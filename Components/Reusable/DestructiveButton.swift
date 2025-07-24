/// Used in: ClientDetailView (Views/Clients/ClientDetailView.swift), and anywhere a destructive action is needed
import SwiftUI

struct DestructiveButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Label(title, systemImage: systemImage)
        }
    }
} 