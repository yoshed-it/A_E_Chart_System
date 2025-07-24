import SwiftUI

struct ClientJournalMainContent: View {
    @Binding var client: Client
    let onClientUpdated: (Client) -> Void
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
    @Binding var selectedChart: ChartEntry?
    @State private var showEditClient = false

    var body: some View {
        contentWithAlerts
            .sheet(isPresented: $showEditClient) {
                EditClientView(client: client, onSave: { updatedClient in
                    showEditClient = false
                    onClientUpdated(updatedClient)
                })
            }
            .onAppear(perform: handleOnAppear)
            .onChange(of: clientTags, perform: handleOnChangeClientTags)
    }

    var contentWithToolbar: some View {
        ClientJournalMainContentBody(
            client: $client,
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
        .applyJournalToolbar(showNewEntry: $showNewEntry, showingConsentForm: $showingConsentForm, showEditClient: $showEditClient)
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

    private func handleOnAppear() {
        Task {
            await viewModel.loadEntries()
        }
    }

    private func handleOnChangeClientTags(_ newTags: [Tag]) {
        Task {
            // Implement saveClientTags if needed
        }
    }
} 