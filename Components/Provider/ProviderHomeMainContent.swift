import SwiftUI
import FirebaseAuth

/**
 *Main content view for ProviderHomeView*
 
 This component contains the main UI content for the provider home screen,
 including the header, daily folio, recent clients, and admin dashboard.
 
 ## Usage
 - Used in: ProviderHomeView
 */
struct ProviderHomeMainContent: View {
    @ObservedObject var viewModel: ProviderHomeViewModel
    @Binding var showAddClient: Bool
    @Binding var showAdminDashboard: Bool
    @Binding var showFolioPicker: Bool
    @Binding var showJoinOrganization: Bool
    @Binding var showCreateOrganization: Bool
    @Binding var selectedClient: Client?
    @Binding var showDeleteAccountAlert: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !viewModel.hasOrganization {
                    ProviderMissingOrgPromptView(
                        showJoinOrganization: $showJoinOrganization,
                        showCreateOrganization: $showCreateOrganization
                    )
                } else {
                    // Fixed header section - takes up its natural height
                    VStack(alignment: .leading, spacing: 0) {
                        ProviderHeaderView(providerName: viewModel.providerName)
                            .padding(.bottom, 32) // More space between header and admin button
                        
                        ProviderAdminDashboardSection(showAdminDashboard: $showAdminDashboard)
                            .padding(.bottom, 40) // More space between admin button and folio
                        
                        FolioSectionView(
                            clients: viewModel.dailyFolioClients,
                            onClientTap: { client in
                                print("🔍 [ProviderHomeMainContent] Folio client tapped: \(client.fullName)")
                                print("🔍 [ProviderHomeMainContent] Before setting selectedClient: \(viewModel.selectedClient?.fullName ?? "nil")")
                                viewModel.selectedClient = client
                                print("🔍 [ProviderHomeMainContent] After setting selectedClient: \(viewModel.selectedClient?.fullName ?? "nil")")
                            },
                            onClientRemove: { client in
                                withAnimation { viewModel.removeClientFromFolio(client) }
                                // TODO: Show snackbar
                            },
                            onAddTap: {
                                print("Add to folio button tapped")
                                showFolioPicker = true
                                print("Folio picker set to: \(showFolioPicker)")
                            }
                        )
                        .padding(.bottom, 32) // Space between folio and recent clients
                    }
                    
                    // Scrollable recent clients section - takes remaining space
                    ProviderRecentClientsSectionView(
                        clients: viewModel.filteredClients,
                        isLoading: viewModel.isLoading,
                        onClientTap: { client in
                            print("🔍 [ProviderHomeMainContent] Recent client tapped: \(client.fullName)")
                            print("🔍 [ProviderHomeMainContent] Before setting selectedClient: \(viewModel.selectedClient?.fullName ?? "nil")")
                            viewModel.selectedClient = client
                            print("🔍 [ProviderHomeMainContent] After setting selectedClient: \(viewModel.selectedClient?.fullName ?? "nil")")
                        }
                    )
                    .frame(height: geometry.size.height * 0.5) // Take roughly half the screen height
                }
                
                ProviderErrorSection(errorMessage: viewModel.errorMessage)
            }
        }
        .background(PluckrTheme.backgroundGradient)
        .ignoresSafeArea()
        .dynamicTypeSize(.large ... .xxLarge)
        .navigationTitle("Provider Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ProviderHomeToolbar(showAddClient: $showAddClient, showDeleteAccountAlert: $showDeleteAccountAlert)
        }
    }
    
    // MARK: - ProviderAdminDashboardSection
    struct ProviderAdminDashboardSection: View {
        @Binding var showAdminDashboard: Bool
        
        var body: some View {
            Group {
                // TODO: Check if user is admin
                Button(action: {
                    print("Admin dashboard button tapped")
                    showAdminDashboard = true
                    print("Admin dashboard set to: \(showAdminDashboard)")
                }) {
                    Label("Admin Dashboard", systemImage: "gearshape")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(PluckrTheme.card)
                        .cornerRadius(16)
                        .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
            }
        }
    }
    
    // MARK: - ProviderErrorSection
    struct ProviderErrorSection: View {
        let errorMessage: String?
        
        var body: some View {
            Group {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(PluckrTheme.bodyFont())
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - ProviderHomeToolbar
    struct ProviderHomeToolbar: ToolbarContent {
        @Binding var showAddClient: Bool
        @Binding var showDeleteAccountAlert: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Add client button tapped")
                    showAddClient = true
                    print("Add client set to: \(showAddClient)")
                }) {
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
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }
                    Button("Delete Account", role: .destructive) {
                        showDeleteAccountAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
}
