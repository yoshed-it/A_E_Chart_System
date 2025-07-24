// MARK: - ClientJournalView.swift

import SwiftUI
import SwiftUIIntrospect

struct ClientJournalView: View {
    @State var client: Client
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
    @State private var selectedChart: ChartEntry? = nil
    
    init(client: Client, isActive: Binding<Bool>) {
        self._client = State(initialValue: client)
        self._isActive = isActive
        self._viewModel = StateObject(wrappedValue: ClientJournalViewModel(clientId: client.id))
    }
    
    var body: some View {
        ZStack {
            PluckrTheme.backgroundGradient.ignoresSafeArea()
            ClientJournalMainContent(
                client: $client,
                onClientUpdated: { updatedClient in
                    client = updatedClient
                },
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
                isActive: $isActive,
                selectedChart: $selectedChart
            )
        }
        .onChange(of: clientTags) { newTags in
            Task {
                await saveClientTags(newTags)
            }
        }
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
