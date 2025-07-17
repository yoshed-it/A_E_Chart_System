import Foundation
import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var label: String
    var colorNameOrHex: String
    
    init(id: String = UUID().uuidString, label: String, colorNameOrHex: String = Tag.randomAssetColor()) {
        self.id = id
        self.label = label
        self.colorNameOrHex = colorNameOrHex
    }
    
    // MARK: - Color Management
    var color: Color {
        // Try asset name first
        if UIColor(named: colorNameOrHex) != nil {
            return Color(colorNameOrHex)
        }
        // Fallback to hex
        return Color(hex: colorNameOrHex) ?? .gray
    }
    
    static func randomAssetColor() -> String {
        let assetColors = [
            "PluckrTagGreen", "PluckrTagBeige", "PluckrTagTan",
            "PluckrTagRed", "PluckrTagYellow", "PluckrTagBlue",
            "PluckrTagPurple", "PluckrTagTeal", "PluckrTagOrange"
        ]
        return assetColors.randomElement() ?? "PluckrTagGreen"
    }
    
    // MARK: - Firestore Integration
    init?(data: [String: Any], id: String?) {
        guard let label = data["label"] as? String,
              let documentId = id, !documentId.isEmpty else {
            return nil
        }
        self.id = documentId
        self.label = label
        self.colorNameOrHex = data["colorNameOrHex"] as? String ?? Tag.randomAssetColor()
    }
    
    func toDict() -> [String: Any] {
        return [
            "label": label,
            "colorNameOrHex": colorNameOrHex
        ]
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 