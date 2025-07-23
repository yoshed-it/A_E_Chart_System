import SwiftUI

/**
 *Loading state display component*
 
 This component provides a consistent loading experience throughout
 the app with proper styling and animations.
 
 ## Usage
 ```swift
 LoadingView(message: "Loading clients...")
 ```
 */
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: PluckrTheme.verticalPadding) {
            // Loading indicator
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: PluckrTheme.textPrimary))
            
            // Loading message
            Text(message)
                .font(PluckrTheme.bodyFont())
                .foregroundColor(PluckrTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PluckrTheme.horizontalPadding)
        .pluckrCard()
    }
}

#Preview {
    LoadingView(message: "Loading clients...")
        .padding()
        .background(PluckrTheme.background)
} 