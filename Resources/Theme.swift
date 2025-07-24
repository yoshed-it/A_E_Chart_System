// Pluckr Theme System
// -------------------
// Use PluckrTheme for all colors, fonts, spacing, corners, and shadows.
// - Spacing: PluckrTheme.verticalPadding, PluckrTheme.horizontalPadding
// - Corners: PluckrTheme.cardCornerRadius, PluckrTheme.tagCornerRadius, etc.
// - Colors: PluckrTheme.textPrimary, textSecondary, accent, error, card, background, borderColor
// - Fonts: PluckrTheme.displayFont(), headingFont(), subheadingFont(), bodyFont(), captionFont(), tagFont()
// - Backgrounds: PluckrTheme.background, PluckrTheme.card
// - Use .pluckrCard(), .pluckrButton(), .pluckrTag(), .pluckrSectionHeader(), .pluckrTextField(), .pluckrJournalBox(), .pluckrImage() for consistent styling.
// - Never use old theme members like spacing, padding, borderColor, or font extensions like .journalCaption.
//
// To migrate a view: Replace all old theme/color/font/spacing references with the new helpers above.

import SwiftUI

// MARK: - Pluckr Theme

struct PluckrTheme {
    // Colors
    static let background = Color("PluckrBackrgound") // light cream
    static let card = Color("PluckrCard") // slightly darker cream
    static let tagGreen = Color("PluckrTagGreen") // muted sage
    static let tagBeige = Color("PluckrTagBeige") // muted beige
    static let tagTan = Color("PluckrTagTan") // muted tan
    static let accent = Color("PluckrAccent") // muted green
    static let button = Color("PluckrButton") // muted green
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let shadow = Color.black.opacity(0.12) // Enhanced shadow opacity
    static let error = Color.red
    static let borderColor = Color.gray.opacity(0.18) // universal border color
    
    // Spacing
    static let horizontalPadding: CGFloat = 32
    static let verticalPadding: CGFloat = 24
    static let cardCornerRadius: CGFloat = 24
    static let cardShadowRadius: CGFloat = 16 // Enhanced shadow radius
    static let cardShadowY: CGFloat = 8 // Enhanced shadow Y offset
    static let tagCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 16
    static let buttonShadowRadius: CGFloat = 8 // Enhanced button shadow
    static let buttonShadowY: CGFloat = 4 // Enhanced button shadow Y
    
    // Enhanced Shadow System
    static let shadowSmall = Color.black.opacity(0.08)
    static let shadowMedium = Color.black.opacity(0.12)
    static let shadowLarge = Color.black.opacity(0.16)
    static let shadowRadiusSmall: CGFloat = 8
    static let shadowRadiusMedium: CGFloat = 16
    static let shadowRadiusLarge: CGFloat = 24
    static let shadowYSmall: CGFloat = 2
    static let shadowYMedium: CGFloat = 8
    static let shadowYLarge: CGFloat = 12
    
    // Fonts
    static func headingFont(size: CGFloat = 38) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    static func subheadingFont(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    static func bodyFont(size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    static func sectionHeaderFont(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    static func tagFont(size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    static func displayFont(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    static func captionFont(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    // Gradient
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color("PluckrBackrgound").opacity(0.98), Color("PluckrCard").opacity(0.96)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Divider
    static var divider: some View {
        Divider()
            .background(Color.black.opacity(0.07))
            .padding(.vertical, 4)
    }
    static let spacing: CGFloat = 16
    static let padding: CGFloat = 20
    static let cornerRadius: CGFloat = 24 // 2xl, matches clinical iOS style
    static let secondaryColor = Color("PluckrTagTan") // Adjust if you want a different secondary color
}

// MARK: - Color Extensions

// MARK: - View Modifiers
struct PluckrCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowMedium, radius: PluckrTheme.shadowRadiusMedium, x: 0, y: PluckrTheme.shadowYMedium)
            .padding(.vertical, 8)
    }
}

struct PluckrCardElevated: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowLarge, radius: PluckrTheme.shadowRadiusLarge, x: 0, y: PluckrTheme.shadowYLarge)
            .padding(.vertical, 8)
    }
}

