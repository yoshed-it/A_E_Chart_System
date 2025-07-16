import Foundation
import FirebaseFirestore

class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let orgId: String
    
    init(orgId: String = "defaultOrg") {
        self.orgId = orgId
    }

    func fetchClients() {
        isLoading = true
        errorMessage = nil

        db.collection("organizations")
            .document(orgId)
            .collection("clients")
            .order(by: "lastSeenAt", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "Error fetching clients: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.errorMessage = "No clients found."
                        return
                    }

                    self.clients = documents.compactMap { doc in
                        Client(data: doc.data(), id: doc.documentID)
                    }

                    if self.clients.isEmpty {
                        self.errorMessage = "No clients found."
                    }
                }
            }
    }

    func refresh() {
        fetchClients()
    }
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Client Deletion
    
    private let clientRepository = ClientRepository()
    
    func deleteClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        clientRepository.deleteClient(client) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success {
                    // Remove the client from the local array
                    self?.clients.removeAll { $0.id == client.id }
                    PluckrLogger.success("Client deleted successfully")
                } else {
                    self?.errorMessage = "Failed to delete client"
                    PluckrLogger.error("Failed to delete client")
                }
                
                completion(success)
            }
        }
    }
}
