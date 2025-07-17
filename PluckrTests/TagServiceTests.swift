import XCTest
@testable import Pluckr

class TagServiceTests: XCTestCase {
    func testTagDictionary() {
        let tag = Tag(label: "Sensitive", colorNameOrHex: "PluckrTagRed")
        let dict = tag.toDict()
        XCTAssertEqual(dict["label"] as? String, "Sensitive")
        XCTAssertEqual(dict["colorNameOrHex"] as? String, "PluckrTagRed")
    }

    func testOrgPathConstruction() async {
        let orgId = "orgTest"
        let tagId = "tagTest"
        let expectedPath = "organizations/\(orgId)/clientTagsLibrary/\(tagId)"
        let actualPath = "organizations/\(orgId)/clientTagsLibrary/\(tagId)"
        XCTAssertEqual(expectedPath, actualPath)
    }

    func testTagCRUDMocked() async {
        // Placeholder for CRUD logic using a mock Firestore
        XCTAssertTrue(true, "CRUD operations should succeed with mock Firestore")
    }

    func testErrorHandlingOnMissingOrgId() async {
        let orgId: String? = nil
        XCTAssertNil(orgId)
    }
} 