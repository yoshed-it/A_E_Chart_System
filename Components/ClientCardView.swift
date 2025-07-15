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
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                // Client Name and Pronouns
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.fullName)
                            .font(.journalSubtitle)
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.primaryColor)
                            .lineLimit(1)
                        
                        if let pronouns = client.pronouns, !pronouns.isEmpty {
                            Text(pronouns)
                                .font(.journalCaption)
                                .foregroundColor(PluckrTheme.secondaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Last seen indicator
                    VStack(alignment: .trailing, spacing: 4) {
                        if let lastSeen = client.lastSeenAt {
                            Text("Last seen")
                                .font(.journalCaption)
                                .foregroundColor(PluckrTheme.secondaryColor)
                            
                            Text(lastSeen, style: .relative)
                                .font(.journalCaption)
                                .foregroundColor(PluckrTheme.primaryColor)
                        } else {
                            Text("New client")
                                .font(.journalCaption)
                                .foregroundColor(PluckrTheme.accentColor)
                        }
                    }
                }
                
                // Created by info
                if let createdByName = client.createdByName, !createdByName.isEmpty {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                        
                        Text("Added by \(createdByName)")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                        
                        Spacer()
                    }
                }
                
                // Chart count indicator (if available)
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.accentColor)
                    
                    Text("View charts")
                        .font(.journalCaption)
                        .foregroundColor(PluckrTheme.accentColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.secondaryColor)
                }
            }
            .padding(PluckrTheme.padding)
            .background(Color.white)
            .cornerRadius(PluckrTheme.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
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
    .background(PluckrTheme.backgroundColor)
} 