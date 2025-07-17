import SwiftUI

/**
 *A styled error display component*
 
 This component provides a consistent way to display error messages
 throughout the app using the Pluckr theme.
 
 ## Usage
 ```swift
 ErrorView(error: "Something went wrong")
 ```
 */
struct ErrorView: View {
    let error: String?

    var body: some View {
        if let error = error, !error.isEmpty {
            HStack(spacing: PluckrTheme.verticalPadding) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                
                Text(error)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(PluckrTheme.horizontalPadding)
            .pluckrCard()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ErrorView(error: "This is an error message")
        ErrorView(error: nil)
        ErrorView(error: "")
    }
    .padding()
    .background(PluckrTheme.background)
}
