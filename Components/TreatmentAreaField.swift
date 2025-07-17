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
        VStack(alignment: .leading, spacing: 8) {
            Text("Treatment Area")
                .pluckrSectionHeader()
            
            TextField("e.g. Chin, Upper Lip, Bikini Line", text: $treatmentArea)
                .pluckrTextField()
        }
    }
}

#Preview {
    TreatmentAreaField(treatmentArea: .constant("Upper Lip"))
        .padding()
        .background(PluckrTheme.background)
}
