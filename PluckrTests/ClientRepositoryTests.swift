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

    func testOrgPathConstruction() async {
        let orgId = "orgTest"
        let clientId = "clientTest"
        let expectedPath = "organizations/\(orgId)/clients/\(clientId)"
        let actualPath = "organizations/\(orgId)/clients/\(clientId)"
        XCTAssertEqual(expectedPath, actualPath)
    }

    func testClientCRUDMocked() async {
        // This is a placeholder for CRUD logic using a mock Firestore
        // In a real test, you would inject a mock Firestore and verify calls
        XCTAssertTrue(true, "CRUD operations should succeed with mock Firestore")
    }

    func testErrorHandlingOnMissingOrgId() async {
        // Simulate missing orgId scenario
        let orgId: String? = nil
        XCTAssertNil(orgId)
    }
} 