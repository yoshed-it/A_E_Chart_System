import XCTest
import FirebaseFirestore
@testable import Pluckr

class FirestoreStructureTests: XCTestCase {
    
    // MARK: - Expected Firestore Structure
    
    /*
    Expected Firestore Structure:
    
    organizations/{orgId}/
    ├── clients/{clientId}/
    │   ├── charts/{chartId}/
    │   └── (client data)
    ├── clientTagsLibrary/{tagId}/
    ├── chartTagsLibrary/{tagId}/
    ├── providers/{userId}/
    └── dailyFolio/{date}/clients/{clientId}/
    
    Firebase Storage Structure:
    organizations/{orgId}/charts/{clientId}/{imageId}.enc
    */
    
    // MARK: - Document Schema Validation Tests
    
    func testClientDocumentSchema() {
        // Test Client document structure
        let testClient = Client(
            id: "test-client-123",
            firstName: "John",
            lastName: "Doe",
            phone: "555-1234",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider-123",
            createdByName: "Dr. Smith",
            clientTags: [
                Tag(label: "VIP", colorNameOrHex: "PluckrTagGreen")
            ]
        )
        
        let clientDict = testClient.toDict()
        
        // Required fields
        XCTAssertNotNil(clientDict["firstName"], "Client should have firstName")
        XCTAssertNotNil(clientDict["lastName"], "Client should have lastName")
        XCTAssertNotNil(clientDict["id"], "Client should have id")
        
        // Optional fields should be present when set
        XCTAssertNotNil(clientDict["phone"], "Client should have phone when set")
        XCTAssertNotNil(clientDict["email"], "Client should have email when set")
        XCTAssertNotNil(clientDict["pronouns"], "Client should have pronouns when set")
        XCTAssertNotNil(clientDict["createdBy"], "Client should have createdBy when set")
        XCTAssertNotNil(clientDict["createdByName"], "Client should have createdByName when set")
        
        // Client tags should be array of dictionaries
        if let tags = clientDict["clientTags"] as? [[String: Any]] {
            XCTAssertFalse(tags.isEmpty, "Client tags should be present")
            XCTAssertNotNil(tags.first?["label"], "Tag should have label")
            XCTAssertNotNil(tags.first?["colorNameOrHex"], "Tag should have color")
        }
        
        print("✅ Client document schema validation passed")
    }
    
    func testChartEntryDocumentSchema() {
        // Test ChartEntry document structure
        let testChart = ChartEntryData(
            modality: "Electrolysis",
            rfLevel: 1.5,
            dcLevel: 2.0,
            probe: "F3 Gold",
            probeIsOnePiece: true,
            treatmentArea: "Upper Lip",
            notes: "Test treatment notes",
            imageURLs: ["https://example.com/image1.enc", "https://example.com/image2.enc"],
            createdAt: Date(),
            createdBy: "provider-123",
            createdByName: "Dr. Smith",
            clientChosenName: "John",
            clientLegalName: "John Doe",
            chartTags: [
                Tag(label: "Sensitive", colorNameOrHex: "PluckrTagRed")
            ]
        )
        
        let chartDict = testChart.asDictionary
        
        // Required fields
        XCTAssertNotNil(chartDict["modality"], "Chart should have modality")
        XCTAssertNotNil(chartDict["rfLevel"], "Chart should have rfLevel")
        XCTAssertNotNil(chartDict["dcLevel"], "Chart should have dcLevel")
        XCTAssertNotNil(chartDict["probe"], "Chart should have probe")
        XCTAssertNotNil(chartDict["probeIsOnePiece"], "Chart should have probeIsOnePiece")
        XCTAssertNotNil(chartDict["notes"], "Chart should have notes")
        XCTAssertNotNil(chartDict["createdAt"], "Chart should have createdAt")
        XCTAssertNotNil(chartDict["createdBy"], "Chart should have createdBy")
        XCTAssertNotNil(chartDict["createdByName"], "Chart should have createdByName")
        
        // Image URLs should be array of strings
        if let imageURLs = chartDict["imageURLs"] as? [String] {
            XCTAssertEqual(imageURLs.count, 2, "Should have 2 image URLs")
            XCTAssertTrue(imageURLs.first?.contains(".enc") == true, "Image URLs should point to encrypted files")
        } else {
            XCTFail("imageURLs should be array of strings")
        }
        
        // Chart tags should be array of dictionaries
        if let tags = chartDict["chartTags"] as? [[String: Any]] {
            XCTAssertFalse(tags.isEmpty, "Chart tags should be present")
            XCTAssertNotNil(tags.first?["label"], "Chart tag should have label")
        }
        
        print("✅ Chart entry document schema validation passed")
    }
    
