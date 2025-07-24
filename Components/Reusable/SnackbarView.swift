/// Used in: ClientsListView (Views/Clients/ClientListView.swift)
import SwiftUI

struct SnackbarView: View {
    let message: String
    let onUndo: (() -> Void)?
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            VStack {
                Spacer()
                HStack {
                    Text(message)
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(.white)
                    Spacer()
                    if let onUndo = onUndo {
                        Button("Undo", action: onUndo)
                            .font(PluckrTheme.captionFont().bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.85))
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: isPresented)
        }
    }
} 