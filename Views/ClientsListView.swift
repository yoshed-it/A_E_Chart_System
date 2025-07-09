import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var searchText = ""
    @State private var selectedClient: Client?

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading clients...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if filteredClients.isEmpty {
                Text("No clients found.")
                    .foregroundColor(.secondary)
            } else {
                Section("All Clients") {
                    ForEach(filteredClients) { client in
                        Button {
                            selectedClient = client
                        } label: {
                            VStack(alignment: .leading) {
                                Text(client.fullName)
                                    .font(.headline)
                                if let pronouns = client.pronouns {
                                    Text(pronouns)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Database")
        .searchable(text: $searchText)
        .sheet(item: $selectedClient) { client in
            ClientDetailView(client: client, onUpdated: viewModel.refresh)
        }
        .onAppear {
            viewModel.refresh()
        }
    }

    var filteredClients: [Client] {
        if searchText.isEmpty {
            return viewModel.clients
        } else {
            return viewModel.clients.filter {
                $0.fullName.lowercased().contains(searchText.lowercased()) ||
                ($0.pronouns?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
}
