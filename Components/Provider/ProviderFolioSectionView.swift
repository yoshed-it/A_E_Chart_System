import SwiftUI

/**
 *Displays the daily folio section with clients and add button*
 
 This component shows the current clients in the daily folio and provides
 functionality to add/remove clients and navigate to client details.
 
 ## Usage
 ```swift
 ProviderFolioSectionView(
     clients: dailyFolioClients,
     onClientTap: { client in /* navigate */ },
     onClientRemove: { client in /* remove */ },
     onAddTap: { /* show picker */ }
 )
 ```
 
 ## Used in
 - ProviderHomeView
 */
struct ProviderFolioSectionView: View {
    let clients: [Client]
    let onClientTap: (Client) -> Void
    let onClientRemove: (Client) -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("DAILY FOLIO")
                    .pluckrSectionHeader()
                
                Spacer()
                
                Button(action: onAddTap) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                        .font(PluckrTheme.subheadingFont(size: 22))
                }
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.bottom, 8) // Space between header and content
            
            if clients.isEmpty {
                emptyFolioView
            } else {
                folioClientsList
            }
        }
    }
    
    // MARK: - Computed Views
    
    private var emptyFolioView: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(PluckrTheme.textSecondary)
            
            Text("No clients in folio")
                .font(PluckrTheme.bodyFont())
                .foregroundColor(PluckrTheme.textSecondary)
            
            Text("Tap + to add clients to your daily folio")
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(PluckrTheme.card)
        .cornerRadius(16)
        .padding(.horizontal, PluckrTheme.horizontalPadding)
    }
    
    private var folioClientsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(clients) { client in
                    FolioClientCard(
                        client: client,
                        onTap: { onClientTap(client) },
                        onRemove: { onClientRemove(client) }
                    )
                }
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.vertical, 8) // Extra padding for shadows
        }
        .scrollClipDisabled(true) // Prevent shadow clipping (iOS 17+)
    }
}

// MARK: - FolioClientCard
struct FolioClientCard: View {
    let client: Client
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(client.fullName)
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(PluckrTheme.textSecondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if let lastSeen = client.lastSeenAt {
                    Text("Last seen: \(lastSeen, style: .relative)")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                }
            }
            .padding(16)
            .frame(width: 200)
            .background(PluckrTheme.card)
            .cornerRadius(12)
            .shadow(color: PluckrTheme.shadow, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 