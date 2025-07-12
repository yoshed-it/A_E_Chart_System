import SwiftUI

struct ProviderHomeView: View {
    @StateObject private var viewModel = ProviderHomeViewModel()
    @State private var showAddClient = false
    @State private var selectedClient: Client? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome, \(viewModel.providerName)")
                    .font(.largeTitle)
                    .bold()

                TextField("Search clients...", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                HStack {
                    Text("Recent Clients")
                        .font(.headline)
                    Spacer()
                    NavigationLink(destination: ClientsListView()) {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }

                if viewModel.isLoading {
                    ProgressView("Loading clients...")
                } else {
                    List {
                        ForEach(viewModel.filteredClients) { client in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(client.fullName)
                                        .font(.headline)

                                    if let pronouns = client.pronouns, !pronouns.isEmpty {
                                        Text(pronouns)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    selectedClient = client
                                }) {
                                    Image(systemName: "info.circle")
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedClient = client
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Provider Home")
            .toolbar {
                Button(action: { showAddClient = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView(
                    onClientAdded: {}, // No longer needed thanks to live updates
                    providerDisplayName: viewModel.providerName
                )
            }
            .navigationDestination(item: $selectedClient) { client in
                ClientJournalView(client: client)
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