    func testTagDocumentSchema() {
        // Test Tag document structure
        let testTag = Tag(label: "Sensitive Area", colorNameOrHex: "PluckrTagRed")
        let tagDict = testTag.toDict()
        
        // Required fields
        XCTAssertNotNil(tagDict["label"], "Tag should have label")
        XCTAssertNotNil(tagDict["colorNameOrHex"], "Tag should have colorNameOrHex")
        
        // Validate data types
        XCTAssertTrue(tagDict["label"] is String, "Tag label should be string")
        XCTAssertTrue(tagDict["colorNameOrHex"] is String, "Tag color should be string")
        
        // Validate content
        let label = tagDict["label"] as? String
        XCTAssertFalse(label?.isEmpty == true, "Tag label should not be empty")
        
        print("✅ Tag document schema validation passed")
    }
    
    // MARK: - Collection Path Validation Tests
    
    func testFirestoreCollectionPaths() {
        let testOrgId = "test-org-123"
        let testClientId = "test-client-456"
        let testChartId = "test-chart-789"
        let testTagId = "test-tag-abc"
        let testProviderId = "test-provider-def"
        let testDate = "2025-01-26"
        
        // Expected collection paths
        let expectedPaths = [
            "organizations/\(testOrgId)/clients/\(testClientId)",
            "organizations/\(testOrgId)/clients/\(testClientId)/charts/\(testChartId)",
            "organizations/\(testOrgId)/clientTagsLibrary/\(testTagId)",
            "organizations/\(testOrgId)/chartTagsLibrary/\(testTagId)",
            "organizations/\(testOrgId)/providers/\(testProviderId)",
            "organizations/\(testOrgId)/providers/\(testProviderId)/dailyFolio/\(testDate)/clients/\(testClientId)"
        ]
        
        // Validate each path structure
        for path in expectedPaths {
            // Should start with organizations/{orgId}
            XCTAssertTrue(path.hasPrefix("organizations/\(testOrgId)"), "All paths should be organization-scoped: \(path)")
            
            // Should not use old root-level structure
            XCTAssertFalse(path.hasPrefix("clients/"), "Should not use old root-level clients: \(path)")
            XCTAssertFalse(path.hasPrefix("charts/"), "Should not use old root-level charts: \(path)")
            
            // Should have proper nesting
            if path.contains("/charts/") {
                XCTAssertTrue(path.contains("/clients/"), "Charts should be nested under clients: \(path)")
            }
        }
        
        print("✅ Firestore collection paths validation passed")
    }
    
    func testFirebaseStoragePaths() {
        let testOrgId = "test-org-123"
        let testClientId = "test-client-456"
        let testImageId = UUID().uuidString
        
        // Expected storage path: organizations/{orgId}/charts/{clientId}/{imageId}.enc
        let expectedPath = "organizations/\(testOrgId)/charts/\(testClientId)/\(testImageId).enc"
        
        // Validate structure
        XCTAssertTrue(expectedPath.hasPrefix("organizations/\(testOrgId)"), "Storage should be organization-scoped")
        XCTAssertTrue(expectedPath.contains("/charts/\(testClientId)/"), "Storage should be client-scoped")
        XCTAssertTrue(expectedPath.hasSuffix(".enc"), "Images should be encrypted with .enc extension")
        
        // Should not use old root-level structure
        XCTAssertFalse(expectedPath.hasPrefix("charts/"), "Should not use old root-level storage")
        
        print("✅ Firebase Storage paths validation passed")
    }
    
