import Foundation
import Firebase

struct Client: Identifiable, Hashable, Codable, Equatable {
    var id: String            // Firestore Document ID
    var firstName: String
    var lastName: String
    var phone: String?
    var email: String?
    var pronouns: String?
    var createdBy: String?
    var createdByName: String?
    var lastSeenAt: Date?
    var createdAt: Date?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    init(
        id: String? = nil,
        firstName: String = "",
        lastName: String = "",
        phone: String? = nil,
        email: String? = nil,
        pronouns: String? = nil,
        createdBy: String? = nil,
        createdByName: String? = nil,
        lastSeenAt: Date? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id ?? ""
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.pronouns = pronouns
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.lastSeenAt = lastSeenAt
        self.createdAt = createdAt
    }

    init?(data: [String: Any], id: String?) {
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String else {
            return nil
        }

        self.id = id ?? ""
        self.firstName = firstName
        self.lastName = lastName
        self.phone = data["phone"] as? String
        self.email = data["email"] as? String
        self.pronouns = data["pronouns"] as? String
        self.createdBy = data["createdBy"] as? String
        self.createdByName = data["createdByName"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        self.lastSeenAt = (data["lastSeenAt"] as? Timestamp)?.dateValue()
    }
    
}
