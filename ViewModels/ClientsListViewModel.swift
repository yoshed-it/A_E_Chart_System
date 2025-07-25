import Foundation
import FirebaseFirestore

class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSnackbar: Bool = false
    @Published var snackbarMessage: String = ""
    private var snackbarTimer: Timer? = nil
    private(set) var lastFolioAction: FolioAction? = nil
    // Navigation/modal state
    @Published var selectedClient: Client? = nil
    @Published var clientToDelete: Client? = nil
    @Published var showDeleteAlert: Bool = false
    enum FolioAction {
        case added(Client)
        case removed(Client)
    }
    var canUndo: Bool { lastFolioAction != nil }

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
                    self?.showSnackbar(message: "Client deleted: \(client.fullName)", action: .removed(client))
                } else {
                    self?.errorMessage = "Failed to delete client"
                    PluckrLogger.error("Failed to delete client")
                    self?.showSnackbar(message: "Failed to delete client", action: nil)
                }
                
                completion(success)
            }
        }
    }

    func showSnackbar(message: String, action: FolioAction?) {
        snackbarTimer?.invalidate()
        snackbarMessage = message
        lastFolioAction = action
        showSnackbar = true
        snackbarTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showSnackbar = false
                self?.lastFolioAction = nil
            }
        }
    }

    func undoLastFolioAction() {
        guard let action = lastFolioAction else { return }
        switch action {
        case .added(let client):
            // This should call a delegate or closure to update the folio in the ProviderHomeViewModel
            // For now, just hide the snackbar
            snackbarMessage = "Undid add: \(client.fullName)"
        case .removed(let client):
            snackbarMessage = "Undid remove: \(client.fullName)"
        }
        lastFolioAction = nil
        showSnackbarWithTimer()
    }

    private func showSnackbarWithTimer() {
        snackbarTimer?.invalidate()
        showSnackbar = true
        snackbarTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showSnackbar = false
            }
        }
    }
}
