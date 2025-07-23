import SwiftUI

/// A reusable card for displaying or editing clinical notes.
struct NotesCard: View {
    enum Mode {
        case view(String)
        case edit(Binding<String>)
    }
    let mode: Mode

    var body: some View {
        Group {
            switch mode {
            case .view(let notes):
                Text(notes)
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .edit(let binding):
                TextEditor(text: binding)
                    .font(PluckrTheme.bodyFont())
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(PluckrTheme.textPrimary)
            }
        }
        .padding(16)
        .background(PluckrTheme.card)
        .cornerRadius(PluckrTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                .stroke(PluckrTheme.borderColor, lineWidth: 1)
        )
        .shadow(color: PluckrTheme.shadowSmall, radius: PluckrTheme.shadowRadiusSmall, x: 0, y: PluckrTheme.shadowYSmall)
    }
}

#Preview {
    VStack(spacing: 24) {
        NotesCard(mode: .view("Patient tolerated treatment well. No adverse reactions."))
        NotesCard(mode: .edit(.constant("Editable notes go here.")))
    }
    .padding()
    .background(PluckrTheme.background)
} 