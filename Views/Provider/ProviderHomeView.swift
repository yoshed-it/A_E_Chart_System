import SwiftUI
import FirebaseAuth
import UIKit

struct ProviderHomeView: View {
    // MARK: - State & Services
    @StateObject private var viewModel = ProviderHomeViewModel()
    @State private var showAddClient = false
    @State private var selectedClient: Client? = nil
    @State private var showFolioPicker = false
    @StateObject private var authService = AuthService()
    @State private var showLogin = false
    @State private var showAdminDashboard = false
    @State private var showJoinOrganization = false
    @State private var showCreateOrganization = false
    @State private var showDeleteAccountAlert = false
    @State private var hasOrganization = false
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

    // MARK: - Body
    var body: some View {
        ZStack {
            PluckrTheme.backgroundGradient.ignoresSafeArea()

            NavigationStack {
                VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                    if !hasOrganization {
                        ProviderMissingOrgPromptView(
                            showJoinOrganization: $showJoinOrganization,
                            showCreateOrganization: $showCreateOrganization
                        )
                    } else {
                        ProviderHeaderView(providerName: viewModel.providerName)
                        if viewModel.isAdmin {
                            Button(action: { showAdminDashboard = true }) {
                                Label("Admin Dashboard", systemImage: "gearshape")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(PluckrTheme.accent)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(PluckrTheme.card)
                                    .cornerRadius(16)
                                    .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                            }
                            .sheet(isPresented: $showAdminDashboard) {
                                AdminDashboardView()
                            }
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                            .padding(.top, 8)
                        }
                        ProviderFolioSectionView(
                            clients: viewModel.dailyFolioClients,
                            onClientTap: { selectedClient = $0 },
                            onClientRemove: { client in
                                withAnimation { viewModel.removeClientFromFolio(client) }
                                folioHaptic.impactOccurred()
                                snackbarMessage = "Removed \(client.fullName) from folio"
                                lastFolioAction = .removed(client)
                                showSnackbarWithTimer()
                            },
                            onAddTap: { showFolioPicker = true }
                        )
                        ProviderRecentClientsSectionView(
                            clients: viewModel.filteredClients,
                            isLoading: viewModel.isLoading,
                            onClientTap: { selectedClient = $0 }
                        )
                        Spacer()
                    }
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(PluckrTheme.bodyFont())
                            .padding(.horizontal)
                    }
                }
                .dynamicTypeSize(.large ... .xxLarge)
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
                            Button("Delete Account", role: .destructive) {
                                showDeleteAccountAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(PluckrTheme.textSecondary)
                                .font(PluckrTheme.subheadingFont(size: 22))
                        }
                    }
                }
                .navigationDestination(item: $selectedClient) { client in
                    ClientJournalView(client: client, isActive: Binding(
                        get: { selectedClient != nil },
                        set: { newValue in if !newValue { selectedClient = nil } }
                    ))
                }
            }
            .sheet(isPresented: $showJoinOrganization) {
                JoinOrganizationView()
            }
            .sheet(isPresented: $showCreateOrganization) {
                CreateOrganizationView()
            }

            if showSnackbar {
                snackbarOverlay
            }
        }
        .sheet(isPresented: $showAddClient) {
            AddClientView(
                onClientAdded: {},
                providerDisplayName: viewModel.providerName
            )
        }
        .sheet(isPresented: $showFolioPicker) {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()

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
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding()
                .shadow(radius: 10)
            }
            .presentationDetents([.large])
            .presentationBackground(.clear)
        }
        .onAppear {
            viewModel.fetchProviderName()
            viewModel.startObservingClients()
            viewModel.loadDailyFolio()
            viewModel.startMidnightReset()
            Task { 
                await viewModel.loadCurrentProvider()
                hasOrganization = OrganizationService.shared.currentOrganization != nil
            }
        }
        .onDisappear {
            viewModel.stopObservingClients()
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            showLogin = !isAuthenticated
        }
        .onChange(of: OrganizationService.shared.currentOrganization) { _, organization in
            hasOrganization = organization != nil
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    let success = await authService.deleteAccount()
                    if success {
                        // User will be automatically signed out and redirected to login
                        PluckrLogger.success("Account deleted successfully")
                    } else {
                        // Error message will be shown via authService.errorMessage
                        PluckrLogger.error("Failed to delete account")
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }

    // MARK: - Subviews

    private struct ProviderHeaderView: View {
        let providerName: String
        var body: some View {
            VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding / 2) {
                Text("Welcome, \(providerName)")
                    .font(PluckrTheme.displayFont(size: 32))
                    .foregroundColor(PluckrTheme.textPrimary)
                Text("Your clinical journal awaits")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.top, PluckrTheme.verticalPadding)
        }
    }

    private struct ProviderFolioSectionView: View {
        let clients: [Client]
        let onClientTap: (Client) -> Void
        let onClientRemove: (Client) -> Void
        let onAddTap: () -> Void
        var body: some View {
            FolioSectionView(
                clients: clients,
                onClientTap: onClientTap,
                onClientRemove: onClientRemove,
                onAddTap: onAddTap
            )
            .padding(.bottom, 16)
        }
    }

    private struct ProviderRecentClientsSectionView: View {
        let clients: [Client]
        let isLoading: Bool
        let onClientTap: (Client) -> Void
        var body: some View {
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
                if isLoading {
                    LoadingView(message: "Loading clients...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                } else if clients.isEmpty {
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
                            ForEach(clients.prefix(5)) { client in
                                ClientCardView(client: client) {
                                    onClientTap(client)
                                }
                            }
                        }
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                    }
                }
            }
        }
    }



    private struct ProviderMissingOrgPromptView: View {
        @Binding var showJoinOrganization: Bool
        @Binding var showCreateOrganization: Bool
        var body: some View {
            VStack(spacing: 24) {
                Text("You're not part of any organization yet.")
                    .font(PluckrTheme.headingFont(size: 24))
                    .foregroundColor(PluckrTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Please join or create an organization to get started.")
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 16) {
                    Button(action: { showJoinOrganization = true }) {
                        Label("Join Organization", systemImage: "person.badge.plus")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(.white)
                            .padding()
                            .background(PluckrTheme.accent)
                            .cornerRadius(16)
                    }
                    Button(action: { showCreateOrganization = true }) {
                        Label("Create Organization", systemImage: "plus.circle")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(16)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PluckrTheme.card.opacity(0.95))
            .cornerRadius(24)
            .padding(.horizontal, 32)
            .padding(.top, 60)
        }
    }

    private var snackbarOverlay: some View {
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

    // MARK: - Snackbar Helpers

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
