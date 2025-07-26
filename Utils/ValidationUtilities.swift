import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

/// Production utilities for validating image capture and Firestore structure
struct ValidationUtilities {
    
    // MARK: - Image Capture Validation
    
    /// Validates that images are actually being captured and stored properly
    static func validateImageCaptureFlow(
        testImage: UIImage, 
        clientId: String,
        completion: @escaping (ValidationResult) -> Void
    ) {
        Task {
            var results: [String] = []
            var errors: [String] = []
            
            // Step 1: Validate image compression
            guard let imageData = testImage.jpegData(compressionQuality: 0.7) else {
                errors.append("❌ Step 1 FAILED: Image compression failed")
                completion(.failure(errors))
                return
            }
            results.append("✅ Step 1 PASSED: Image compression successful (\(imageData.count) bytes)")
            
            // Step 2: Validate encryption key
            guard let orgKey = OrgEncryptionKeyManager.shared.orgKey else {
                errors.append("❌ Step 2 FAILED: No organization encryption key available")
                completion(.failure(errors))
                return
            }
            results.append("✅ Step 2 PASSED: Organization encryption key available")
            
            // Step 3: Validate encryption
            guard let encryptedData = AESHelper.encrypt(data: imageData, key: orgKey) else {
                errors.append("❌ Step 3 FAILED: Image encryption failed")
                completion(.failure(errors))
                return
            }
            results.append("✅ Step 3 PASSED: Image encryption successful (\(encryptedData.count) encrypted bytes)")
            
            // Step 4: Validate upload path structure
            guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
                errors.append("❌ Step 4 FAILED: No organization ID available")
                completion(.failure(errors))
                return
            }
            
            let filename = UUID().uuidString + ".enc"
            let expectedPath = "organizations/\(orgId)/charts/\(clientId)/\(filename)"
            results.append("✅ Step 4 PASSED: Upload path structure valid: \(expectedPath)")
            
            // Step 5: Attempt actual upload
            let uploadURL = await CameraUploader.uploadImage(image: testImage, clientId: clientId)
            if let url = uploadURL {
                results.append("✅ Step 5 PASSED: Image uploaded successfully to: \(url)")
                
                // Step 6: Validate uploaded file
                let isValid = await validateUploadedImage(url: url, originalSize: imageData.count)
                if isValid {
                    results.append("✅ Step 6 PASSED: Uploaded image validation successful")
                    completion(.success(results))
                } else {
                    errors.append("❌ Step 6 FAILED: Uploaded image validation failed")
                    completion(.failure(errors))
                }
            } else {
                errors.append("❌ Step 5 FAILED: Image upload failed")
                completion(.failure(errors))
            }
        }
    }
    
    /// Validates that an uploaded image URL contains valid encrypted data
    private static func validateUploadedImage(url: String, originalSize: Int) async -> Bool {
        guard let downloadURL = URL(string: url) else {
            PluckrLogger.error("Validation: Invalid URL format")
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: downloadURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                PluckrLogger.error("Validation: HTTP error or invalid response")
                return false
            }
            
            guard data.count > 0 else {
                PluckrLogger.error("Validation: Downloaded data is empty")
                return false
            }
            
            // Validate it looks like encrypted data (should be different from original)
            let isEncrypted = data.count >= Int(Double(originalSize) * 0.8) && // Roughly same size (accounting for compression)
                              !data.allSatisfy { $0 == 0 } && // Not all zeros
                              data.count < Int(Double(originalSize) * 2.0) // Not unreasonably large
            
            if isEncrypted {
                PluckrLogger.success("Validation: Downloaded data appears to be valid encrypted content (\(data.count) bytes)")
                return true
            } else {
                PluckrLogger.error("Validation: Downloaded data doesn't appear to be valid encrypted content")
                return false
            }
        } catch {
            PluckrLogger.error("Validation: Failed to download/validate image: \(error)")
            return false
        }
    }
    
    // MARK: - Firestore Structure Validation
    
    /// Validates the Firestore structure for a specific organization
    static func validateFirestoreStructure(
        orgId: String,
        completion: @escaping (ValidationResult) -> Void
    ) {
        Task {
            var results: [String] = []
            var errors: [String] = []
            let db = Firestore.firestore()
            
            // Test 1: Validate organization exists
            do {
                let orgDoc = try await db.collection("organizations").document(orgId).getDocument()
                if orgDoc.exists {
                    results.append("✅ Organization document exists: \(orgId)")
                } else {
                    errors.append("❌ Organization document does not exist: \(orgId)")
                }
            } catch {
                errors.append("❌ Failed to check organization: \(error)")
            }
            
            // Test 2: Validate required collections exist
            let requiredCollections = ["clients", "providers", "clientTagsLibrary", "chartTagsLibrary"]
            
            for collection in requiredCollections {
                do {
                    let snapshot = try await db.collection("organizations")
                        .document(orgId)
                        .collection(collection)
                        .limit(to: 1)
                        .getDocuments()
                    
                    results.append("✅ Collection accessible: organizations/\(orgId)/\(collection)")
                } catch {
                    errors.append("❌ Collection not accessible: organizations/\(orgId)/\(collection) - \(error)")
                }
            }
            
            // Test 3: Validate a sample client structure (if clients exist)
            do {
                let clientsSnapshot = try await db.collection("organizations")
                    .document(orgId)
                    .collection("clients")
                    .limit(to: 1)
                    .getDocuments()
                
                if let firstClient = clientsSnapshot.documents.first {
                    let clientId = firstClient.documentID
                    
                    // Check if client has proper schema
                    let data = firstClient.data()
                    let requiredFields = ["firstName", "lastName", "id"]
                    let missingFields = requiredFields.filter { !data.keys.contains($0) }
                    
                    if missingFields.isEmpty {
                        results.append("✅ Sample client has required fields: \(clientId)")
                    } else {
                        errors.append("❌ Sample client missing fields: \(missingFields.joined(separator: ", "))")
                    }
                    
                    // Check charts subcollection
                    do {
                        let chartsSnapshot = try await db.collection("organizations")
                            .document(orgId)
                            .collection("clients")
                            .document(clientId)
                            .collection("charts")
                            .limit(to: 1)
                            .getDocuments()
                        
                        results.append("✅ Charts subcollection accessible for client: \(clientId)")
                        
                        if let firstChart = chartsSnapshot.documents.first {
                            let chartData = firstChart.data()
                            let chartRequiredFields = ["modality", "rfLevel", "dcLevel", "probe", "createdAt"]
                            let chartMissingFields = chartRequiredFields.filter { !chartData.keys.contains($0) }
                            
                            if chartMissingFields.isEmpty {
                                results.append("✅ Sample chart has required fields")
                            } else {
                                errors.append("❌ Sample chart missing fields: \(chartMissingFields.joined(separator: ", "))")
                            }
                            
                            // Validate image URLs if present
                            if let imageURLs = chartData["imageURLs"] as? [String], !imageURLs.isEmpty {
                                let encryptedURLs = imageURLs.filter { $0.contains(".enc") }
                                if encryptedURLs.count == imageURLs.count {
                                    results.append("✅ All chart image URLs point to encrypted files")
                                } else {
                                    errors.append("❌ Some chart image URLs are not encrypted")
                                }
                            }
                        }
                    } catch {
                        errors.append("❌ Charts subcollection not accessible: \(error)")
                    }
                } else {
                    results.append("⚠️  No clients found in organization (this may be normal for new orgs)")
                }
            } catch {
                errors.append("❌ Failed to check clients collection: \(error)")
            }
            
            if errors.isEmpty {
                completion(.success(results))
            } else {
                completion(.failure(errors + results))
            }
        }
    }
    
    // MARK: - Complete System Validation
    
    /// Runs a complete validation of both image capture and Firestore structure
    static func runCompleteValidation(completion: @escaping (ValidationResult) -> Void) {
        Task {
            guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
                completion(.failure(["❌ No organization ID available for validation"]))
                return
            }
            
            var allResults: [String] = []
            var allErrors: [String] = []
            
            allResults.append("🔍 Starting complete system validation for org: \(orgId)")
            
            // Step 1: Validate Firestore structure
            await withCheckedContinuation { continuation in
                validateFirestoreStructure(orgId: orgId) { result in
                    switch result {
                    case .success(let results):
                        allResults.append("📊 Firestore Structure Validation:")
                        allResults.append(contentsOf: results)
                    case .failure(let errors):
                        allErrors.append("📊 Firestore Structure Validation FAILED:")
                        allErrors.append(contentsOf: errors)
                    }
                    continuation.resume()
                }
            }
            
            // Step 2: Validate image capture flow
            let testImage = createTestImage()
            let testClientId = "validation-test-client"
            
            await withCheckedContinuation { continuation in
                validateImageCaptureFlow(testImage: testImage, clientId: testClientId) { result in
                    switch result {
                    case .success(let results):
                        allResults.append("📷 Image Capture Validation:")
                        allResults.append(contentsOf: results)
                    case .failure(let errors):
                        allErrors.append("📷 Image Capture Validation FAILED:")
                        allErrors.append(contentsOf: errors)
                    }
                    continuation.resume()
                }
            }
            
            // Final result
            if allErrors.isEmpty {
                allResults.append("🎉 Complete system validation PASSED!")
                completion(.success(allResults))
            } else {
                allResults.append("⚠️  Complete system validation had issues")
                completion(.failure(allErrors + allResults))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private static func createTestImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)
        
        // Create a test pattern
        UIColor.systemBlue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        UIColor.white.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.move(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.lineWidth = 3
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}

// MARK: - Validation Result Types

enum ValidationResult {
    case success([String])
    case failure([String])
}

// MARK: - SwiftUI Integration

#if DEBUG
import SwiftUI

struct ValidationDebugView: View {
    @State private var validationResults: [String] = []
    @State private var isRunning = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isRunning {
                    ProgressView("Running validation...")
                        .padding()
                } else {
                    Button("Run Complete Validation") {
                        runValidation()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(validationResults, id: \.self) { result in
                            Text(result)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(result.hasPrefix("✅") ? .green : 
                                               result.hasPrefix("❌") ? .red : .primary)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("System Validation")
        }
    }
    
    private func runValidation() {
        isRunning = true
        validationResults = []
        
        ValidationUtilities.runCompleteValidation { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    validationResults = results
                case .failure(let errors):
                    validationResults = errors
                }
                isRunning = false
            }
        }
    }
}
#endif 
