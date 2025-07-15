import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let mossGreen = Color(red: 0.4, green: 0.6, blue: 0.4)                // Primary
    static let warmGray = Color(red: 0.94, green: 0.94, blue: 0.92)              // Background
    static let softOlive = Color(red: 0.78, green: 0.80, blue: 0.72)             // Accent
    static let gentleOrange = Color(red: 0.95, green: 0.8, blue: 0.6)            // Optional highlight
    static let watercolorShadow = Color.black.opacity(0.05)                     // Subtle watercolor wash

    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)              // Charcoal
    static let textSecondary = Color.gray.opacity(0.7)
    static let border = Color.gray.opacity(0.2)
    static let error = Color.red.opacity(0.8)
}

// MARK: - Font Extensions
extension Font {
    static let journalTitle = Font.system(size: 28, weight: .bold, design: .serif)
    static let journalSubtitle = Font.system(size: 18, weight: .semibold, design: .serif)
    static let journalBody = Font.system(size: 16, weight: .regular, design: .default)
    static let journalCaption = Font.system(size: 14, weight: .light, design: .default)
}

// MARK: - Theme Tokens
struct PluckrTheme {
    // Colors
    static let primaryColor = Color.mossGreen
    static let secondaryColor = Color.warmGray
    static let accentColor = Color.softOlive
    static let backgroundColor = Color.warmGray
    static let borderColor = Color.border
    static let textColor = Color.textPrimary
    static let errorColor = Color.error
    static let shadowColor = Color.watercolorShadow

    // Typography
    static let titleFont = Font.journalTitle
    static let subtitleFont = Font.journalSubtitle
    static let bodyFont = Font.journalBody
    static let captionFont = Font.journalCaption

    // Layout
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 10
    static let shadowRadius: CGFloat = 6

    // Animation
    static let animation = Animation.easeInOut(duration: 0.3)
}

// MARK: - Button Style
struct PluckrButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, PluckrTheme.padding)
            .padding(.vertical, 12)
            .background(PluckrTheme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(PluckrTheme.cornerRadius)
            .shadow(color: PluckrTheme.shadowColor, radius: 2, y: 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - TextField Style
struct PluckrTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(PluckrTheme.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: PluckrTheme.cornerRadius).stroke(PluckrTheme.borderColor))
            .shadow(color: PluckrTheme.shadowColor, radius: 2, x: 0, y: 1)
    }
}
