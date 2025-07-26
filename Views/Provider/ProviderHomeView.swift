import SwiftUI
import FirebaseAuth

struct ProviderHomeView: View {
    @StateObject private var viewModel = ProviderHomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        if !viewModel.hasOrganization {
                            missingOrgPrompt
                        } else {
                            headerSection
                            adminButton
                            folioSection
                            recentClientsSection
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(PluckrTheme.bodyFont())
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 60)
                }
                .scrollClipDisabled(true)
                
                if viewModel.showSnackbar {
                    snackbarOverlay
                }
            }
            .navigationTitle("Provider Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .navigationDestination(item: $viewModel.selectedClient) { client in
                ClientJournalView(client: client, isActive: Binding(
                    get: { viewModel.selectedClient != nil },
                    set: { newValue in if !newValue { viewModel.selectedClient = nil } }
                ))
            }
        }
        .sheet(isPresented: $viewModel.showJoinOrganization) { JoinOrganizationView() }
        .sheet(isPresented: $viewModel.showCreateOrganization) { CreateOrganizationView() }
        .sheet(isPresented: $viewModel.showAddClient) { 
            AddClientView(onClientAdded: {}, providerDisplayName: viewModel.providerName)
        }
        .sheet(isPresented: $viewModel.showFolioPicker) { folioPickerSheet }
        .onAppear { onAppear() }
        .onDisappear { viewModel.stopObservingClients() }
        .onChange(of: OrganizationService.shared.currentOrganization) { _, organization in
            viewModel.hasOrganization = organization != nil
        }
        .fullScreenCover(isPresented: $viewModel.showLogin) { LoginView() }
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    // MARK: - Computed Properties
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Add Client") { viewModel.showAddClient = true }
                .font(PluckrTheme.bodyFont())
                .foregroundColor(PluckrTheme.accent)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                NavigationLink("Probe Management") { ProbeManagementView() }
                Divider()
                Button("Log Out", role: .destructive) { }
                Button("Delete Account", role: .destructive) { viewModel.showDeleteAccountAlert = true }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(PluckrTheme.textSecondary)
                    .font(PluckrTheme.subheadingFont(size: 22))
            }
        }
    }
    
    private var missingOrgPrompt: some View {
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
                Button("Join Organization") { viewModel.showJoinOrganization = true }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.white)
                    .padding()
                    .background(PluckrTheme.accent)
                    .cornerRadius(16)
                Button("Create Organization") { viewModel.showCreateOrganization = true }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PluckrTheme.card.opacity(0.95))
        .cornerRadius(24)
        .padding(.horizontal, 32)
        .padding(.top, 60)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding / 2) {
            Text("Welcome, \(viewModel.providerName)")
                .font(PluckrTheme.displayFont(size: 32))
                .foregroundColor(PluckrTheme.textPrimary)
            Text("Your clinical journal awaits")
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, PluckrTheme.verticalPadding)
        .padding(.horizontal, PluckrTheme.padding)
    }
    
    @ViewBuilder
    private var adminButton: some View {
        if viewModel.isAdmin {
            Button("Admin Dashboard") { viewModel.showAdminDashboard = true }
                .font(PluckrTheme.bodyFont())
                .foregroundColor(PluckrTheme.accent)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(PluckrTheme.card)
                .cornerRadius(16)
                .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                .padding(.horizontal, PluckrTheme.horizontalPadding)
                .sheet(isPresented: $viewModel.showAdminDashboard) { AdminDashboardView() }
        }
    }
    
    private var folioSection: some View {
        FolioSectionView(
            clients: viewModel.dailyFolioClients,
            onClientTap: { viewModel.selectedClient = $0 },
            onClientRemove: { client in
                withAnimation { viewModel.removeClientFromFolio(client) }
                viewModel.showSnackbarWithTimer(message: "Removed \(client.fullName) from folio", action: .removed(client))
            },
            onAddTap: { viewModel.showFolioPicker = true }
        )

    }
    
    private var recentClientsSection: some View {
        VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
            HStack {
                Text("Recent Clients")
                    .font(PluckrTheme.subheadingFont())
                    .foregroundColor(PluckrTheme.textPrimary)
    
                Spacer()
                NavigationLink("See All") { ClientsListView() }
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.accent)
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
                VStack(spacing: 16) {
                    ForEach(viewModel.filteredClients.prefix(5)) { client in
                        ClientCardView(client: client) {
                            viewModel.selectedClient = client
                        }
                    }
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
                .padding(.top, 8)
            }
        }
    }
    
    private var folioPickerSheet: some View {
        ZStack {
            PluckrTheme.backgroundGradient.ignoresSafeArea()
            AllClientsFolioPickerView { clients in
                for client in clients {
                    withAnimation { viewModel.addClientToFolio(client) }
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
    
    private var snackbarOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Text(viewModel.snackbarMessage)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(.white)
                Spacer()
                Button("Undo") { viewModel.undoLastFolioAction() }
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
    
    // MARK: - Methods
    
    private func onAppear() {
        viewModel.fetchProviderName()
        viewModel.startObservingClients()
        viewModel.loadDailyFolio()
        viewModel.startMidnightReset()
        Task { 
            await viewModel.loadCurrentProvider()
            viewModel.hasOrganization = OrganizationService.shared.currentOrganization != nil
        }
    }
}
