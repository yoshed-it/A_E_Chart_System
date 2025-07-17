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
        ClientJournalMainContent(
            client: client,
            clientTags: $clientTags,
            availableClientTags: $availableClientTags,
            viewModel: viewModel,
            selectedChartId: $selectedChartId,
            activeSheet: $activeSheet,
            editingChart: $editingChart,
            showEditSheet: $showEditSheet,
            deletingChart: $deletingChart,
            showDeleteAlert: $showDeleteAlert,
            showNewEntry: $showNewEntry,
            showDeleteClientAlert: $showDeleteClientAlert,
            showingClientTagPicker: $showingClientTagPicker,
            showingConsentForm: $showingConsentForm,
            editFormViewModel: editFormViewModel,
            isActive: $isActive
        )
    }
    
    // MARK: - Chart Entries List Section
    // Remove the private ChartEntriesListSection struct
    
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

// MARK: - Main Content Subview
private struct ClientJournalMainContent: View {
    let client: Client
    @Binding var clientTags: [Tag]
    @Binding var availableClientTags: [Tag]
    @ObservedObject var viewModel: ClientJournalViewModel
    @Binding var selectedChartId: String?
    @Binding var activeSheet: ActiveSheet?
    @Binding var editingChart: ChartEntry?
    @Binding var showEditSheet: Bool
    @Binding var deletingChart: ChartEntry?
    @Binding var showDeleteAlert: Bool
    @Binding var showNewEntry: Bool
    @Binding var showDeleteClientAlert: Bool
    @Binding var showingClientTagPicker: Bool
    @Binding var showingConsentForm: Bool
    var editFormViewModel: ChartEntryFormViewModel
    @Binding var isActive: Bool

    // Refactored: break up chained modifiers into computed properties
    var contentWithToolbar: some View {
        mainContent
            .applyJournalToolbar(showNewEntry: $showNewEntry, showingConsentForm: $showingConsentForm)
    }

    var contentWithSheets: some View {
        contentWithToolbar
            .applyJournalSheets(
                showNewEntry: $showNewEntry,
                showEditSheet: $showEditSheet,
                editingChart: $editingChart,
                editFormViewModel: editFormViewModel,
                client: client,
                viewModel: viewModel,
                clientTags: $clientTags,
                availableClientTags: availableClientTags,
                showingClientTagPicker: $showingClientTagPicker,
                showingConsentForm: $showingConsentForm
            )
    }

    var contentWithAlerts: some View {
        contentWithSheets
            .applyJournalAlerts(
                showDeleteAlert: $showDeleteAlert,
                deletingChart: $deletingChart,
                viewModel: viewModel,
                showDeleteClientAlert: $showDeleteClientAlert,
                client: client
            )
    }

    var body: some View {
        contentWithAlerts
            .onAppear(perform: handleOnAppear)
            .onChange(of: clientTags, perform: handleOnChangeClientTags)
    }

