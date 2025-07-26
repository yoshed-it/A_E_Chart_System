import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr

@MainActor
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

    func testChartServiceSingleton() {
        // Given & When
        let service1 = ChartService.shared
        let service2 = ChartService.shared
        
        // Then
        XCTAssertTrue(service1 === service2, "ChartService should be a singleton")
    }
    
    func testChartEntryDataValidation() {
        // Given
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
        
        // When & Then
        XCTAssertEqual(chartData.modality, "TestModality", "Modality should be correct")
        XCTAssertEqual(chartData.rfLevel, 1.0, "RF level should be correct")
        XCTAssertEqual(chartData.dcLevel, 2.0, "DC level should be correct")
        XCTAssertEqual(chartData.probe, "TestProbe", "Probe should be correct")
        XCTAssertTrue(chartData.probeIsOnePiece, "Probe is one piece should be correct")
        XCTAssertEqual(chartData.treatmentArea, "Area", "Treatment area should be correct")
        XCTAssertEqual(chartData.notes, "Test notes", "Notes should be correct")
        XCTAssertEqual(chartData.imageURLs.count, 1, "Image URLs count should be correct")
        XCTAssertEqual(chartData.createdBy, "provider1", "Created by should be correct")
        XCTAssertEqual(chartData.createdByName, "Provider One", "Created by name should be correct")
        XCTAssertEqual(chartData.clientChosenName, "Jane D.", "Client chosen name should be correct")
        XCTAssertEqual(chartData.clientLegalName, "Jane Doe", "Client legal name should be correct")
        XCTAssertEqual(chartData.chartTags.count, 0, "Chart tags should be empty")
    }
} 