struct PluckrCardSubtle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowSmall, radius: PluckrTheme.shadowRadiusSmall, x: 0, y: PluckrTheme.shadowYSmall)
            .padding(.vertical, 8)
    }
}

struct PluckrTag: ViewModifier {
    var color: Color
    var textColor: Color = .primary
    func body(content: Content) -> some View {
        content
            .font(PluckrTheme.tagFont())
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .foregroundColor(textColor)
            .cornerRadius(PluckrTheme.tagCornerRadius)
            .shadow(color: PluckrTheme.shadowSmall, radius: 4, x: 0, y: 2)
    }
}

struct PluckrButton: ViewModifier {
    var small: Bool = false
    func body(content: Content) -> some View {
        content
            .font(small ? PluckrTheme.bodyFont(size: 17) : .headline)
            .padding(.horizontal, small ? 16 : 24)
            .padding(.vertical, small ? 8 : 10)
            .background(PluckrTheme.button)
            .foregroundColor(.white)
            .cornerRadius(PluckrTheme.buttonCornerRadius)
            .shadow(color: PluckrTheme.shadowMedium, radius: PluckrTheme.buttonShadowRadius, x: 0, y: PluckrTheme.buttonShadowY)
    }
}

struct PluckrSectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(PluckrTheme.sectionHeaderFont())
            .textCase(.uppercase)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
    }
}

struct PluckrImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: PluckrTheme.shadowMedium, radius: 12, x: 0, y: 6)
    }
}

struct PluckrJournalBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(PluckrTheme.card.opacity(0.85))
                    .shadow(color: PluckrTheme.shadowLarge, radius: 32, x: 0, y: 12)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
    }
}

struct LargeTapArea: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .padding(8)
    }
}

struct PluckrTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(12)
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                    .stroke(PluckrTheme.accent.opacity(0.18), lineWidth: 1)
            )
            .font(PluckrTheme.bodyFont())
            .foregroundColor(PluckrTheme.textPrimary)
            .shadow(color: PluckrTheme.shadowSmall, radius: 6, x: 0, y: 3)
    }
}

// MARK: - View Extension Helpers
extension View {
    func pluckrCard() -> some View { self.modifier(PluckrCard()) }
    func pluckrCardElevated() -> some View { self.modifier(PluckrCardElevated()) }
    func pluckrCardSubtle() -> some View { self.modifier(PluckrCardSubtle()) }
    func pluckrTag(color: Color, textColor: Color = .primary) -> some View { self.modifier(PluckrTag(color: color, textColor: textColor)) }
    func pluckrButton(small: Bool = false) -> some View { self.modifier(PluckrButton(small: small)) }
    func pluckrSectionHeader() -> some View { self.modifier(PluckrSectionHeader()) }
    func pluckrImage() -> some View { self.modifier(PluckrImage()) }
    func pluckrJournalBox() -> some View { self.modifier(PluckrJournalBox()) }
    func largeTapArea() -> some View { self.modifier(LargeTapArea()) }
    func pluckrTextField() -> some View { self.textFieldStyle(PluckrTextFieldStyle()) }
}

// Utility: Color.isLight
extension Color {
    var isLight: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        // Perceived brightness formula
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.7
    }
}

extension Font {
    static var journalCaption: Font {
        .system(size: 14, weight: .regular, design: .default)
    }
}

struct PluckrSwipeActionStyle {
    static let editColor = Color("PluckrAccent") 
    static let deleteColor = Color("PluckrTagRed")
    static let archiveGray = Color("ArchiveGray")
    static let archiveOlive = Color("ArchiveOlive")
    static let shadowColor = Color.black.opacity(0.15)
    static let shadowRadius: CGFloat = 6
    static let shadowY: CGFloat = 2
}

extension View {
    /// Applies a consistent drop shadow for swipe actions. You can override color, radius, and y-offset if needed.
    func pluckrSwipeActionShadow(
        color: Color = PluckrSwipeActionStyle.shadowColor,
        radius: CGFloat = PluckrSwipeActionStyle.shadowRadius,
        y: CGFloat = PluckrSwipeActionStyle.shadowY
    ) -> some View {
        self.shadow(color: color, radius: radius, x: 0, y: y)
    }
}

