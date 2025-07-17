import Foundation
import FirebaseFirestore
import FirebaseAuth

/**
 *Service for managing probe data in Firestore*
 
 This service handles all probe-related database operations including
 fetching predefined and custom probes, saving new custom probes,
 and managing probe availability.
 
 ## Features
 - Fetch all probes (predefined + custom)
 - Save custom probes
 - Update probe status
 - Initialize predefined probes in database
 */
@MainActor
class ProbeService: ObservableObject {
    static let shared = ProbeService()
    private let db = Firestore.firestore()
    
    @Published var probes: [Probe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Fetch Probes
    
    /**
     *Fetches all probes from the database*
     
     This method retrieves both predefined and custom probes from Firestore.
     If no probes exist, it initializes the predefined probes.
     
     - Parameter completion: Optional completion handler called when fetch completes
     */
    func fetchProbes(completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let probes = try await fetchProbesFromDatabase()
                
                if probes.isEmpty {
                    // Initialize predefined probes if none exist
                    await initializePredefinedProbes()
                    self.probes = Probe.predefinedProbes
                } else {
                    self.probes = probes
                }
                
                isLoading = false
                completion?()
                
            } catch {
                errorMessage = "Failed to fetch probes: \(error.localizedDescription)"
                isLoading = false
                completion?()
            }
        }
    }
    
    /**
     *Fetches probes from Firestore database*
     
     - Returns: Array of probes from the database
     - Throws: Error if database operation fails
     */
    private func fetchProbesFromDatabase() async throws -> [Probe] {
        // Try organization-based structure first
        if let orgId = await OrganizationService.shared.getCurrentOrganizationId() {
            let snapshot = try await db.collection("organizations")
                .document(orgId)
                .collection("probes")
                .order(by: "name")
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                Probe(data: doc.data(), id: doc.documentID)
            }
        } else {
            // Fallback to root-level structure
            let snapshot = try await db.collection("probes")
                .order(by: "name")
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                Probe(data: doc.data(), id: doc.documentID)
            }
        }
    }
    
    // MARK: - Initialize Predefined Probes
    
    /**
     *Initializes predefined probes in the database*
     
     This method creates the default probe configurations in Firestore
     if they don't already exist.
     */
    private func initializePredefinedProbes() async {
        let predefinedProbes = Probe.predefinedProbes
        
        for probe in predefinedProbes {
            do {
                // Ensure the probe is marked as active when initializing
                var activeProbe = probe
                activeProbe.isActive = true
                try await saveProbe(activeProbe)
                PluckrLogger.info("Initialized predefined probe: \(probe.name)")
            } catch {
                PluckrLogger.error("Failed to initialize probe \(probe.name): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Save Custom Probe
    
    /**
     *Saves a custom probe to the database*
     
     - Parameter probe: The probe to save
     - Throws: Error if save operation fails
     */
    func saveCustomProbe(_ probe: Probe) async throws {
        guard probe.isCustom else {
            throw ProbeError.invalidProbeType
        }
        
        try await saveProbe(probe)
        
        // Refresh the probes list
        await fetchProbes()
        
        PluckrLogger.success("Custom probe saved: \(probe.name)")
    }
    
    /**
     *Saves a probe to the database*
     
     - Parameter probe: The probe to save
     - Throws: Error if save operation fails
     */
    private func saveProbe(_ probe: Probe) async throws {
        let probeData = probe.toDict()
        
        // Try organization-based structure first
        if let orgId = await OrganizationService.shared.getCurrentOrganizationId() {
            try await db.collection("organizations")
                .document(orgId)
                .collection("probes")
                .document(probe.id)
                .setData(probeData, merge: true)
        } else {
            // Fallback to root-level structure
            try await db.collection("probes")
                .document(probe.id)
                .setData(probeData, merge: true)
        }
    }
    
    // MARK: - Update Probe Status
    
    /**
     *Updates the active status of a probe*
     
     - Parameter probeId: ID of the probe to update
     - Parameter isActive: New active status
     - Throws: Error if update operation fails
     */
    func updateProbeStatus(probeId: String, isActive: Bool) async throws {
        // Try organization-based structure first
        if let orgId = await OrganizationService.shared.getCurrentOrganizationId() {
            try await db.collection("organizations")
                .document(orgId)
                .collection("probes")
                .document(probeId)
                .updateData(["isActive": isActive])
        } else {
            // Fallback to root-level structure
            try await db.collection("probes")
                .document(probeId)
                .updateData(["isActive": isActive])
        }
        
        // Update local probes array
        if let index = probes.firstIndex(where: { $0.id == probeId }) {
            probes[index].isActive = isActive
        }
        
        PluckrLogger.info("Updated probe status: \(probeId) -> \(isActive)")
    }
    
    // MARK: - Helper Methods
    
    /**
     *Gets probes filtered by type*
     
     - Parameter type: The probe type to filter by
     - Returns: Array of probes of the specified type
     */
    func getProbes(for type: Probe.ProbeType) -> [Probe] {
        return probes.filter { $0.type == type && $0.isActive }
    }
    
    /**
     *Gets all active probes*
     
     - Returns: Array of all active probes
     */
    func getActiveProbes() -> [Probe] {
        return probes.filter { $0.isActive }
    }
    
    /**
     *Gets custom probes created by the current user*
     
     - Returns: Array of custom probes created by the current user
     */
    func getCustomProbes() -> [Probe] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        return probes.filter { $0.isCustom && $0.createdBy == currentUserId && $0.isActive }
    }
}

// MARK: - Probe Errors

enum ProbeError: LocalizedError {
    case invalidProbeType
    case probeNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidProbeType:
            return "Invalid probe type"
        case .probeNotFound:
            return "Probe not found"
        case .saveFailed:
            return "Failed to save probe"
        }
    }
} 