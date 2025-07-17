import SwiftUI
import FirebaseAuth
import UIKit

struct ProviderHomeView: View {
    @StateObject private var viewModel = ProviderHomeViewModel()
    @State private var showAddClient = false
    @State private var selectedClient: Client? = nil
    @State private var showFolioPicker = false
    @StateObject private var authService = AuthService()
    @State private var showLogin = false
    private let folioHaptic = UIImpactFeedbackGenerator(style: .light)
    // Snackbar/Undo state
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var lastFolioAction: FolioAction? = nil
    @State private var snackbarTimer: Timer? = nil

    enum FolioAction {
        case added(Client)
        case removed(Client)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding / 2) {
                        Text("Welcome, \(viewModel.providerName)")
                            .font(PluckrTheme.displayFont(size: 32))
                            .foregroundColor(PluckrTheme.textPrimary)
                        Text("Your clinical journal awaits")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    .padding(.top, PluckrTheme.verticalPadding)

                    // Daily Folio Section
                    FolioSectionView(
                        clients: viewModel.dailyFolioClients,
                        onClientTap: { client in
                            selectedClient = client
                        },
                        onClientRemove: { client in
                            withAnimation {
                                viewModel.removeClientFromFolio(client)
                            }
                            folioHaptic.impactOccurred()
                            snackbarMessage = "Removed \(client.fullName) from folio"
                            lastFolioAction = .removed(client)
                            showSnackbarWithTimer()
                        },
                        onAddTap: {
                            showFolioPicker = true
                        }
                    )
                    .padding(.bottom, 16)
                    .sheet(isPresented: $showFolioPicker) {
                        AllClientsFolioPickerView { clients in
                            for client in clients {
                                withAnimation {
                                    viewModel.addClientToFolio(client)
                                }
                                folioHaptic.impactOccurred()
                                snackbarMessage = "Added \(client.fullName) to folio"
                                lastFolioAction = .added(client)
                                showSnackbarWithTimer()
                            }
                            showFolioPicker = false
                        }
                    }

                    // Recent Clients Section
                    VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                        HStack {
                            Text("Recent Clients")
                                .font(PluckrTheme.subheadingFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                            Spacer()
                            NavigationLink(destination: ClientsListView()) {
                                Text("See All")
                                    .font(PluckrTheme.captionFont())
                                    .foregroundColor(PluckrTheme.accent)
                            }
                        }
                        .padding(.horizontal, PluckrTheme.horizontalPadding)

                        if viewModel.isLoading {
                            LoadingView(message: "Loading clients...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
                        } else if viewModel.filteredClients.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No clients yet")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(PluckrTheme.textSecondary)
                                Text("Add your first client to get started")
                                    .font(PluckrTheme.captionFont())
                                    .foregroundColor(PluckrTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.filteredClients.prefix(5)) { client in
                                        ClientCardView(client: client) {
                                            selectedClient = client
                                        }
                                    }
                                }
                                .padding(.horizontal, PluckrTheme.horizontalPadding)
                            }
                        }
                    }
                    .padding(.top, 0)

                    Spacer()
                }
                .dynamicTypeSize(.large ... .xxLarge)
                // Snackbar overlay
                if showSnackbar {
                    VStack {
                        Spacer()
                        HStack {
                            Text(snackbarMessage)
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(.white)
                            Spacer()
                            Button("Undo") {
                                undoLastFolioAction()
                            }
                            .font(PluckrTheme.captionFont().bold())
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showSnackbar)
                }
            }
            .navigationTitle("Provider Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddClient = true }) {
                        Text("Add Client")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink("Probe Management") {
                            ProbeManagementView()
                        }
                        Divider()
                        Button("Log Out", role: .destructive) {
                            authService.signOut()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(PluckrTheme.textSecondary)
                            .font(PluckrTheme.subheadingFont(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView(
                    onClientAdded: {}, // No longer needed thanks to live updates
                    providerDisplayName: viewModel.providerName
                )
            }
            .navigationDestination(item: $selectedClient) { client in
                ClientJournalView(client: client, isActive: Binding(
                    get: { selectedClient != nil },
                    set: { newValue in if !newValue { selectedClient = nil } }
                ))
            }
            .onAppear {
                viewModel.fetchProviderName()
                viewModel.startObservingClients()
                viewModel.loadDailyFolio()
                viewModel.startMidnightReset()
            }
            .onDisappear {
                viewModel.stopObservingClients()
            }
            .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
                showLogin = !isAuthenticated
            }
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
            }
        }
    }

    // MARK: - Snackbar/Undo helpers
    private func showSnackbarWithTimer() {
        snackbarTimer?.invalidate()
        showSnackbar = true
        snackbarTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation { showSnackbar = false }
        }
    }

    private func undoLastFolioAction() {
        guard let action = lastFolioAction else { return }
        switch action {
        case .added(let client):
            withAnimation { viewModel.removeClientFromFolio(client) }
            snackbarMessage = "Undid add: \(client.fullName)"
        case .removed(let client):
            withAnimation { viewModel.addClientToFolio(client) }
            snackbarMessage = "Undid remove: \(client.fullName)"
        }
        lastFolioAction = nil
        showSnackbarWithTimer()
    }
}

struct AllClientsFolioPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClientIds: Set<String> = []
    @StateObject private var homeViewModel = ProviderHomeViewModel() // For folio status
    let onClientsScribed: ([Client]) -> Void
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                TextField("Search clients...", text: $viewModel.searchText)
                    .pluckrTextField()
                    .padding(.horizontal)
                    .padding(.top)
                // Client List
                List(viewModel.filteredClients) { client in
                    let inFolio = homeViewModel.dailyFolioClients.contains(where: { $0.id == client.id })
                    MultipleSelectionRow(
                        client: client,
                        isSelected: selectedClientIds.contains(client.id),
                        isDisabled: inFolio,
                        inFolio: inFolio
                    ) {
                        if !inFolio {
                            if selectedClientIds.contains(client.id) {
                                selectedClientIds.remove(client.id)
                            } else {
                                selectedClientIds.insert(client.id)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                // Scribe Button
                VStack(spacing: 8) {
                    if !selectedClientIds.isEmpty {
                        Text("\(selectedClientIds.count) selected")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(.secondary)
                    }
                    Button(action: {
                        let selectedClients = viewModel.filteredClients.filter { selectedClientIds.contains($0.id) }
                        onClientsScribed(selectedClients)
                        dismiss()
                    }) {
                        Text("Scribe to Folio")
                            .font(PluckrTheme.subheadingFont())
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedClientIds.isEmpty ? Color.gray.opacity(0.3) : PluckrTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(PluckrTheme.buttonCornerRadius)
                    }
                    .disabled(selectedClientIds.isEmpty)
                    .padding([.horizontal, .bottom])
                }
            }
            .navigationTitle("Add to Daily Folio")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchClients()
                homeViewModel.loadDailyFolio()
            }
        }
    }
}

struct MultipleSelectionRow: View {
    let client: Client
    let isSelected: Bool
    let isDisabled: Bool
    let inFolio: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(client.fullName)
                    .foregroundColor(isDisabled ? .gray : .primary)
                Spacer()
                if inFolio {
                    Label("In Folio", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
