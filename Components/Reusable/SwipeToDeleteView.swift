import SwiftUI

struct SwipeToDeleteView<Content: View>: View {
    let onDelete: () -> Void
    let onEdit: () -> Void
    let content: () -> Content

    var body: some View {
        ZStack {
            content()
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.accentColor)
        }
    }
}
