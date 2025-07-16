import SwiftUI

struct ProviderHomeView: View {
    @StateObject private var viewModel = ProviderHomeViewModel()
    @State private var showAddClient = false
    @State private var selectedClient: Client? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PluckrTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: PluckrTheme.spacing * 2) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                        Text("Welcome, \(viewModel.providerName)")
                            .font(.journalTitle)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("Your clinical journal awaits")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    .padding(.horizontal, PluckrTheme.padding)
                    .padding(.top, PluckrTheme.padding)

                    // Search Bar
                    TextField("Search clients...", text: $viewModel.searchText)
                        .textFieldStyle(PluckrTextFieldStyle())
                        .padding(.horizontal, PluckrTheme.padding)

                    // Recent Clients Section
                    VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                        HStack {
                            Text("Recent Clients")
                                .font(.journalSubtitle)
                                .foregroundColor(PluckrTheme.primaryColor)
                            Spacer()
                            NavigationLink(destination: ClientsListView()) {
                                Text("See All")
                                    .font(.journalCaption)
                                    .foregroundColor(PluckrTheme.accentColor)
                            }
                        }
                        .padding(.horizontal, PluckrTheme.padding)

                        if viewModel.isLoading {
                            LoadingView(message: "Loading clients...")
                                .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
                                .padding(.top, 60)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: PluckrTheme.spacing) {
                                    ForEach(viewModel.filteredClients) { client in
                                        ClientCardView(client: client) {
                                            selectedClient = client
                                        }
                                    }
                                }
                                .padding(.horizontal, PluckrTheme.padding)
                            }
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Provider Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button(action: { showAddClient = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PluckrTheme.primaryColor)
                        .font(.title2)
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
            }
            .onDisappear {
                viewModel.stopObservingClients()
            }
        }
    }
}
