import SwiftUI

// MARK: - TreatmentAreaField
struct TreatmentAreaField: View {
    @Binding var treatmentArea: String

    var body: some View {
        Section(header: Text("Treatment Area")) {
            TextField("e.g. Chin, Upper Lip", text: $treatmentArea)
                .textInputAutocapitalization(.words)
        }
    }
}
