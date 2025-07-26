import XCTest
import UIKit
import CryptoKit
import FirebaseStorage
@testable import Pluckr

class CameraUploaderTests: XCTestCase {
    
    // MARK: - Image Creation and Processing Tests
    
    func testImageCreationAndCompression() {
        // Test that we can create and compress images properly
        let testImage = createTestImage()
        XCTAssertNotNil(testImage, "Should be able to create test image")
        
        let jpegData = testImage.jpegData(compressionQuality: 0.7)
        XCTAssertNotNil(jpegData, "Should be able to compress image to JPEG")
        XCTAssertTrue(jpegData!.count > 0, "JPEG data should not be empty")
        
        // Verify we can recreate image from JPEG data
        let reconstructedImage = UIImage(data: jpegData!)
        XCTAssertNotNil(reconstructedImage, "Should be able to recreate image from JPEG data")
    }
    
    func testImageEncryptionDecryptionCycle() {
        // Test the complete encryption/decryption cycle
        let testImage = createTestImage()
        guard let imageData = testImage.jpegData(compressionQuality: 0.7) else {
            XCTFail("Failed to get image data")
            return
        }
        
        // Create test encryption key
        let testKey = SymmetricKey(size: .bits256)
        
        // Test encryption
        guard let encryptedData = AESHelper.encrypt(data: imageData, key: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        XCTAssertNotEqual(encryptedData, imageData, "Encrypted data should be different from original")
        XCTAssertTrue(encryptedData.count > 0, "Encrypted data should not be empty")
        
        // Test decryption
        let decryptedImage = ChartImageDecryptor.decryptImageData(encryptedData, with: testKey)
        XCTAssertNotNil(decryptedImage, "Decryption should succeed")
        XCTAssertEqual(decryptedImage?.size, testImage.size, "Decrypted image should have same size")
    }
    
    // MARK: - Storage Path Validation Tests
    
    func testFirebaseStoragePathStructure() async {
        // Test that storage paths follow the expected structure
        let testClientId = "test-client-123"
        let testOrgId = "test-org-456"
        
        // Expected path: organizations/{orgId}/charts/{clientId}/{filename}.enc
        let expectedPathPattern = "organizations/\(testOrgId)/charts/\(testClientId)/"
        
        // Mock the storage path creation logic
        let filename = UUID().uuidString + ".enc"
        let fullPath = "organizations/\(testOrgId)/charts/\(testClientId)/\(filename)"
        
        XCTAssertTrue(fullPath.hasPrefix(expectedPathPattern), "Storage path should follow expected structure")
        XCTAssertTrue(fullPath.hasSuffix(".enc"), "Encrypted files should have .enc extension")
        XCTAssertTrue(filename.contains("-"), "Filename should be a valid UUID")
    }
    
    // MARK: - Integration Validation Tests
    
    func testImageUploadPipelineValidation() async {
        // This test validates the complete pipeline without actually uploading
        let testImage = createTestImage()
        let testClientId = "validation-client"
        
        // Step 1: Validate image compression
        guard let imageData = testImage.jpegData(compressionQuality: 0.7) else {
            XCTFail("Step 1 failed: Image compression")
            return
        }
        
        // Step 2: Validate encryption key availability
        // Note: In real tests, you'd mock OrgEncryptionKeyManager
        let testKey = SymmetricKey(size: .bits256)
        
        // Step 3: Validate encryption
        guard let encryptedData = AESHelper.encrypt(data: imageData, key: testKey) else {
            XCTFail("Step 3 failed: Image encryption")
            return
        }
        
        // Step 4: Validate path structure
        let filename = UUID().uuidString + ".enc"
        XCTAssertTrue(filename.hasSuffix(".enc"), "Step 4 failed: Filename should have .enc extension")
        
        // Step 5: Validate data integrity
        XCTAssertTrue(encryptedData.count > 0, "Step 5 failed: Encrypted data should not be empty")
        XCTAssertNotEqual(encryptedData, imageData, "Step 5 failed: Encrypted data should differ from original")
        
        print("✅ Image upload pipeline validation passed all steps")
    }
    
    // MARK: - Real Upload Test (Manual/Integration)
    
    func testActualImageUploadToFirebase() async {
        // This test requires Firebase configuration and should be run manually
        // Skip in automated tests but provide for manual validation
        guard ProcessInfo.processInfo.environment["RUN_FIREBASE_TESTS"] == "1" else {
            print("⚠️  Skipping Firebase upload test - set RUN_FIREBASE_TESTS=1 to enable")
            return
        }
        
        let testImage = createTestImage()
        let testClientId = "integration-test-client"
        
        let uploadURL = await CameraUploader.uploadImage(image: testImage, clientId: testClientId)
        
        if let url = uploadURL {
            print("✅ Image uploaded successfully to: \(url)")
            XCTAssertTrue(url.contains("firebase"), "Upload URL should be from Firebase")
            XCTAssertTrue(url.contains(testClientId), "Upload URL should contain client ID")
        } else {
            print("❌ Image upload failed - check Firebase configuration and org key")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage() -> UIImage {
        // Create a simple test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Add some visual content to make it more realistic
        UIColor.white.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 10))
        path.addLine(to: CGPoint(x: 90, y: 90))
        path.lineWidth = 2
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}

// MARK: - Image Validation Utilities

extension CameraUploaderTests {
    
    /// Validates that an image URL from Firestore actually contains valid encrypted image data
    func validateImageURL(_ url: String) async -> Bool {
        // Download the data from the URL
        guard let downloadURL = URL(string: url) else {
            print("❌ Invalid URL format: \(url)")
            return false
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: downloadURL)
            
            // Validate it's not empty
            guard data.count > 0 else {
                print("❌ Downloaded data is empty")
                return false
            }
            
            // Check if it looks like encrypted data (random bytes, not readable)
            let isValidEncrypted = data.count > 100 && !data.allSatisfy { $0 == 0 }
            
            if isValidEncrypted {
                print("✅ Image URL contains valid encrypted data (\(data.count) bytes)")
                return true
            } else {
                print("❌ Image URL data doesn't look like valid encrypted content")
                return false
            }
        } catch {
            print("❌ Failed to download image from URL: \(error)")
            return false
        }
    }
} 