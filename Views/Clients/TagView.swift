import SwiftUI

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .clipShape(Capsule())
            .font(.caption)
    }
}
