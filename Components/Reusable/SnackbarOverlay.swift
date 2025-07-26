import SwiftUI

struct SnackbarOverlay: View {
    let message: String
    let lastAction: FolioAction?
    let onUndo: (() -> Void)?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(message)
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.white)
                
                Spacer()
                
                if lastAction != nil && onUndo != nil {
                    Button("Undo") {
                        onUndo?()
                        onDismiss()
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.white)
                    .underline()
                }
            }
            .padding()
            .background(PluckrTheme.accent)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.horizontal)
            .padding(.bottom, 100) // Account for safe area
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
} 