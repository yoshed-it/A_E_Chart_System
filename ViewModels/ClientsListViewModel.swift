import Foundation
import FirebaseFirestore

class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let clientRepository: ClientRepository
    
    init(clientRepository: ClientRepository = AppEnvironment.live.clientRepository) {
        self.clientRepository = clientRepository
    }

    func fetchClients() {
        isLoading = true
        errorMessage = nil
        clientRepository.fetchClients { [weak self] clients in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.clients = clients
                if clients.isEmpty {
                    self?.errorMessage = "No clients found."
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
