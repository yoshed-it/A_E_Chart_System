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
 - `errorMessage`: String containing any error messages
 */
@MainActor
class ProviderHomeViewModel: ObservableObject {
    @Published var providerName: String = ""
    @Published var clients: [Client] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var recentClients: [Client] = []
    @Published var dailyFolioClients: [Client] = [] // Placeholder for Daily Folio clients
    @Published var currentProvider: Provider? = nil
    @Published var errorMessage: String? = nil

    // MARK: - UI State (for ProviderHomeView)
    @Published var showSnackbar: Bool = false
    @Published var snackbarMessage: String = ""
    @Published var lastFolioAction: FolioAction? = nil
    private var snackbarTimer: Timer? = nil

    @Published var showAddClient: Bool = false
    @Published var showFolioPicker: Bool = false
    @Published var showAdminDashboard: Bool = false
    @Published var showJoinOrganization: Bool = false
    @Published var showCreateOrganization: Bool = false
    @Published var showDeleteAccountAlert: Bool = false
    @Published var showLogin: Bool = false
    @Published var selectedClient: Client? = nil
    @Published var hasOrganization: Bool = false

    enum FolioAction {
        case added(Client)
        case removed(Client)
    }

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

    var isAdmin: Bool {
        currentProvider?.role == "admin"
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
        guard let orgId = OrganizationService.shared.getCurrentOrganizationId() else {
            PluckrLogger.error("No organization context for chart date lookup")
            return nil
        }
        
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

    func loadCurrentProvider() async {
        guard let orgId = OrganizationService.shared.getCurrentOrganizationId(),
              let userId = Auth.auth().currentUser?.uid else {
            self.currentProvider = nil
            return
        }
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("organizations").document(orgId).collection("providers").document(userId).getDocument()
            if let data = doc.data() {
                self.currentProvider = Provider(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: data["role"] as? String ?? "provider",
                    isActive: data["isActive"] as? Bool ?? true
                )
            } else {
                self.currentProvider = nil
            }
        } catch {
            self.currentProvider = nil
        }
    }

    // MARK: - Snackbar Helpers
    func showSnackbarWithTimer(message: String, action: FolioAction? = nil) {
        snackbarTimer?.invalidate()
        snackbarMessage = message
        lastFolioAction = action
        showSnackbar = true
        snackbarTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showSnackbar = false
            }
        }
    }

    func undoLastFolioAction() {
        guard let action = lastFolioAction else { return }
        switch action {
        case .added(let client):
            removeClientFromFolio(client)
            snackbarMessage = "Undid add: \(client.fullName)"
        case .removed(let client):
            addClientToFolio(client)
            snackbarMessage = "Undid remove: \(client.fullName)"
        }
        lastFolioAction = nil
        showSnackbarWithTimer(message: snackbarMessage)
    }

    deinit {
        folioListener?.remove()
        midnightTimer?.invalidate()
    }
}