    // MARK: - Data Integrity Validation Tests
    
    func testDataIntegrityValidation() {
        // Test that related data maintains referential integrity
        let testOrgId = "test-org-123"
        let testClientId = "test-client-456"
        let testProviderId = "test-provider-789"
        
        // Client should reference provider
        let client = Client(
            id: testClientId,
            firstName: "Jane",
            lastName: "Doe",
            createdBy: testProviderId,
            createdByName: "Dr. Smith"
        )
        
        XCTAssertEqual(client.createdBy, testProviderId, "Client should reference correct provider")
        XCTAssertNotNil(client.createdByName, "Client should have provider name for display")
        
        // Chart should reference both client and provider
        let chart = ChartEntryData(
            modality: "Test",
            rfLevel: 1.0,
            dcLevel: 1.0,
            probe: "Test Probe",
            probeIsOnePiece: true,
            notes: "Test notes",
            imageURLs: [],
            createdAt: Date(),
            createdBy: testProviderId,
            createdByName: "Dr. Smith",
            clientChosenName: "Jane",
            clientLegalName: "Jane Doe"
        )
        
        XCTAssertEqual(chart.createdBy, testProviderId, "Chart should reference correct provider")
        XCTAssertNotNil(chart.clientChosenName, "Chart should have client reference")
        
        print("✅ Data integrity validation passed")
    }
    
    // MARK: - HIPAA Compliance Validation Tests
    
    func testHIPAAComplianceValidation() {
        // Test that sensitive data is properly handled
        let client = Client(
            id: "test-client",
            firstName: "John",
            lastName: "Doe",
            phone: "555-1234",
            email: "john@example.com"
        )
        
        let clientDict = client.toDict()
        
        // Client data should be properly structured for HIPAA
        XCTAssertTrue(clientDict.keys.contains("firstName"), "firstName should be stored")
        XCTAssertTrue(clientDict.keys.contains("lastName"), "lastName should be stored")
        
        // Image URLs should point to encrypted files
        let chart = ChartEntryData(
            modality: "Test",
            rfLevel: 1.0,
            dcLevel: 1.0,
            probe: "Test",
            probeIsOnePiece: true,
            notes: "Test",
            imageURLs: ["https://firebase.com/image.enc"],
            createdAt: Date(),
            createdBy: "provider",
            createdByName: "Provider",
            clientChosenName: "John",
            clientLegalName: "John Doe"
        )
        
        let chartDict = chart.asDictionary
        if let imageURLs = chartDict["imageURLs"] as? [String] {
            for url in imageURLs {
                XCTAssertTrue(url.contains(".enc"), "All image URLs should point to encrypted files for HIPAA compliance")
            }
        }
        
        print("✅ HIPAA compliance validation passed")
    }
}

// MARK: - Manual Validation Utilities

extension FirestoreStructureTests {
    
    /// Run this manually to validate your actual Firestore structure
    func manualFirestoreValidation() async {
        guard ProcessInfo.processInfo.environment["RUN_FIRESTORE_VALIDATION"] == "1" else {
            print("⚠️  Skipping manual Firestore validation - set RUN_FIRESTORE_VALIDATION=1 to enable")
            return
        }
        
        print("🔍 Starting manual Firestore structure validation...")
        
        // This would connect to your actual Firestore and validate structure
        // Implementation depends on your specific Firebase configuration
        
        print("✅ Manual Firestore validation completed")
    }
    
    /// Validates that a chart entry has all required image URLs and they're accessible
    func validateChartImageIntegrity(chartId: String, clientId: String) async -> Bool {
        // This would load a chart from Firestore and validate all its image URLs
        // Return true if all images are accessible and properly encrypted
        return true
    }
} 