// Used in ClientJournalView for displaying client header info
import SwiftUI

struct ClientJournalHeaderSection: View {
    @Binding var client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.fullName)
                .font(PluckrTheme.displayFont())
                .foregroundColor(PluckrTheme.textPrimary)
            if let lastSeen = client.lastSeenAt {
                Text("Last Seen: \(lastSeen.formatted(date: .abbreviated, time: .omitted))")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                if let phone = client.phone, !phone.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text(phone)
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                }
                if let email = client.email, !email.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text(email)
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                }
            }
        }
        // .padding(.horizontal, PluckrTheme.horizontalPadding)
        .padding(.top, PluckrTheme.verticalPadding)
        .padding(.bottom, 16)
    }
} 