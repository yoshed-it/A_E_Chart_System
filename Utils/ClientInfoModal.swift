import SwiftUI

struct ClientInfoModal: View {
    let fullName: String
    let pronouns: String?
    let createdByName: String?
    let createdAt: Date?
    let lastSeenAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(fullName)
                .font(.title)
                .bold()

            if let pronouns = pronouns, !pronouns.isEmpty {
                Text(pronouns)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            if let createdByName = createdByName {
                Text("🧾 Created by: \(createdByName)")
            }

            if let createdAt = createdAt {
                Text("📅 Created on: \(formatted(createdAt))")
            }

            if let lastSeenAt = lastSeenAt {
                Text("⏰ Last seen: \(formatted(lastSeenAt))")
            }

            Spacer()
        }
        .padding()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
