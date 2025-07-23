import SwiftUI

struct SwipeableRow<Content: View>: View {
    let leadingActions: [SwipeAction]
    let trailingActions: [SwipeAction]
    let content: () -> Content

    var body: some View {
        content()
            .contentShape(Rectangle())
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                ForEach(leadingActions) { $0.button }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                ForEach(trailingActions) { $0.button }
            }
    }
} 