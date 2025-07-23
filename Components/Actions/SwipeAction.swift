import SwiftUI

struct SwipeAction: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String
    let tint: Color?
    let role: ButtonRole?
    let action: () -> Void

    var button: some View {
        Button(role: role, action: action) {
            Label(label, systemImage: systemImage)
        }
        .tint(tint)
    }
} 