import Foundation

struct TagConstants {
    
    // MARK: - Client Tags (Long-term characteristics)
    static let defaultClientTags: [Tag] = [
        Tag(label: "Phalloplasty Prep", colorHex: "#FFB3BA"),
        Tag(label: "Top Surgery", colorHex: "#BAFFC9"),
        Tag(label: "Sensitive Client", colorHex: "#BAE1FF"),
        Tag(label: "No-Show Risk", colorHex: "#FFFFBA"),
        Tag(label: "Prefers Evenings", colorHex: "#FFB3F7"),
        Tag(label: "Coarse Hair", colorHex: "#E6B3FF"),
        Tag(label: "Dry Skin", colorHex: "#B3FFE6"),
        Tag(label: "New Client", colorHex: "#FFE6B3"),
        Tag(label: "Returning Client", colorHex: "#B3E6FF"),
        Tag(label: "VIP", colorHex: "#FFB3D9")
    ]
    
    // MARK: - Chart Tags (Treatment-specific)
    static let defaultChartTags: [Tag] = [
        Tag(label: "Sensitive", colorHex: "#FFB3BA"),
        Tag(label: "Bleeding", colorHex: "#BAFFC9"),
        Tag(label: "Consult", colorHex: "#BAE1FF"),
        Tag(label: "Numbness", colorHex: "#FFFFBA"),
        Tag(label: "Healed Well", colorHex: "#FFB3F7"),
        Tag(label: "Follow-up", colorHex: "#E6B3FF"),
        Tag(label: "Complications", colorHex: "#B3FFE6"),
        Tag(label: "Quick Session", colorHex: "#FFE6B3"),
        Tag(label: "Extended Session", colorHex: "#B3E6FF"),
        Tag(label: "Test Patch", colorHex: "#FFB3D9")
    ]
    
    // MARK: - Validation
    static let maxTagLabelLength = 25
    static let minTagLabelLength = 1
} 