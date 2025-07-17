import SwiftUI

struct FolioCardView: View {
    let client: Client
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ClientCardView(client: client) {
                onTap()
            }
            .accessibilityLabel("Folio client: \(client.fullName)")
            .accessibilityAddTraits(.isButton)
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                    .stroke(PluckrTheme.accent.opacity(0.3), lineWidth: 1)
            )
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(PluckrTheme.accent)
                    .background(Color.white.clipShape(Circle()))
                    .shadow(color: PluckrTheme.shadowSmall, radius: 2, x: 0, y: 1)
            }
            .offset(x: 8, y: -8)
            .accessibilityLabel("Remove \(client.fullName) from folio")
            .accessibilityAddTraits(.isButton)
        }
        .frame(width: 200)
    }
}

struct FolioSectionView: View {
    let clients: [Client]
    let onClientTap: (Client) -> Void
    let onClientRemove: (Client) -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Folio")
                    .font(PluckrTheme.subheadingFont())
                    .foregroundColor(PluckrTheme.textPrimary)
                Spacer()
                Button(action: onAddTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(PluckrTheme.accent)
                            .font(PluckrTheme.subheadingFont(size: 18))
                        Text("Add")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PluckrTheme.accent.opacity(0.1))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Add client to Daily Folio")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            
            if clients.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.25))
                    Text("No clients in your folio yet.")
                        .font(PluckrTheme.subheadingFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                    Text("Tap "+" to add clients for today's workflow.")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                        .italic()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(clients) { client in
                            FolioCardView(
                                client: client,
                                onTap: { onClientTap(client) },
                                onRemove: { onClientRemove(client) }
                            )
                        }
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.bottom, PluckrTheme.verticalPadding)
    }
} 