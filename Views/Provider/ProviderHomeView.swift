import SwiftUI
import FirebaseAuth
import UIKit

struct ProviderHomeView: View {
    // MARK: - State & Services
    @StateObject private var viewModel = ProviderHomeViewModel()
    // Remove all local snackbar/undo and navigation/modal state
    // private let folioHaptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        ZStack {
            PluckrTheme.backgroundGradient.ignoresSafeArea()

            NavigationStack {
                VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                    if !viewModel.hasOrganization {
                        ProviderMissingOrgPromptView(
                            showJoinOrganization: $viewModel.showJoinOrganization,
                            showCreateOrganization: $viewModel.showCreateOrganization
                        )
                    } else {
                        ProviderHeaderView(providerName: viewModel.providerName)
                        if viewModel.isAdmin {
                            Button(action: { viewModel.showAdminDashboard = true }) {
                                Label("Admin Dashboard", systemImage: "gearshape")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(PluckrTheme.accent)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(PluckrTheme.card)
                                    .cornerRadius(16)
                                    .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                            }
                            .sheet(isPresented: $viewModel.showAdminDashboard) {
                                AdminDashboardView()
                            }
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                            .padding(.top, 8)
                        }
                        ProviderFolioSectionView(
                            clients: viewModel.dailyFolioClients,
                            onClientTap: { viewModel.selectedClient = $0 },
                            onClientRemove: { client in
                                withAnimation { viewModel.removeClientFromFolio(client) }
                                // folioHaptic.impactOccurred() // Optionally add haptic in ViewModel
                                viewModel.showSnackbarWithTimer(message: "Removed \(client.fullName) from folio", action: .removed(client))
                            },
                            onAddTap: { viewModel.showFolioPicker = true }
                        )
                        ProviderRecentClientsSectionView(
                            clients: viewModel.filteredClients,
                            isLoading: viewModel.isLoading,
                            onClientTap: { viewModel.selectedClient = $0 }
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
                        Button(action: { viewModel.showAddClient = true }) {
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
                                // authService.signOut() // Keep as is if needed
                            }
                            Button("Delete Account", role: .destructive) {
                                viewModel.showDeleteAccountAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(PluckrTheme.textSecondary)
                                .font(PluckrTheme.subheadingFont(size: 22))
                        }
                    }
                }
                .navigationDestination(item: $viewModel.selectedClient) { client in
                    ClientJournalView(client: client, isActive: Binding(
                        get: { viewModel.selectedClient != nil },
                        set: { newValue in if !newValue { viewModel.selectedClient = nil } }
                    ))
                }
            }
            .sheet(isPresented: $viewModel.showJoinOrganization) {
                JoinOrganizationView()
            }
            .sheet(isPresented: $viewModel.showCreateOrganization) {
                CreateOrganizationView()
            }

            if viewModel.showSnackbar {
                snackbarOverlay
            }
        }
        .sheet(isPresented: $viewModel.showAddClient) {
            AddClientView(
                onClientAdded: {},
                providerDisplayName: viewModel.providerName
            )
        }
        .sheet(isPresented: $viewModel.showFolioPicker) {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()

                AllClientsFolioPickerView { clients in
                    for client in clients {
                        withAnimation {
                            viewModel.addClientToFolio(client)
                        }
                        // folioHaptic.impactOccurred() // Optionally add haptic in ViewModel
                        viewModel.showSnackbarWithTimer(message: "Added \(client.fullName) to folio", action: .added(client))
                    }
                    viewModel.showFolioPicker = false
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
                viewModel.hasOrganization = OrganizationService.shared.currentOrganization != nil
            }
        }
        .onDisappear {
            viewModel.stopObservingClients()
        }
        // .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
        //     viewModel.showLogin = !isAuthenticated
        // }
        .onChange(of: OrganizationService.shared.currentOrganization) { _, organization in
            viewModel.hasOrganization = organization != nil
        }
        .fullScreenCover(isPresented: $viewModel.showLogin) {
            LoginView()
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Task {
                //     let success = await authService.deleteAccount()
                //     if success {
                //         PluckrLogger.success("Account deleted successfully")
                //     } else {
                //         PluckrLogger.error("Failed to delete account")
                //     }
                // }
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
                Text(viewModel.snackbarMessage)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(.white)
                Spacer()
                Button("Undo") {
                    viewModel.undoLastFolioAction()
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
        .animation(.easeInOut, value: viewModel.showSnackbar)
    }
}
