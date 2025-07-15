import SwiftUI

/**
 *Treatment area input field component*
 
 This component provides a text field for specifying the treatment area
 with proper styling and validation.
 
 ## Usage
 ```swift
 TreatmentAreaField(treatmentArea: $viewModel.treatmentArea)
 ```
 */
struct TreatmentAreaField: View {
    @Binding var treatmentArea: String

    var body: some View {
        VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
            Text("Treatment Area")
                .font(.journalCaption)
                .foregroundColor(PluckrTheme.secondaryColor)
                .padding(.horizontal, PluckrTheme.padding)
            
            TextField("e.g. Chin, Upper Lip, Bikini Line", text: $treatmentArea)
                .font(.journalBody)
                .textInputAutocapitalization(.words)
                .padding(PluckrTheme.padding)
                .background(Color.white)
                .cornerRadius(PluckrTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PluckrTheme.cornerRadius)
                        .stroke(PluckrTheme.borderColor, lineWidth: 1)
                )
                .padding(.horizontal, PluckrTheme.padding)
        }
        .padding(.vertical, PluckrTheme.spacing)
        .background(Color.white)
        .cornerRadius(PluckrTheme.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    TreatmentAreaField(treatmentArea: .constant("Upper Lip"))
        .padding()
        .background(PluckrTheme.backgroundColor)
}
