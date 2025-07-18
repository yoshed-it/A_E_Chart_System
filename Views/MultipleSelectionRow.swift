import SwiftUI

struct MultipleSelectionRow: View {
    let client: Client
    let isSelected: Bool
    let isDisabled: Bool
    let inFolio: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(client.fullName)
                    .foregroundColor(isDisabled ? .gray : .primary)
                Spacer()
                if inFolio {
                    Label("In Folio", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
