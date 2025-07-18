import Foundation
import FirebaseFirestore

struct UserOrganization: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let organizationId: String
    var role: OrganizationRole
    var joinedAt: Date
    var isActive: Bool
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        organizationId: String,
        role: OrganizationRole = .member
    ) {
        self.id = id
        self.userId = userId
        self.organizationId = organizationId
        self.role = role
        self.joinedAt = Date()
        self.isActive = true
    }
    
    init?(data: [String: Any], id: String?) {
        guard let userId = data["userId"] as? String,
              let organizationId = data["organizationId"] as? String,
              let documentId = id, !documentId.isEmpty else {
            return nil
        }
        
        self.id = documentId
        self.userId = userId
        self.organizationId = organizationId
        self.role = OrganizationRole(rawValue: data["role"] as? String ?? "member") ?? .member
        self.joinedAt = (data["joinedAt"] as? Timestamp)?.dateValue() ?? Date()
        self.isActive = data["isActive"] as? Bool ?? true
    }
    
    func toDict() -> [String: Any] {
        return [
            "userId": userId,
            "organizationId": organizationId,
            "role": role.rawValue,
            "joinedAt": Timestamp(date: joinedAt),
            "isActive": isActive
        ]
    }
}

enum OrganizationRole: String, CaseIterable, Codable {
    case owner = "owner"
    case admin = "admin"
    case member = "member"
    case viewer = "viewer"
    
    var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .admin: return "Administrator"
        case .member: return "Member"
        case .viewer: return "Viewer"
        }
    }
    
    var canManageUsers: Bool {
        switch self {
        case .owner, .admin: return true
        case .member, .viewer: return false
        }
    }
    
    var canManageOrganization: Bool {
        switch self {
        case .owner: return true
        case .admin, .member, .viewer: return false
        }
    }
    
    var canEditData: Bool {
        switch self {
        case .owner, .admin, .member: return true
        case .viewer: return false
        }
    }
} 