import SwiftUI

/**
 *Client information card component*
 
 This component displays client information in a clean, professional
 card format suitable for the clinical journal interface.
 
 ## Usage
 ```swift
 ClientCardView(client: client) {
     // Handle client selection
 }
 ```
 */
struct ClientCardView: View {
    let client: Client
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                // Client Name and Pronouns
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.fullName)
                            .font(PluckrTheme.subheadingFont())
                            .foregroundColor(PluckrTheme.textPrimary)
                            .lineLimit(1)
                        
                        if let pronouns = client.pronouns, !pronouns.isEmpty {
                            Text(pronouns)
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Last seen indicator
                    VStack(alignment: .trailing, spacing: 4) {
                        if let lastSeen = client.lastSeenAt {
                            Text("Last seen")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            
                            Text(formatLastSeenDate(lastSeen))
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        } else {
                            Text("New client")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.accent)
                        }
                    }
                }
                
                // Created by info
                if let createdByName = client.createdByName, !createdByName.isEmpty {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(PluckrTheme.textSecondary)
                        
                        Text("Added by \(createdByName)")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        
                        Spacer()
                    }
                }
                
                // Chart count indicator (if available)
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.accent)
                    
                    Text("View charts")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.accent)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.textSecondary)
                }
            }
            .padding(PluckrTheme.verticalPadding)
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowMedium, radius: PluckrTheme.shadowRadiusMedium, x: 0, y: PluckrTheme.shadowYMedium)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Client card for \(client.fullName). Tap to view details.")
        .accessibilityAddTraits(.isButton)
        .dynamicTypeSize(.large ... .xxLarge)
    }

    // MARK: - Helper Methods
    private func formatLastSeenDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            return "\(days) days ago"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ClientCardView(
            client: Client(
                id: "1",
                firstName: "Alex",
                lastName: "Johnson",
                pronouns: "they/them",
                createdByName: "Dr. Smith",
                lastSeenAt: Date().addingTimeInterval(-86400), // 1 day ago
                createdAt: Date()
            )
        ) {
            print("Client tapped")
        }
        
        ClientCardView(
            client: Client(
                id: "2",
                firstName: "Sarah",
                lastName: "Williams",
                pronouns: "she/her",
                createdByName: "Dr. Smith",
                lastSeenAt: nil,
                createdAt: Date()
            )
        ) {
            print("Client tapped")
        }
    }
    .padding()
    .background(PluckrTheme.background)
} 