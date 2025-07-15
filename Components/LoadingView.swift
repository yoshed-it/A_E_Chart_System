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
        VStack(spacing: PluckrTheme.spacing * 2) {
            // Loading indicator
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: PluckrTheme.primaryColor))
            
            // Loading message
            Text(message)
                .font(.journalBody)
                .foregroundColor(PluckrTheme.secondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding(PluckrTheme.padding * 2)
        .background(Color.white)
        .cornerRadius(PluckrTheme.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    LoadingView(message: "Loading clients...")
        .padding()
        .background(PluckrTheme.backgroundColor)
} 