import Foundation

struct TagConstants {
    
    // MARK: - Client Tags (Long-term characteristics)
    static let defaultClientTags: [Tag] = [
        Tag(label: "Phalloplasty Prep", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "Top Surgery", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Sensitive Client", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "No-Show Risk", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "Prefers Evenings", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Coarse Hair", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "Dry Skin", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "New Client", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Returning Client", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "VIP", colorNameOrHex: "PluckrTagGreen")
    ]
    
    // MARK: - Chart Tags (Treatment-specific)
    static let defaultChartTags: [Tag] = [
        Tag(label: "Sensitive", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "Bleeding", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Consult", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "Numbness", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "Healed Well", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Follow-up", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "Complications", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "Quick Session", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Extended Session", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "Test Patch", colorNameOrHex: "PluckrTagGreen")
    ]
    
    // MARK: - Validation
    static let maxTagLabelLength = 25
    static let minTagLabelLength = 1
    
    static let tagColors: [String] = [
        "PluckrTagGreen",    // Muted green
        "PluckrTagBeige",    // Soft beige
        "PluckrTagTan",      // Light tan
        "PluckrTagRed",      // Muted clinical red
        "PluckrTagYellow",   // Soft yellow
        "PluckrTagBlue",     // Muted blue
        "PluckrTagPurple",   // Muted purple
        "PluckrTagTeal",     // Muted teal
        "PluckrTagOrange"    // Soft orange
    ]
} 