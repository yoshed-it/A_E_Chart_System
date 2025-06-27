//
//  ClientInfoModal.swift
//  A_E_Charting
//
//  Created by Susan Bailey on 6/27/25.
//

import SwiftUI

struct ClientInfoModal: View {
    let client: Client

    var body: some View {
        VStack(spacing: 16) {
            Text(client.name)
                .font(.largeTitle)
                .bold()

            Text("Pronouns: \(client.pronouns)")
                .font(.subheadline)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("🧾 Created by: \(client.createdByName)")
                Text("📅 Created at: \(formatted(client.createdAt))")
                Text("⏰ Last seen: \(formatted(client.lastSeenAt))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button("Close") {
                // Sheet will auto-dismiss on parent binding change
            }
            .padding()
        }
        .padding()
    }

    func formatted(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
