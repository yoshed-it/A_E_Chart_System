import SwiftUI

struct NotesFieldView: View {
    @Binding var notes: String

    var body: some View {
        TextEditor(text: $notes)
            .font(PluckrTheme.bodyFont())
            .frame(minHeight: 120)
            .padding(16)
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                    .stroke(PluckrTheme.borderColor, lineWidth: 1)
            )
            .shadow(color: PluckrTheme.shadowSmall, radius: PluckrTheme.shadowRadiusSmall, x: 0, y: PluckrTheme.shadowYSmall)
            .foregroundColor(PluckrTheme.textPrimary)
            .scrollContentBackground(.hidden)
    }
}

#Preview {
    NotesFieldView(notes: .constant("Sample notes text"))
        .padding()
        .background(PluckrTheme.background)
} 