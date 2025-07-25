import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class ClientJournalViewModel: ObservableObject {
    @Published var entries: [ChartEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var clientTags: [Tag] = []
    @Published var availableClientTags: [Tag] = []
    
    let clientId: String
    private var listenerRegistration: ListenerRegistration?
    
    init(clientId: String) {
        self.clientId = clientId
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func loadEntries() async {
        isLoading = true
        errorMessage = nil
        
        // Remove existing listener
        listenerRegistration?.remove()
        
        // Set up real-time listener for chart entries
        let db = Firestore.firestore()
        
        Task {
            guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
                self.errorMessage = "No organization context available"
                self.isLoading = false
                return
            }
            
            let query = db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .order(by: "createdAt", descending: true)
            
            self.listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Failed to load chart entries: \(error.localizedDescription)"
                        self.isLoading = false
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        self.errorMessage = "No data received"
                        self.isLoading = false
                        return
                    }
                    
                    self.entries = snapshot.documents.compactMap { doc in
                        ChartEntry(id: doc.documentID, data: doc.data())
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    func deleteEntry(chartId: String) async {
        isLoading = true
        errorMessage = nil
        await ChartEntryService.deleteEntry(for: clientId, chartId: chartId)
        // No need to manually reload - the listener will handle it
        isLoading = false
    }
    
    // MARK: - Tag Management
    func loadClientTags(client: Client) async {
        // Load client tags from the client object or database
        clientTags = client.clientTags
    }
    func loadAvailableClientTags() async {
        PluckrLogger.info("ClientJournalViewModel: Starting loadAvailableClientTags")
        
        // Get library tags
        let libraryTags = await TagService.shared.getAvailableTags(context: .client)
        PluckrLogger.info("ClientJournalViewModel: Loaded \(libraryTags.count) library tags")
        PluckrLogger.info("ClientJournalViewModel: Current clientTags count: \(clientTags.count)")
        
        // Create a dictionary to track unique tags by label (case-insensitive)
        var uniqueTagsDict: [String: Tag] = [:]
        
        // Add library tags first
        for tag in libraryTags {
            uniqueTagsDict[tag.label.lowercased()] = tag
        }
        
        // Add client's current tags (only if not already present)
        for tag in clientTags {
            if uniqueTagsDict[tag.label.lowercased()] == nil {
                uniqueTagsDict[tag.label.lowercased()] = tag
                PluckrLogger.info("ClientJournalViewModel: Added client tag '\(tag.label)' to available tags")
            } else {
                PluckrLogger.info("ClientJournalViewModel: Skipped duplicate client tag '\(tag.label)'")
            }
        }
        
        // Convert back to array and sort
        let allAvailableTags = Array(uniqueTagsDict.values).sorted { $0.label < $1.label }
        
        availableClientTags = allAvailableTags
        PluckrLogger.info("ClientJournalViewModel: Final availableClientTags count: \(allAvailableTags.count)")
    }
    func saveClientTags(clientId: String, tags: [Tag]) async {
        do {
            try await TagService.shared.updateClientTags(clientId: clientId, tags: tags)
            clientTags = tags
        } catch {
            print("Failed to save client tags: \(error)")
        }
    }
}
