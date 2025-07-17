// MARK: - ClientJournalView.swift

import SwiftUI
import SwiftUIIntrospect

struct ClientJournalView: View {
    let client: Client
    @Binding var isActive: Bool
    @StateObject private var viewModel: ClientJournalViewModel
    @State private var showNewEntry = false
    @State private var editingChart: ChartEntry? = nil
    @State private var showEditSheet = false
    @State private var deletingChart: ChartEntry? = nil
    @State private var showDeleteAlert = false
    @StateObject private var editFormViewModel = ChartEntryFormViewModel()
    @State private var selectedChartId: String? = nil
    @State private var activeSheet: ActiveSheet? = nil
    @State private var showingClientTagPicker = false
    @State private var showDeleteClientAlert = false
    @State private var clientTags: [Tag] = []
    @State private var availableClientTags: [Tag] = []
    @State private var showingConsentForm = false
    
    init(client: Client, isActive: Binding<Bool>) {
        self.client = client
        self._isActive = isActive
        self._viewModel = StateObject(wrappedValue: ClientJournalViewModel(clientId: client.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            ClientJournalTagsSection(
                clientTags: clientTags,
                onShowTagPicker: { showingClientTagPicker = true }
            )
            ClientJournalChartEntriesSection(
                entries: viewModel.entries,
                onEntryTap: { entry in
                    editingChart = entry
                    showEditSheet = true
                }
            )
        }
        .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Image Consent Form") {
                        showingConsentForm = true
                    }
                    // Future: Add more client options/settings here
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewEntry = true
                } label: {
                    Text("Add Chart")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.accent)
                }
            }
        }
        .sheet(isPresented: $showNewEntry) {
            ChartEntryFormView(
                viewModel: ChartEntryFormViewModel(),
                clientId: client.id,
                chartId: nil
            ) {
                Task {
                    await viewModel.loadEntries()
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let editingChart = editingChart {
                ChartEntryFormView(
                    viewModel: editFormViewModel,
                    clientId: client.id,
                    chartId: editingChart.id
                ) {
                    Task {
                        await viewModel.loadEntries()
                    }
                }
            }
        }
        .sheet(isPresented: $showingClientTagPicker) {
            TagPickerModal(
                selectedTags: $clientTags,
                availableTags: availableClientTags,
                context: .client
            )
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
        .alert("Delete Client?", isPresented: $showDeleteClientAlert) {
            Button("Delete", role: .destructive) {
                deleteClient()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(client.fullName)? This will permanently delete the client and all their chart entries. This action cannot be undone.")
        }
        .onAppear {
            Task {
                await viewModel.loadEntries()
                await loadClientTags()
                await loadAvailableClientTags()
            }
        }
        .onChange(of: clientTags) { _, newTags in
            Task {
                await saveClientTags(newTags)
            }
        }
        .sheet(isPresented: $showingConsentForm) {
            ImageConsentFormView(client: client) { updatedClient in
                // TODO: Update client in Firestore and local state
            }
        }
    }

    // MARK: - Subviews
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.fullName)
                .font(PluckrTheme.displayFont())
                .foregroundColor(PluckrTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                if let phone = client.phone, !phone.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text(phone)
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                }
                if let email = client.email, !email.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text(email)
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, PluckrTheme.horizontalPadding)
        .padding(.top, PluckrTheme.verticalPadding)
        .padding(.bottom, 16)
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CLIENT TAGS")
                    .pluckrSectionHeader()
                Spacer()
                Button {
                    showingClientTagPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                        .font(PluckrTheme.subheadingFont(size: 22))
                }
            }
            if clientTags.isEmpty {
                Text("No tags added yet")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 6) {
                    ForEach(clientTags) { tag in
                        TagView(tag: tag)
                    }
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
            }
        }
        .padding(.horizontal, PluckrTheme.horizontalPadding)
        .padding(.vertical, PluckrTheme.verticalPadding)
    }
    
    private var chartEntriesSection: some View {
        List {
            ForEach(viewModel.entries) { entry in
                ChartEntryCard(entry: entry)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button {
                            editingChart = entry
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(PluckrTheme.captionFont())
                                .fontWeight(.medium)
                        }
                        .tint(Color.gray.opacity(0.6))
                        
                        Button(role: .destructive) {
                            deletingChart = entry
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(PluckrTheme.captionFont())
                                .fontWeight(.medium)
                        }
                        .tint(Color.red.opacity(0.5))
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    .padding(.vertical, 16)
            }
        }
        .listStyle(.plain)
        .background(Color.clear)
    }
    
    // MARK: - Client Tag Management
    private func loadClientTags() async {
        // Load client tags from the client object or database
        // For now, we'll use an empty array and implement this later
        clientTags = []
    }
    
    private func loadAvailableClientTags() async {
        availableClientTags = await TagService.shared.getAvailableTags(context: .client)
    }
    
    private func saveClientTags(_ tags: [Tag]) async {
        do {
            try await TagService.shared.updateClientTags(clientId: client.id, tags: tags)
        } catch {
            print("Failed to save client tags: \(error)")
        }
    }
    
    private func deleteClient() {
        // Implementation for deleting client
        print("Delete client implementation")
    }
}

// MARK: - ActiveSheet Enum
enum ActiveSheet: Identifiable {
    case newEntry
    case editEntry(ChartEntry)
    case tagPicker
    
    var id: Int {
        switch self {
        case .newEntry:
            return 0
        case .editEntry:
            return 1
        case .tagPicker:
            return 2
        }
    }
}
