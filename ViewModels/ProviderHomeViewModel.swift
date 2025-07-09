import Foundation
import Combine

@MainActor
class ProviderHomeViewModel: ObservableObject {
    @Published var providerName: String = ""
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true

    private let clientRepository = ClientRepository()

    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter {
                $0.fullName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func startObservingClients() {
        isLoading = true
        clientRepository.observeClients { [weak self] updatedClients in
            Task { @MainActor in
                self?.clients = updatedClients
                self?.isLoading = false
            }
        }
    }

    func stopObservingClients() {
        clientRepository.stopObservingClients()
    }

    func fetchProviderName() {
        clientRepository.fetchProviderName { [weak self] name in
            Task { @MainActor in
                self?.providerName = name
            }
        }
    }
}
