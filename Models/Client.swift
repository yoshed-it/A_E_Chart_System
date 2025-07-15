import Foundation
import Firebase

/**
 *Represents a client in the Pluckr system*
 
 This struct contains all the essential information about a client,
 including their personal details and metadata about their records.
 
 ## Properties
 - `id`: Unique Firestore document identifier
 - `firstName`: Client's first name
 - `lastName`: Client's last name
 - `phone`: Optional phone number
 - `email`: Optional email address
 - `pronouns`: Optional preferred pronouns
 - `createdBy`: ID of the provider who created this client
 - `createdByName`: Display name of the creating provider
 - `lastSeenAt`: Date of the client's last visit
 - `createdAt`: Date when the client record was created
 
 ## Usage
 ```swift
 let client = Client(
     id: "client123",
     firstName: "John",
     lastName: "Doe",
     phone: "+1234567890"
 )
 ```
 
 ## Firestore Integration
 This struct can be initialized from Firestore data using the `init?(data:id:)` method
 and converted back to a dictionary using the `toDict()` method.
 */
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

    /// Computed property that returns the client's full name
    /// - Returns: A string combining first and last name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /**
     *Creates a new Client instance*
     
     - Parameter id: Unique identifier for the client
     - Parameter firstName: Client's first name
     - Parameter lastName: Client's last name
     - Parameter phone: Optional phone number
     - Parameter email: Optional email address
     - Parameter pronouns: Optional preferred pronouns
     - Parameter createdBy: ID of the creating provider
     - Parameter createdByName: Display name of the creating provider
     - Parameter lastSeenAt: Date of last visit
     - Parameter createdAt: Date when record was created
     */
    init(
        id: String,
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
        self.id = id
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

    /**
     *Creates a Client instance from Firestore data*
     
     This initializer is used to create Client instances from Firestore document data.
     It validates required fields and handles optional data appropriately.
     
     - Parameter data: Dictionary containing Firestore document data
     - Parameter id: Optional document ID from Firestore
     - Returns: A Client instance if valid data is provided, nil otherwise
     
     ## Example
     ```swift
     if let client = Client(data: documentData, id: documentID) {
         // Use the client
     }
     ```
     */
    init?(data: [String: Any], id: String?) {
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let documentId = id, !documentId.isEmpty else {
            return nil
        }

        self.id = documentId
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
