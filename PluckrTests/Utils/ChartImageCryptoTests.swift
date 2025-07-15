//
//  ChartImageCryptoTests.swift
//  Pluckr
//
//  Created by Susan Bailey on 7/15/25.
//

import XCTest
import CryptoKit
@testable import Pluckr

final class ChartImageCryptoTests: XCTestCase {
    func testEncryptAndDecryptImage() {
        // 1. Create a test image (solid red square)
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let originalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        XCTAssertNotNil(originalImage)

        // 2. Convert to JPEG data
        guard let imageData = originalImage!.jpegData(compressionQuality: 0.8) else {
            XCTFail("Failed to get JPEG data")
            return
        }

        // 3. Use a test key
        let key = SymmetricKey(size: .bits256)

        // 4. Encrypt using AESHelper (same as CameraUploader)
        guard let encryptedData = AESHelper.encrypt(data: imageData, key: key) else {
            XCTFail("Encryption failed")
            return
        }

        // 5. Decrypt using ChartImageDecryptor
        let decryptedImage = ChartImageDecryptor.decryptImageData(encryptedData, with: key)
        XCTAssertNotNil(decryptedImage, "Decryption failed")

        // 6. Optionally, compare pixel data or just size
        XCTAssertEqual(decryptedImage!.size, originalImage!.size, "Image size mismatch after decrypt")
    }
}

