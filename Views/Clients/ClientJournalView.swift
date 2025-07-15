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
                    Text("Last Seen: \(formattedDate(from: lastSeen))")
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
            } else {
                List {
                    ForEach(viewModel.entries) { entry in
                        ChartEntryCard(entry: entry)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingChart = entry
                                showEditSheet = true
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    editingChart = entry
                                    showEditSheet = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(.blue)
                                Button(role: .destructive) {
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
                    showNewEntry = true
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
        .sheet(isPresented: $showNewEntry) {
            ChartEntryFormView(
                viewModel: ChartEntryFormViewModel(),
                clientId: client.id,
                chartId: nil,
                onSave: {
                    Task {
                        await viewModel.loadEntries()
                    }
                }
            )
        }
        .sheet(isPresented: $showEditSheet) {
            if let chart = editingChart {
                ChartEntryFormView(
                    viewModel: ChartEntryFormViewModel(),
                    clientId: client.id,
                    chartId: chart.id,
                    onSave: {
                        Task {
                            await viewModel.loadEntries()
                        }
                        showEditSheet = false
                    }
                )
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
}
