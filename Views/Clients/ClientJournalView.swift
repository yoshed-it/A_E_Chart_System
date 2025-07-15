// MARK: - ClientJournalView.swift

import SwiftUI

struct ClientJournalView: View {
    let client: Client
    @StateObject private var viewModel: ClientJournalViewModel
    @State private var showNewEntry = false
    @State private var editingChart: ChartEntry? = nil
    @State private var showEditSheet = false
    @State private var deletingChart: ChartEntry? = nil
    @State private var showDeleteAlert = false
    @StateObject private var editFormViewModel = ChartEntryFormViewModel()
    @State private var selectedChartId: String? = nil
    @State private var activeSheet: ActiveSheet? = nil

    init(client: Client) {
        self.client = client
        _viewModel = StateObject(wrappedValue: ClientJournalViewModel(clientId: client.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(client.fullName)
                    .font(.system(size: 34, weight: .bold, design: .serif))

                if let lastSeen = client.lastSeenAt {
                    Text("Last Seen: \(relativeDaysAgo(from: lastSeen))")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .padding(.top)

            // Tags (Placeholder for future implementation)
            HStack(spacing: 8) {
                TagView(text: "Coarse Hair")
                TagView(text: "Dry Skin")
                TagView(text: "New Client")
            }

            // Chart Entries List
            if viewModel.isLoading {
                ProgressView("Loading charts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.entries.isEmpty {
                Text("No chart entries yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.entries) { entry in
                        ChartEntryCard(entry: entry)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                PluckrLogger.info("Tapped chart \(entry.id) for detail view")
                                activeSheet = .detail(entry)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    PluckrLogger.info("Editing chart \(entry.id) via swipe")
                                    Task {
                                        editFormViewModel.isLoading = true
                                        await editFormViewModel.loadChart(for: client.id, chartId: entry.id)
                                        selectedChartId = entry.id
                                        activeSheet = .editEntry
                                    }
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(.blue)
                                Button(role: .destructive) {
                                    PluckrLogger.info("Deleting chart \(entry.id)")
                                    deletingChart = entry
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    activeSheet = .newEntry
                } label: {
                    Text("New Entry")
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newEntry:
                ChartEntryFormView(
                    viewModel: ChartEntryFormViewModel(),
                    clientId: client.id,
                    chartId: nil,
                    onSave: {
                        Task {
                            await viewModel.loadEntries()
                        }
                        activeSheet = nil
                    }
                )
            case .editEntry:
                if let chartId = selectedChartId {
                    ChartEntryFormView(
                        viewModel: editFormViewModel,
                        clientId: client.id,
                        chartId: chartId,
                        onSave: {
                            Task {
                                await viewModel.loadEntries()
                            }
                            activeSheet = nil
                        }
                    )
                }
            case .detail(let chart):
                ChartDetailView(chart: chart, onEdit: {
                    Task {
                        editFormViewModel.isLoading = true
                        await editFormViewModel.loadChart(for: client.id, chartId: chart.id)
                        selectedChartId = chart.id
                        activeSheet = .editEntry
                    }
                })
            }
        }
        .alert("Delete Chart?", isPresented: $showDeleteAlert, presenting: deletingChart) { chart in
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteEntry(chartId: chart.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { chart in
            Text("Are you sure you want to delete this chart? This action cannot be undone.")
        }
        .onAppear {
            Task {
                await viewModel.loadEntries()
            }
        }
    }

    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func relativeDaysAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

enum ActiveSheet: Identifiable, Equatable {
    case newEntry, editEntry, detail(ChartEntry)
    var id: String {
        switch self {
        case .newEntry: return "newEntry"
        case .editEntry: return "editEntry"
        case .detail(let chart): return chart.id
        }
    }
    static func == (lhs: ActiveSheet, rhs: ActiveSheet) -> Bool {
        switch (lhs, rhs) {
        case (.newEntry, .newEntry): return true
        case (.editEntry, .editEntry): return true
        case let (.detail(a), .detail(b)): return a.id == b.id
        default: return false
        }
    }
}
