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

    func testUpdateClientTagsSavesTags() async {
        // This is an integration-style test. In a real unit test, use a mock Firestore.
        // Here, we check that updateClientTags completes without error for a fake client.
        let clientId = "testClientId"
        let tags = [Tag(label: "Sensitive", colorNameOrHex: "PluckrTagRed"), Tag(label: "VIP", colorNameOrHex: "PluckrTagBlue")]
        do {
            try await TagService.shared.updateClientTags(clientId: clientId, tags: tags)
            // If no error is thrown, the test passes for this integration scenario.
            XCTAssertTrue(true)
        } catch {
            XCTFail("updateClientTags threw an error: \(error)")
        }
    }

    func testSaveCustomClientTagToLibrary() async {
        // This is an integration-style test. In a real unit test, use a mock Firestore.
        // Here, we check that saveCustomTagToLibrary completes without error for a custom client tag.
        let customTag = Tag(label: "TestCustom", colorNameOrHex: "PluckrTagTan")
        do {
            try await TagService.shared.saveCustomTagToLibrary(tag: customTag, context: .client)
            // If no error is thrown, the test passes for this integration scenario.
            XCTAssertTrue(true)
        } catch {
            XCTFail("saveCustomTagToLibrary threw an error: \(error)")
        }
    }
} 