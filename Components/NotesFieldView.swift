import SwiftUI

/**
 *A styled notes input component*
 
 This component provides a consistent notes input field using the Pluckr theme.
 
 ## Usage
 ```swift
 NotesFieldView(notes: $viewModel.notes)
 ```
 */
struct NotesFieldView: View {
    @Binding var notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clinical Notes")
                .pluckrSectionHeader()
            
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
                .scrollContentBackground(.hidden) // Hide the default TextEditor background
        }
    }
}

#Preview {
    NotesFieldView(notes: .constant("Sample notes text"))
        .padding()
        .background(PluckrTheme.background)
}
