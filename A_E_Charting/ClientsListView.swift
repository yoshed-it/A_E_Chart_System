import SwiftUI
import FirebaseFirestore

struct ClientsListView: View {
    @State private var clients: [Client] = []
    @State private var searchText = ""
    @State private var isLoading = true

    var body: some View {
        List {
            if filteredClients.isEmpty {
                Text("No clients found.")
                    .foregroundColor(.secondary)
            } else {
                Section("All Clients") {
                    ForEach(filteredClients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            VStack(alignment: .leading) {
                                Text(client.name)
                                    .font(.headline)
                                Text(client.pronouns)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Database")
        .searchable(text: $searchText)
        .onAppear(perform: loadClients)
    }

    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func loadClients() {
        let db = Firestore.firestore()
        db.collection("clients")
            .order(by: "name")
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
