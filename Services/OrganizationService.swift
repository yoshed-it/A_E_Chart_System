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
    
    private init() {}
    
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
        
        // Set as current organization
        self.currentOrganization = organization
        self.userOrganizations.append(userOrg)
        
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
        
        let snapshot = try await db.collection("userOrganizations")
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        var orgs: [UserOrganization] = []
        for doc in snapshot.documents {
            if let userOrg = UserOrganization(data: doc.data(), id: doc.documentID) {
                orgs.append(userOrg)
            }
        }
        
        self.userOrganizations = orgs
        
        // Set first organization as current if none set
        if currentOrganization == nil, let firstOrg = orgs.first {
            currentOrganization = try await fetchOrganization(id: firstOrg.organizationId)
        }
    }
    
    func setCurrentOrganization(_ organization: Organization) {
        self.currentOrganization = organization
    }
    
    func getCurrentOrganizationId() -> String? {
        return currentOrganization?.id
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
        
        self.userOrganizations.append(userOrg)
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
        
        // Migrate clients
        let clientsSnapshot = try await db.collection("clients").getDocuments()
        for doc in clientsSnapshot.documents {
            let clientData = doc.data()
            try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(doc.documentID)
                .setData(clientData)
        }
        
        // Migrate charts (they're already under clients, so we need to move them)
        for doc in clientsSnapshot.documents {
            let chartsSnapshot = try await db.collection("clients")
                .document(doc.documentID)
                .collection("charts")
                .getDocuments()
            
            for chartDoc in chartsSnapshot.documents {
                let chartData = chartDoc.data()
                try await db.collection("organizations")
                    .document(orgId)
                    .collection("clients")
                    .document(doc.documentID)
                    .collection("charts")
                    .document(chartDoc.documentID)
                    .setData(chartData)
            }
        }
        
        // Migrate tags
        let clientTagsSnapshot = try await db.collection("clientTagsLibrary").getDocuments()
        for doc in clientTagsSnapshot.documents {
            let tagData = doc.data()
            try await db.collection("organizations")
                .document(orgId)
                .collection("clientTagsLibrary")
                .document(doc.documentID)
                .setData(tagData)
        }
        
        let chartTagsSnapshot = try await db.collection("chartTagsLibrary").getDocuments()
        for doc in chartTagsSnapshot.documents {
            let tagData = doc.data()
            try await db.collection("organizations")
                .document(orgId)
                .collection("chartTagsLibrary")
                .document(doc.documentID)
                .setData(tagData)
        }
        
        PluckrLogger.success("Data migration completed for organization: \(orgId)")
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