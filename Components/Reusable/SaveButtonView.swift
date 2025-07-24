/// Used in: ClientDetailView (Views/Clients/ClientDetailView.swift), and anywhere a save button with progress is needed
import SwiftUI

struct SaveButtonView: View {
    let isSaving: Bool
    let action: () -> Void
    let title: String

    var body: some View {
        Button(action: action) {
            if isSaving {
                ProgressView()
            } else {
                Text(title)
            }
        }
    }
}
