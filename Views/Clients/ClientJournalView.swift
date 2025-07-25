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
    // Tag state now managed by ViewModel
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
                clientTags: $viewModel.clientTags,
                availableClientTags: $viewModel.availableClientTags,
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
        .onChange(of: viewModel.clientTags) { newTags in
            Task {
                await viewModel.saveClientTags(clientId: client.id, tags: newTags)
            }
        }
        .onAppear {
            Task {
                PluckrLogger.info("ClientJournalView: onAppear - starting tag loading")
                await viewModel.loadClientTags(client: client)
                PluckrLogger.info("ClientJournalView: onAppear - clientTags loaded: \(viewModel.clientTags.count)")
                await viewModel.loadAvailableClientTags()
                PluckrLogger.info("ClientJournalView: onAppear - availableClientTags loaded: \(viewModel.availableClientTags.count)")
            }
        }
    }
    
}
