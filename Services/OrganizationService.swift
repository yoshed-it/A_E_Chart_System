import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OrganizationService: ObservableObject {
    static let shared = OrganizationService()
    private let db = Firestore.firestore()
    
    @Published var currentOrganization: Organization?
    @Published var userOrganizations: [UserOrganization] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let orgIdKey = "currentOrganizationId"
    
    private init() {
        // Initialize when service is created
        Task {
            await initializeIfAuthenticated()
        }
    }
    
    // MARK: - Initialization
    
    func initializeIfAuthenticated() async {
        guard let user = Auth.auth().currentUser else { 
            PluckrLogger.info("No authenticated user for organization service initialization")
            return 
        }
        
        PluckrLogger.info("Initializing organization service for user: \(user.email ?? "Unknown")")
        
        do {
            try await fetchUserOrganizations()
            PluckrLogger.info("Organization service initialized. Found \(self.userOrganizations.count) organizations")
        } catch {
            PluckrLogger.error("Failed to initialize organization service: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Organization Management
    
    func createOrganization(name: String, description: String? = nil) async throws -> Organization {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw OrganizationError.userNotAuthenticated
        }
        
        let organization = Organization(
            name: name,
            description: description,
            createdBy: userId
        )
        
        try await db.collection("organizations")
            .document(organization.id)
            .setData(organization.toDict())
        
        // Add user as owner
        let userOrg = UserOrganization(
            userId: userId,
            organizationId: organization.id,
            role: .owner
        )
        
        try await db.collection("userOrganizations")
            .document(userOrg.id)
            .setData(userOrg.toDict())
        
        // Create provider document for the organization creator
        guard let user = Auth.auth().currentUser else {
            throw OrganizationError.userNotAuthenticated
        }
        
        let providerData: [String: Any] = [
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "isActive": true,
            "role": "admin"
        ]
        
        try await db.collection("organizations")
            .document(organization.id)
            .collection("providers")
            .document(user.uid)
            .setData(providerData)
        
        // Set as current organization
        self.currentOrganization = organization
        self.userOrganizations.append(userOrg)
        self.setCurrentOrganizationId(organization.id)
        
        PluckrLogger.success("Created organization: \(name)")
        return organization
    }
    
    func fetchOrganization(id: String) async throws -> Organization? {
        let doc = try await db.collection("organizations")
            .document(id)
            .getDocument()
        
        guard let data = doc.data() else {
            return nil
        }
        
        return Organization(data: data, id: doc.documentID)
    }
    
    func fetchUserOrganizations() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw OrganizationError.userNotAuthenticated
        }
        
        PluckrLogger.info("Fetching user organizations for user: \(userId)")
        
        let snapshot = try await db.collection("userOrganizations")
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        PluckrLogger.info("Found \(snapshot.documents.count) user organization documents")
        
        var orgs: [UserOrganization] = []
        for doc in snapshot.documents {
            if let userOrg = UserOrganization(data: doc.data(), id: doc.documentID) {
                orgs.append(userOrg)
                PluckrLogger.info("Added user organization: \(userOrg.organizationId) with role: \(userOrg.role.rawValue)")
            } else {
                PluckrLogger.error("Failed to parse user organization document: \(doc.documentID)")
            }
        }
        
        self.userOrganizations = orgs
        PluckrLogger.info("Set userOrganizations array with \(orgs.count) organizations")
        
        // Set first organization as current if none set
        if currentOrganization == nil, let firstOrg = orgs.first {
            currentOrganization = try await fetchOrganization(id: firstOrg.organizationId)
            self.setCurrentOrganizationId(firstOrg.organizationId)
            PluckrLogger.info("Set current organization: \(firstOrg.organizationId)")
        }
    }
    
    func setCurrentOrganization(_ organization: Organization) {
        self.currentOrganization = organization
    }
    
    func setCurrentOrganizationId(_ orgId: String) {
        UserDefaults.standard.set(orgId, forKey: orgIdKey)
        // Update currentOrganization if you want to keep it in sync
        Task {
            if let org = try? await fetchOrganization(id: orgId) {
                await MainActor.run { self.currentOrganization = org }
            }
        }
    }
    
    func setCurrentOrganization(_ organization: Organization) async {
        await MainActor.run {
            self.currentOrganization = organization
        }
    }

    func getCurrentOrganizationId() -> String? {
        return UserDefaults.standard.string(forKey: orgIdKey)
    }
    
    func joinOrganization(inviteCode: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw OrganizationError.userNotAuthenticated
        }
        
        // For now, we'll use a simple approach where invite codes are organization IDs
        // In a real app, you'd have a separate invite system
        guard let organization = try await fetchOrganization(id: inviteCode) else {
            throw OrganizationError.organizationNotFound
        }
        
        let userOrg = UserOrganization(
            userId: userId,
            organizationId: organization.id,
            role: .member
        )
        
        try await db.collection("userOrganizations")
            .document(userOrg.id)
            .setData(userOrg.toDict())
        
        // Create provider document for the user joining the organization
        guard let user = Auth.auth().currentUser else {
            throw OrganizationError.userNotAuthenticated
        }
        
        let providerData: [String: Any] = [
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "isActive": true,
            "role": "provider"
        ]
        
        try await db.collection("organizations")
            .document(organization.id)
            .collection("providers")
            .document(user.uid)
            .setData(providerData)
        
        // Add to local arrays and set as current organization
        self.userOrganizations.append(userOrg)
        self.currentOrganization = organization
        self.setCurrentOrganizationId(organization.id)
        
        PluckrLogger.success("Joined organization: \(organization.name)")
    }
    
    func leaveOrganization(_ organization: Organization) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw OrganizationError.userNotAuthenticated
        }
        
        // Find the user organization relationship
        let snapshot = try await db.collection("userOrganizations")
            .whereField("userId", isEqualTo: userId)
            .whereField("organizationId", isEqualTo: organization.id)
            .getDocuments()
        
        guard let doc = snapshot.documents.first else {
            throw OrganizationError.userNotInOrganization
        }
        
        // Mark as inactive instead of deleting
        try await doc.reference.updateData([
            "isActive": false,
            "leftAt": Timestamp(date: Date())
        ])
        
        // Remove from local arrays
        self.userOrganizations.removeAll { $0.organizationId == organization.id }
        if self.currentOrganization?.id == organization.id {
            if let firstOrg = self.userOrganizations.first {
                self.currentOrganization = try? await fetchOrganization(id: firstOrg.organizationId)
            } else {
                self.currentOrganization = nil
            }
        }
        
        PluckrLogger.success("Left organization: \(organization.name)")
    }
    
    // MARK: - Data Migration
    
    func migrateExistingData() async throws {
        guard let orgId = getCurrentOrganizationId() else {
            throw OrganizationError.noCurrentOrganization
        }
        
        PluckrLogger.info("Starting data migration to organization: \(orgId)")
        
        // Use a batch write for atomic migration
        let batch = db.batch()
        var migratedCount = 0
        
        // Migrate clients
        let clientsSnapshot = try await db.collection("clients").getDocuments()
        PluckrLogger.info("Found \(clientsSnapshot.documents.count) clients to migrate")
        
        for doc in clientsSnapshot.documents {
            let clientData = doc.data()
            let newClientRef = db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(doc.documentID)
            batch.setData(clientData, forDocument: newClientRef)
            migratedCount += 1
        }
        
        // Migrate charts
        for doc in clientsSnapshot.documents {
            let chartsSnapshot = try await db.collection("clients")
                .document(doc.documentID)
                .collection("charts")
                .getDocuments()
            
            PluckrLogger.info("Found \(chartsSnapshot.documents.count) charts for client \(doc.documentID)")
            
            for chartDoc in chartsSnapshot.documents {
                let chartData = chartDoc.data()
                let newChartRef = db.collection("organizations")
                    .document(orgId)
                    .collection("clients")
                    .document(doc.documentID)
                    .collection("charts")
                    .document(chartDoc.documentID)
                batch.setData(chartData, forDocument: newChartRef)
                migratedCount += 1
            }
        }
        
        // Migrate tags
        let clientTagsSnapshot = try await db.collection("clientTagsLibrary").getDocuments()
        PluckrLogger.info("Found \(clientTagsSnapshot.documents.count) client tags to migrate")
        
        for doc in clientTagsSnapshot.documents {
            let tagData = doc.data()
            let newTagRef = db.collection("organizations")
                .document(orgId)
                .collection("clientTagsLibrary")
                .document(doc.documentID)
            batch.setData(tagData, forDocument: newTagRef)
            migratedCount += 1
        }
        
        let chartTagsSnapshot = try await db.collection("chartTagsLibrary").getDocuments()
        PluckrLogger.info("Found \(chartTagsSnapshot.documents.count) chart tags to migrate")
        
        for doc in chartTagsSnapshot.documents {
            let tagData = doc.data()
            let newTagRef = db.collection("organizations")
                .document(orgId)
                .collection("chartTagsLibrary")
                .document(doc.documentID)
            batch.setData(tagData, forDocument: newTagRef)
            migratedCount += 1
        }
        
        // Commit the batch
        try await batch.commit()
        PluckrLogger.success("Data migration completed for organization: \(orgId) - migrated \(migratedCount) documents")
        
        // Optionally, clean up old data after successful migration
        // await cleanupOldData()
    }
    
    private func cleanupOldData() async {
        PluckrLogger.info("Starting cleanup of old data structure")
        
        // Delete old clients collection
        let clientsSnapshot = try? await db.collection("clients").getDocuments()
        if let clients = clientsSnapshot?.documents {
            for doc in clients {
                try? await doc.reference.delete()
            }
            PluckrLogger.info("Deleted \(clients.count) old client documents")
        }
        
        // Delete old tag libraries
        let clientTagsSnapshot = try? await db.collection("clientTagsLibrary").getDocuments()
        if let clientTags = clientTagsSnapshot?.documents {
            for doc in clientTags {
                try? await doc.reference.delete()
            }
            PluckrLogger.info("Deleted \(clientTags.count) old client tag documents")
        }
        
        let chartTagsSnapshot = try? await db.collection("chartTagsLibrary").getDocuments()
        if let chartTags = chartTagsSnapshot?.documents {
            for doc in chartTags {
                try? await doc.reference.delete()
            }
            PluckrLogger.info("Deleted \(chartTags.count) old chart tag documents")
        }
        
        PluckrLogger.success("Old data cleanup completed")
    }
}

// MARK: - Organization Errors
enum OrganizationError: LocalizedError {
    case userNotAuthenticated
    case organizationNotFound
    case userNotInOrganization
    case noCurrentOrganization
    case invalidInviteCode
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .organizationNotFound:
            return "Organization not found"
        case .userNotInOrganization:
            return "User is not a member of this organization"
        case .noCurrentOrganization:
            return "No current organization selected"
        case .invalidInviteCode:
            return "Invalid invite code"
        }
    }
} 