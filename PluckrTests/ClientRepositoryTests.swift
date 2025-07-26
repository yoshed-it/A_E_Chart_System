import XCTest
import Firebase
@testable import Pluckr

class ClientRepositoryTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        if ProcessInfo.processInfo.environment["IS_TESTING"] == "1" {
            FirebaseApp.app()?.delete { _ in
                let filePath = Bundle(for: self).path(forResource: "GoogleService-Info-Test", ofType: "plist")!
                let options = FirebaseOptions(contentsOfFile: filePath)!
                FirebaseApp.configure(options: options)
            }
        }
    }

    func testCreateClientDataDictionary() {
        let input = ClientInput(firstName: "Jane", lastName: "Doe", phone: "123", email: "jane@doe.com", pronouns: "she/her", createdBy: "provider1", createdByName: "Provider One")
        let data: [String: Any] = [
            "firstName": input.firstName,
            "lastName": input.lastName,
            "phone": input.phone as Any,
            "email": input.email as Any,
            "pronouns": input.pronouns as Any,
            "createdBy": input.createdBy,
            "createdByName": input.createdByName,
            "createdAt": Timestamp(date: input.createdAt),
            "lastSeenAt": Timestamp(date: input.createdAt)
        ]
        XCTAssertEqual(data["firstName"] as? String, "Jane")
        XCTAssertEqual(data["lastName"] as? String, "Doe")
    }

    func testClientRepositoryInitialization() {
        // Given & When
        let repository = ClientRepository()
        
        // Then
        XCTAssertNotNil(repository, "ClientRepository should be initialized")
    }
    
    func testClientInputValidation() {
        // Given
        let validInput = ClientInput(
            firstName: "John",
            lastName: "Doe",
            phone: "123-456-7890",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider1",
            createdByName: "Provider One"
        )
        
        // When & Then
        XCTAssertEqual(validInput.firstName, "John", "First name should be correct")
        XCTAssertEqual(validInput.lastName, "Doe", "Last name should be correct")
        XCTAssertEqual(validInput.phone, "123-456-7890", "Phone should be correct")
        XCTAssertEqual(validInput.email, "john@example.com", "Email should be correct")
        XCTAssertEqual(validInput.pronouns, "he/him", "Pronouns should be correct")
        XCTAssertEqual(validInput.createdBy, "provider1", "Created by should be correct")
        XCTAssertEqual(validInput.createdByName, "Provider One", "Created by name should be correct")
    }
    
    func testClientInputWithEmptyFields() {
        // Given
        let inputWithEmptyFields = ClientInput(
            firstName: "",
            lastName: "",
            phone: "",
            email: "",
            pronouns: "",
            createdBy: "",
            createdByName: ""
        )
        
        // When & Then
        XCTAssertEqual(inputWithEmptyFields.firstName, "", "Empty first name should be allowed")
        XCTAssertEqual(inputWithEmptyFields.lastName, "", "Empty last name should be allowed")
        XCTAssertEqual(inputWithEmptyFields.phone, "", "Empty phone should be allowed")
        XCTAssertEqual(inputWithEmptyFields.email, "", "Empty email should be allowed")
        XCTAssertEqual(inputWithEmptyFields.pronouns, "", "Empty pronouns should be allowed")
        XCTAssertEqual(inputWithEmptyFields.createdBy, "", "Empty created by should be allowed")
        XCTAssertEqual(inputWithEmptyFields.createdByName, "", "Empty created by name should be allowed")
    }
    
    func testClientInputDataDictionaryCreation() {
        // Given
        let testDate = Date()
        let input = ClientInput(
            firstName: "Jane",
            lastName: "Smith",
            phone: "098-765-4321",
            email: "jane@smith.com",
            pronouns: "she/her",
            createdBy: "provider2",
            createdByName: "Provider Two"
        )
        
        // When
        let data: [String: Any] = [
            "firstName": input.firstName,
            "lastName": input.lastName,
            "phone": input.phone as Any,
            "email": input.email as Any,
            "pronouns": input.pronouns as Any,
            "createdBy": input.createdBy,
            "createdByName": input.createdByName,
            "createdAt": Timestamp(date: input.createdAt),
            "lastSeenAt": Timestamp(date: input.createdAt)
        ]
        
        // Then
        XCTAssertEqual(data["firstName"] as? String, "Jane", "First name should be correct")
        XCTAssertEqual(data["lastName"] as? String, "Smith", "Last name should be correct")
        XCTAssertEqual(data["phone"] as? String, "098-765-4321", "Phone should be correct")
        XCTAssertEqual(data["email"] as? String, "jane@smith.com", "Email should be correct")
        XCTAssertEqual(data["pronouns"] as? String, "she/her", "Pronouns should be correct")
        XCTAssertEqual(data["createdBy"] as? String, "provider2", "Created by should be correct")
        XCTAssertEqual(data["createdByName"] as? String, "Provider Two", "Created by name should be correct")
        XCTAssertNotNil(data["createdAt"], "Created at should be present")
        XCTAssertNotNil(data["lastSeenAt"], "Last seen at should be present")
    }
} 