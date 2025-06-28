import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Client: Identifiable, Equatable {
    var id: String
    var name: String
    var pronouns: String
    var createdAt: Date?
    var createdByName: String
    var lastSeenAt: Date?
}

struct ProviderHomeView: View {
    @State private var providerName: String = ""
    @State private var clients: [Client] = []
    @State private var searchText: String = ""
    @State private var showAddClient = false
    @State private var isLoading = true
    @State private var selectedClient: Client? = nil

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome, \(providerName)")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Search clients...", text: $searchText)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Text("Recent Clients")
                    .font(.headline)
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
                if isLoading {
                    ProgressView("Loading clients...")
                } else {
                    List {
                        ForEach(filteredClients) { client in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(client.name)
                                        .font(.headline)
                                    Text(client.pronouns)
                                        .font(.subheadline)
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
                                // TODO: Navigate to ClientDetailView
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
            .sheet(isPresented: $showAddClient, onDismiss: loadClients) {
                AddClientView(onClientAdded: loadClients)
            }
            .sheet(item: $selectedClient) { client in
                ClientInfoModal(client: client)
            }
            .onAppear {
                fetchProviderName()
                loadClients()
            }
        }
    }

    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchProviderName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("providers").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                providerName = name
                print("✅ Provider name loaded: \(name)")
            }
        }
    }

    func loadClients() {
        let db = Firestore.firestore()
        db.collection("clients")
            .order(by: "lastSeenAt", descending: true)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.clients = docs.map { doc in
                        let data = doc.data()
                        return Client(
                            id: doc.documentID,
                            name: data["name"] as? String ?? "Unknown",
                            pronouns: data["pronouns"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                            createdByName: data["createdByName"] as? String ?? "",
                            lastSeenAt: (data["lastSeenAt"] as? Timestamp)?.dateValue()
                        )
                    }
                }
                isLoading = false
            }
    }
}
