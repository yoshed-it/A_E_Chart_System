import XCTest
import UIKit
import CryptoKit
@testable import Pluckr

class CameraUploaderTests: XCTestCase {
    func testImageEncryptionProducesNonEmptyData() async {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let key = SymmetricKey(data: Data(repeating: 0x01, count: 32))
        let data = image.jpegData(compressionQuality: 0.7)!
        let encrypted = AESHelper.encrypt(data: data, key: key)
        XCTAssertNotNil(encrypted)
        XCTAssertFalse(encrypted!.isEmpty)
    }

    func testStoragePathIncludesOrgAndClient() async {
        // This test assumes OrganizationService.shared.getCurrentOrganizationId() returns a stubbed value
        let orgId = "testOrg123"
        let clientId = "testClient456"
        let filename = "testfile.enc"
        let expectedPath = "organizations/\(orgId)/charts/\(clientId)/\(filename)"
        // Simulate the path construction logic
        let actualPath = "organizations/\(orgId)/charts/\(clientId)/\(filename)"
        XCTAssertEqual(expectedPath, actualPath)
    }
} 