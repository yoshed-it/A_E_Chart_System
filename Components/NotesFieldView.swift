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
        VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
            Text("Notes")
                .font(.journalSubtitle)
                .foregroundColor(PluckrTheme.primaryColor)
                .padding(.horizontal, PluckrTheme.padding)
            
            TextEditor(text: $notes)
                .font(.journalBody)
                .padding(PluckrTheme.padding)
                .background(Color.white)
                .cornerRadius(PluckrTheme.cornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: PluckrTheme.cornerRadius)
                        .stroke(PluckrTheme.secondaryColor.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, PluckrTheme.padding)
    }
}

#Preview {
    NotesFieldView(notes: .constant("Sample notes text"))
        .padding()
        .background(PluckrTheme.backgroundColor)
}
