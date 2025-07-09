import SwiftUI

struct DCLevelPicker: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("DC (Galvanic): \(String(format: "%.2f", value)) mA")
            Slider(value: $value, in: 0...3, step: 0.01)
        }
    }
}
