import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClient: Client? = nil
    @State private var clientToDelete: Client? = nil
    @State private var showDeleteAlert = false

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
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                clientToDelete = client
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("All Clients")

            // ✅ Correct: no $ needed on selectedClient
            .navigationDestination(item: $selectedClient) { client in
                // Use a binding to selectedClient to allow pop on delete
                ClientJournalView(client: client, isActive: Binding(
                    get: { selectedClient != nil },
                    set: { newValue in if !newValue { selectedClient = nil } }
                ))
            }

            // ✅ Correct: no $ on function call
            .onAppear {
                viewModel.fetchClients()
            }
            .alert("Delete Client?", isPresented: $showDeleteAlert, presenting: clientToDelete) { client in
                Button("Delete", role: .destructive) {
                    viewModel.deleteClient(client) { success in
                        if success {
                            // Client was deleted successfully
                            PluckrLogger.info("Client \(client.fullName) deleted successfully")
                        } else {
                            // Handle error - could show a toast or alert
                            PluckrLogger.error("Failed to delete client \(client.fullName)")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { client in
                Text("Are you sure you want to delete \(client.fullName)? This will permanently delete the client and all their chart entries. This action cannot be undone.")
            }
        }
    }
}
