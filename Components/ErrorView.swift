import SwiftUI

// MARK: - ErrorSection
struct ErrorView: View {
    let error: String?

    var body: some View {
        if let error = error, !error.isEmpty {
            Section {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
        }
    }
}
