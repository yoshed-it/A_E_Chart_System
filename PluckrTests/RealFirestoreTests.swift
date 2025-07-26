import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr

@MainActor
class RealFirestoreTests: XCTestCase {
    var organizationService: OrganizationService!
    var chartService: ChartService!
    var tagService: TagService!
    
    override func setUp() {
        super.setUp()
        organizationService = OrganizationService.shared
        chartService = ChartService.shared
        tagService = TagService.shared
    }
    
    override func tearDown() {
        organizationService = nil
        chartService = nil
        tagService = nil
        super.tearDown()
    }
    
    // MARK: - Service Initialization Tests
    
    func testClientRepositoryInitialization() {
        // Given & When
        let repository = ClientRepository()
        
        // Then
        XCTAssertNotNil(repository, "ClientRepository should initialize properly")
    }
    
    func testOrganizationServiceInitialization() {
        // Given & When
        let service = OrganizationService.shared
        
        // Then
        XCTAssertNotNil(service, "OrganizationService should initialize properly")
    }
    
    func testChartServiceInitialization() {
        // Given & When
        let service = ChartService.shared
        
        // Then
        XCTAssertNotNil(service, "ChartService should initialize properly")
    }
    
    func testTagServiceInitialization() {
        // Given & When
        let service = TagService.shared
        
        // Then
        XCTAssertNotNil(service, "TagService should initialize properly")
    }
    
    func testServicesSingleton() {
        // Given & When
        let orgService1 = OrganizationService.shared
        let orgService2 = OrganizationService.shared
        let chartService1 = ChartService.shared
        let chartService2 = ChartService.shared
        let tagService1 = TagService.shared
        let tagService2 = TagService.shared
        
        // Then
        XCTAssertTrue(orgService1 === orgService2, "OrganizationService should be singleton")
        XCTAssertTrue(chartService1 === chartService2, "ChartService should be singleton")
        XCTAssertTrue(tagService1 === tagService2, "TagService should be singleton")
    }
} 