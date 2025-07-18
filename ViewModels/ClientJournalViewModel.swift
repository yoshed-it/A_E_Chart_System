import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class ClientJournalViewModel: ObservableObject {
    @Published var entries: [ChartEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
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
}
