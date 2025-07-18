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
                    headerView
                    folioSection
                    recentClientsSection
                    Spacer()
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

    // MARK: - Subviews

    private var headerView: some View {
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
    }

    private var folioSection: some View {
        FolioSectionView(
            clients: viewModel.dailyFolioClients,
            onClientTap: { selectedClient = $0 },
            onClientRemove: { client in
                withAnimation {
                    viewModel.removeClientFromFolio(client)
                }
                folioHaptic.impactOccurred()
                snackbarMessage = "Removed \(client.fullName) from folio"
                lastFolioAction = .removed(client)
                showSnackbarWithTimer()
            },
            onAddTap: { showFolioPicker = true }
        )
        .padding(.bottom, 16)
    }

    private var recentClientsSection: some View {
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
