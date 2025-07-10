import SwiftUI

// MARK: - NotesField
struct NotesFieldView: View {
    @Binding var notes: String

    var body: some View {
        Section(header: Text("Notes")) {
            TextEditor(text: $notes)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2))
                )
        }
    }
}
