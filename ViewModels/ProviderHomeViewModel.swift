import Foundation
import Combine

/**
 *Manages the provider home screen state and data*
 
 This ViewModel handles the main provider dashboard, including client list
 management, search functionality, and provider information display.
 
 ## Features
 - Real-time client list updates via Firestore listeners
 - Client search and filtering
 - Provider name fetching
 - Loading state management
 
 ## Usage
 ```swift
 @StateObject private var viewModel = ProviderHomeViewModel()
 
 // Start observing clients
 viewModel.startObservingClients()
 
 // Access filtered clients
 let clients = viewModel.filteredClients
 ```
 
 ## Published Properties
 - `providerName`: Display name of the current provider
 - `clients`: Array of all clients
 - `searchText`: Current search query
 - `isLoading`: Boolean indicating if data is being loaded
 */
@MainActor
class ProviderHomeViewModel: ObservableObject {
    @Published var providerName: String = ""
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true

    private let clientRepository = ClientRepository()

    /// Computed property that filters clients based on search text
    /// - Returns: Array of clients matching the search criteria
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter {
                $0.fullName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    /**
     *Starts real-time observation of clients from Firestore*
     
     This method sets up a Firestore listener to receive real-time updates
     when client data changes. The listener automatically updates the
     `clients` published property.
     
     - Note: Sets `isLoading` to true initially
     - Note: Automatically handles listener cleanup when called multiple times
     */
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
