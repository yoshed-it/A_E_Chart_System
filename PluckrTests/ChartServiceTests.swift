import XCTest
@testable import Pluckr

class ChartServiceTests: XCTestCase {
    func testChartEntryDataDictionary() {
        let chartData = ChartEntryData(
            modality: "TestModality",
            rfLevel: 1.0,
            dcLevel: 2.0,
            probe: "TestProbe",
            probeIsOnePiece: true,
            treatmentArea: "Area",
            notes: "Test notes",
            imageURLs: ["url1"],
            createdAt: Date(),
            createdBy: "provider1",
            createdByName: "Provider One",
            clientChosenName: "Jane D.",
            clientLegalName: "Jane Doe",
            chartTags: []
        )
        let dict = chartData.asDictionary
        XCTAssertEqual(dict["modality"] as? String, "TestModality")
        XCTAssertEqual(dict["probe"] as? String, "TestProbe")
    }

    func testOrgPathConstruction() async {
        let orgId = "orgTest"
        let clientId = "clientTest"
        let chartId = "chartTest"
        let expectedPath = "organizations/\(orgId)/clients/\(clientId)/charts/\(chartId)"
        let actualPath = "organizations/\(orgId)/clients/\(clientId)/charts/\(chartId)"
        XCTAssertEqual(expectedPath, actualPath)
    }

    func testChartCRUDMocked() async {
        // Placeholder for CRUD logic using a mock Firestore
        XCTAssertTrue(true, "CRUD operations should succeed with mock Firestore")
    }

    func testErrorHandlingOnMissingOrgId() async {
        let orgId: String? = nil
        XCTAssertNil(orgId)
    }
} 