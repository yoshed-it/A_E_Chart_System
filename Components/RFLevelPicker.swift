import SwiftUI

struct RFLevelPicker: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("RF (Thermolysis): \(String(format: "%.1f", value)) W")
            Slider(value: $value, in: 0...8, step: 0.1)
        }
    }
}
