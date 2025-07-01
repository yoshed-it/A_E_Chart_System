import SwiftUI

struct SwipeToDeleteView<Content: View>: View {
    let onDelete: () -> Void
    let content: () -> Content

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity)

            content()
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
