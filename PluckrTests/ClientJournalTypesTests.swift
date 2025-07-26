import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr



class ClientJournalTypesTests: XCTestCase {
    
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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Real Client Functionality Tests
    
    func testClientDataDictionaryCreation() {
        // Given
        let testDate = Date()
        let client = Client(
            id: "testClient123",
            firstName: "John",
            lastName: "Doe",
            phone: "123-456-7890",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider1",
            createdByName: "Provider One",
            clientTags: []
        )
        
        // When
        let data = client.toDict()
        
        // Then
        XCTAssertEqual(data["firstName"] as? String, "John", "First name should be serialized correctly")
        XCTAssertEqual(data["lastName"] as? String, "Doe", "Last name should be serialized correctly")
        XCTAssertEqual(data["phone"] as? String, "123-456-7890", "Phone should be serialized correctly")
        XCTAssertEqual(data["email"] as? String, "john@example.com", "Email should be serialized correctly")
        XCTAssertEqual(data["pronouns"] as? String, "he/him", "Pronouns should be serialized correctly")
        XCTAssertEqual(data["createdBy"] as? String, "provider1", "Created by should be serialized correctly")
        XCTAssertEqual(data["createdByName"] as? String, "Provider One", "Created by name should be serialized correctly")
    }
    
    func testClientFullNameComputation() {
        // Given
        let client = Client(
            id: "testClient456",
            firstName: "Jane",
            lastName: "Smith",
            phone: "555-123-4567",
            email: "jane@example.com",
            pronouns: "she/her",
            createdBy: "provider2",
            createdByName: "Provider Two",
            clientTags: []
        )
        // When
        let fullName = client.fullName
        // Then
        if fullName != "Jane Smith" {
            print("DEBUG: fullName was '", fullName, "'")
        }
        XCTAssertEqual(fullName, "Jane Smith", "Full name should be concatenated correctly")
    }

    func testClientFullNameWithEmptyNames() {
        // Given
        let client1 = Client(
            id: "testClient789",
            firstName: "",
            lastName: "Johnson",
            phone: "555-987-6543",
            email: "johnson@example.com",
            pronouns: "they/them",
            createdBy: "provider3",
            createdByName: "Provider Three",
            clientTags: []
        )
        let client2 = Client(
            id: "testClient101",
            firstName: "Bob",
            lastName: "",
            phone: "555-111-2222",
            email: "bob@example.com",
            pronouns: "he/him",
            createdBy: "provider4",
            createdByName: "Provider Four",
            clientTags: []
        )
        // When & Then
        if client1.fullName != "Johnson" {
            print("DEBUG: client1.fullName was '", client1.fullName, "'")
        }
        if client2.fullName != "Bob" {
            print("DEBUG: client2.fullName was '", client2.fullName, "'")
        }
        XCTAssertEqual(client1.fullName, "Johnson", "Full name should handle empty first name")
        XCTAssertEqual(client2.fullName, "Bob", "Full name should handle empty last name")
    }
    
    func testClientInitializationFromDictionary() {
        // Given
        let testDate = Date()
        let data: [String: Any] = [
            "firstName": "Jane",
            "lastName": "Smith",
            "phone": "555-123-4567",
            "email": "jane@example.com",
            "pronouns": "she/her",
            "createdBy": "provider2",
            "createdByName": "Provider Two",
            "createdAt": Timestamp(date: testDate),
            "lastSeenAt": Timestamp(date: testDate)
        ]
        
        // When
        let client = Client(data: data, id: "testClient456")
        
        // Then
        XCTAssertNotNil(client, "Client should be initialized successfully")
        if let client = client {
            XCTAssertEqual(client.firstName, "Jane", "First name should be correct")
            XCTAssertEqual(client.lastName, "Smith", "Last name should be correct")
            XCTAssertEqual(client.phone, "555-123-4567", "Phone should be correct")
            XCTAssertEqual(client.email, "jane@example.com", "Email should be correct")
            XCTAssertEqual(client.pronouns, "she/her", "Pronouns should be correct")
            XCTAssertEqual(client.createdBy, "provider2", "Created by should be correct")
            XCTAssertEqual(client.createdByName, "Provider Two", "Created by name should be correct")
            XCTAssertEqual(client.id, "testClient456", "ID should be set correctly")
        }
    }
    
    func testClientInitializationWithMissingData() {
        // Given
        let data: [String: Any] = [
            "firstName": "Jane",
            "lastName": "Smith"
            // Missing other fields
        ]
        
        // When
        let client = Client(data: data, id: "testClient789")
        
        // Then
        XCTAssertNotNil(client, "Client should be initialized successfully")
        if let client = client {
            XCTAssertEqual(client.firstName, "Jane", "First name should be correct")
            XCTAssertEqual(client.lastName, "Smith", "Last name should be correct")
            XCTAssertNil(client.phone, "Phone should be nil when missing")
            XCTAssertNil(client.email, "Email should be nil when missing")
            XCTAssertNil(client.pronouns, "Pronouns should be nil when missing")
            XCTAssertNil(client.createdBy, "Created by should be nil when missing")
            XCTAssertNil(client.createdByName, "Created by name should be nil when missing")
            XCTAssertEqual(client.id, "testClient789", "ID should be set correctly")
        }
    }
} 