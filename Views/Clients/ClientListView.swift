import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClient: Client? = nil

    var body: some View {
        NavigationStack {
            VStack {
                // ✅ Correct: bind to a @Published property inside the ViewModel
                TextField("Search clients...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if viewModel.isLoading {
                    ProgressView("Loading clients...")
                } else {
                    List(viewModel.filteredClients) { client in
                        Button {
                            selectedClient = client
                        } label: {
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
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("All Clients")

            // ✅ Correct: no $ needed on selectedClient
            .navigationDestination(item: $selectedClient) { client in
                ClientJournalView(client: client)
            }

            // ✅ Correct: no $ on function call
            .onAppear {
                viewModel.fetchClients()
            }
        }
    }
}
