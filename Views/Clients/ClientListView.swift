import SwiftUI
import SwiftUIX // For enhanced text field
import UIKit

struct ClientsListView: View {
    @Environment(\.appEnvironment) private var env
    @StateObject private var viewModel: ClientsListViewModel
    @StateObject private var homeViewModel = ProviderHomeViewModel() // For folio actions
    @State private var selectedClient: Client? = nil
    @State private var clientToDelete: Client? = nil
    @State private var showDeleteAlert = false
    private let folioHaptic = UIImpactFeedbackGenerator(style: .light)

    enum FolioAction {
        case added(Client)
        case removed(Client)
    }

    init() {
        _viewModel = StateObject(wrappedValue: ClientsListViewModel(clientRepository: AppEnvironment.live.clientRepository))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: PluckrTheme.verticalPadding) {
                    // Search Field
                    CocoaTextField("Search clients...", text: $viewModel.searchText)
                        .font(PluckrTheme.bodyFont())
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                        .padding(.vertical, 10)
                        .background(PluckrTheme.card)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                        .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                        .padding(.top, PluckrTheme.verticalPadding)

                    if viewModel.isLoading {
                        ProgressView("Loading clients...")
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.filteredClients) { client in
                                    ClientRowView(
                                        client: client,
                                        isInFolio: homeViewModel.dailyFolioClients.contains(where: { $0.id == client.id }),
                                        onSelect: { selectedClient = client },
                                        onAddToFolio: {
                                            withAnimation {
                                                homeViewModel.addClientToFolio(client)
                                            }
                                            folioHaptic.impactOccurred()
                                            viewModel.showSnackbar(message: "Added \(client.fullName) to folio", action: .added(client))
                                        },
                                        onDelete: {
                                            clientToDelete = client
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                            .padding(.bottom, PluckrTheme.verticalPadding / 2)
                        }
                    }
                }
                SnackbarView(
                    message: viewModel.snackbarMessage,
                    onUndo: viewModel.canUndo ? { viewModel.undoLastFolioAction() } : nil,
                    isPresented: $viewModel.showSnackbar
                )
            }
            .navigationTitle("All Clients")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedClient) { client in
                ClientJournalView(client: client, isActive: Binding(
                    get: { selectedClient != nil },
                    set: { newValue in if (!newValue) { selectedClient = nil } }
                ))
            }
            .onAppear {
                viewModel.fetchClients()
                homeViewModel.loadDailyFolio()
            }
            .alert("Delete Client?", isPresented: $showDeleteAlert, presenting: clientToDelete) { client in
                Button("Delete", role: .destructive) {
                    viewModel.deleteClient(client) { success in
                        if success {
                            PluckrLogger.info("Client \(client.fullName) deleted successfully")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { client in
                Text("Are you sure you want to delete \(client.fullName)? This cannot be undone.")
            }
        }
    }
}