    // MARK: - Header and Tags Subview
    private var headerAndTags: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.fullName)
                .font(PluckrTheme.displayFont())
                .foregroundColor(PluckrTheme.textPrimary)
                .padding(.top, PluckrTheme.verticalPadding)
            if let lastSeen = client.lastSeenAt {
                Text("Last Seen: \(lastSeen.formatted(date: .abbreviated, time: .omitted))")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                    .padding(.bottom, 4)
            }
            ClientJournalTagsSection(
                clientTags: clientTags,
                onShowTagPicker: { showingClientTagPicker = true }
            )
            // No extra padding or centering, left-justified
        }
        .padding(.horizontal, PluckrTheme.horizontalPadding)
    }

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header: Name and Last Seen
                Text(client.fullName)
                    .font(PluckrTheme.displayFont())
                    .foregroundColor(PluckrTheme.textPrimary)
                    .padding(.top, PluckrTheme.verticalPadding)
                if let lastSeen = client.lastSeenAt {
                    Text("Last Seen: \(lastSeen.formatted(date: .abbreviated, time: .omitted))")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                        .padding(.bottom, 4)
                }
                ClientJournalTagsSection(
                    clientTags: clientTags,
                    onShowTagPicker: { showingClientTagPicker = true }
                )
                .padding(.bottom, 16)

                // Chart Entries as cards (swipe-to-delete only)
                if viewModel.isLoading {
                    LoadingView(message: "Loading chart entries...")
                        .padding(.top, 32)
                } else if viewModel.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text("No chart entries yet.")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text("Tap 'Add Chart' to create a new entry for this client.")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.entries) { entry in
                            SwipeToDeleteView(onDelete: {
                                deletingChart = entry
                                showDeleteAlert = true
                            }) {
                                ChartEntryCard(entry: entry)
                                    .onTapGesture {
                                        editingChart = entry
                                        showEditSheet = true
                                    }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.bottom, 32)
        }
        .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleOnAppear() {
        Task {
            await viewModel.loadEntries()
            // Implement loadClientTags and loadAvailableClientTags if needed
        }
    }

    private func handleOnChangeClientTags(_ newTags: [Tag]) {
        Task {
            // Implement saveClientTags if needed
        }
    }
}

// MARK: - View Extensions for Modifiers
private extension View {
    func applyJournalToolbar(showNewEntry: Binding<Bool>, showingConsentForm: Binding<Bool>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Image Consent Form") {
                        showingConsentForm.wrappedValue = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewEntry.wrappedValue = true
                } label: {
                    Text("Add Chart")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }

    func applyJournalSheets(
        showNewEntry: Binding<Bool>,
        showEditSheet: Binding<Bool>,
        editingChart: Binding<ChartEntry?>,
        editFormViewModel: ChartEntryFormViewModel,
        client: Client,
        viewModel: ClientJournalViewModel,
        clientTags: Binding<[Tag]>,
        availableClientTags: [Tag],
        showingClientTagPicker: Binding<Bool>,
        showingConsentForm: Binding<Bool>
    ) -> some View {
        self
            .sheet(isPresented: showNewEntry) {
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
            .sheet(item: editingChart) { chart in
                ChartEntryFormView(
                    viewModel: editFormViewModel,
                    clientId: client.id,
                    chartId: chart.id
                ) {
                    Task {
                        await viewModel.loadEntries()
                    }
                }
            }
            .sheet(isPresented: showingClientTagPicker) {
                TagPickerModal(
                    selectedTags: clientTags,
                    availableTags: availableClientTags,
                    context: .client
                )
            }
            .sheet(isPresented: showingConsentForm) {
                ImageConsentFormView(client: client) { updatedClient in
                    // TODO: Update client in Firestore and local state
                }
            }
    }

    func applyJournalAlerts(
        showDeleteAlert: Binding<Bool>,
        deletingChart: Binding<ChartEntry?>,
        viewModel: ClientJournalViewModel,
        showDeleteClientAlert: Binding<Bool>,
        client: Client
    ) -> some View {
        self
            .alert("Delete Chart?", isPresented: showDeleteAlert, presenting: deletingChart.wrappedValue) { chart in
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteEntry(chartId: chart.id)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { chart in
                Text("Are you sure you want to delete this chart? This action cannot be undone.")
            }
            .alert("Delete Client?", isPresented: showDeleteClientAlert) {
                Button("Delete", role: .destructive) {
                    // Implement deleteClient logic here if needed
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \(client.fullName)? This will permanently delete the client and all their chart entries. This action cannot be undone.")
            }
    }
}

// MARK: - ActiveSheet Enum
enum ActiveSheet: Identifiable {
    case newEntry
    case editEntry(ChartEntry)
    case tagPicker
    case viewChart

    var id: Int {
        switch self {
        case .newEntry: return 0
        case .editEntry: return 1
        case .tagPicker: return 2
        case .viewChart: return 3
        }
    }
}
