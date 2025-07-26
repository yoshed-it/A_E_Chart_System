import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr

class OrganizationServiceTests: XCTestCase {
    var organizationService: OrganizationService!
    
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
        organizationService = OrganizationService.shared
    }
    
    override func tearDown() {
        organizationService = nil
        super.tearDown()
    }
    
    // MARK: - Organization Service Tests
    
    func testOrganizationServiceSingleton() {
        // Given & When
        let service1 = OrganizationService.shared
        let service2 = OrganizationService.shared
        
        // Then
        XCTAssertTrue(service1 === service2, "OrganizationService should be a singleton")
    }
    
    func testOrganizationServiceInitialization() {
        // Given & When
        let service = OrganizationService.shared
        
        // Then
        XCTAssertNotNil(service, "OrganizationService should be initialized")
    }
} 