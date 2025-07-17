import Foundation
import Combine
import FirebaseAuth // Added for Auth.auth()
import FirebaseFirestore

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
    @Published var recentClients: [Client] = []
    @Published var dailyFolioClients: [Client] = [] // Placeholder for Daily Folio clients

    private let clientRepository = ClientRepository()
    private let db = Firestore.firestore()
    private var folioListener: ListenerRegistration?

    /// Computed property that filters clients based on search text
    /// - Returns: Array of clients matching the search criteria
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return recentClients
        } else {
            return recentClients.filter {
                $0.fullName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    /**
     *Starts real-time observation of clients from Firestore*
     
     This method sets up a Firestore listener to receive real-time updates
     when client data changes. The listener automatically updates the
     `clients` published property and shows recent clients based on chart activity.
     
     - Note: Sets `isLoading` to true initially
     - Note: Automatically handles listener cleanup when called multiple times
     - Note: Recent clients are determined by the provider's chart activity
     */
    func startObservingClients() {
        isLoading = true
        clientRepository.observeClients { [weak self] updatedClients in
            Task { @MainActor in
                guard let self = self else { return }
                
                // Get recent clients based on chart activity
                await self.loadRecentClientsFromCharts(allClients: updatedClients)
                self.isLoading = false
            }
        }
    }
    
    /**
     *Loads recent clients based on the provider's chart activity*
     
     This method finds the last 8 clients for whom the current provider
     has created or edited charts, sorted by most recent chart activity.
     
     - Parameter allClients: Array of all available clients
     */
    private func loadRecentClientsFromCharts(allClients: [Client]) async {
        guard let providerId = Auth.auth().currentUser?.uid else {
            self.recentClients = Array(allClients.prefix(8))
            return
        }
        
        var clientChartActivity: [(Client, Date)] = []
        
        // Check each client for chart activity by this provider
        for client in allClients {
            if let mostRecentChartDate = await getMostRecentChartDate(for: client.id, by: providerId) {
                clientChartActivity.append((client, mostRecentChartDate))
            }
        }
        
        // Sort by most recent chart activity (newest first)
        let sortedClients = clientChartActivity
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
        
        // Take the first 8 most recently charted clients
        self.recentClients = Array(sortedClients.prefix(8))
    }
    
    /**
     *Gets the most recent chart date for a client by the specified provider*
     
     - Parameter clientId: The client's ID
     - Parameter providerId: The provider's ID
     - Returns: The date of the most recent chart, or nil if no charts exist
     */
    private func getMostRecentChartDate(for clientId: String, by providerId: String) async -> Date? {
        // Try organization-based structure first
        if let orgId = OrganizationService.shared.getCurrentOrganizationId() {
            do {
                let snapshot = try await db.collection("organizations")
                    .document(orgId)
                    .collection("clients")
                    .document(clientId)
                    .collection("charts")
                    .whereField("createdBy", isEqualTo: providerId)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 1)
                    .getDocuments()
                
                if let doc = snapshot.documents.first,
                   let timestamp = doc.data()["createdAt"] as? Timestamp {
                    return timestamp.dateValue()
                }
            } catch {
                PluckrLogger.error("Failed to get chart date from org structure: \(error.localizedDescription)")
            }
        }
        
        // Fallback to root-level structure
        do {
            let snapshot = try await db.collection("clients")
                .document(clientId)
                .collection("charts")
                .whereField("createdBy", isEqualTo: providerId)
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            if let doc = snapshot.documents.first,
               let timestamp = doc.data()["createdAt"] as? Timestamp {
                return timestamp.dateValue()
            }
        } catch {
            PluckrLogger.error("Failed to get chart date from root structure: \(error.localizedDescription)")
        }
        
        return nil
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

    private func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func loadDailyFolio() {
        guard let providerId = Auth.auth().currentUser?.uid else { return }
        folioListener?.remove()
        let dateKey = todayKey()
        folioListener = db.collection("providers").document(providerId).collection("dailyFolio").document(dateKey).collection("clients").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let docs = snapshot?.documents else {
                self.dailyFolioClients = []
                return
            }
            let clients = docs.compactMap { doc in
                let data = doc.data()
                let clientId = data["clientId"] as? String
                let clientData = data["clientData"] as? [String: Any]
                if let clientId = clientId, let clientData = clientData {
                    return Client(data: clientData, id: clientId)
                }
                return nil
            }
            self.dailyFolioClients = clients
        }
    }

    func addClientToFolio(_ client: Client) {
        guard let providerId = Auth.auth().currentUser?.uid else { return }
        let dateKey = todayKey()
        let docRef = db.collection("providers").document(providerId).collection("dailyFolio").document(dateKey).collection("clients").document(client.id)
        docRef.setData([
            "clientId": client.id,
            "clientData": client.toDict()
        ])
    }

    func removeClientFromFolio(_ client: Client) {
        guard let providerId = Auth.auth().currentUser?.uid else { return }
        let dateKey = todayKey()
        let docRef = db.collection("providers").document(providerId).collection("dailyFolio").document(dateKey).collection("clients").document(client.id)
        docRef.delete()
    }

    // Optionally, add a timer to reload at midnight
    private var midnightTimer: Timer? = nil
    func startMidnightReset() {
        midnightTimer?.invalidate()
        let now = Date()
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour:0, minute:0, second:1), matchingPolicy: .nextTime) ?? now.addingTimeInterval(86400)
        let interval = nextMidnight.timeIntervalSince(now)
        midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.loadDailyFolio()
                self?.startMidnightReset()
            }
        }
    }
    deinit {
        folioListener?.remove()
        midnightTimer?.invalidate()
    }
}
