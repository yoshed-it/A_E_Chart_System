import SwiftUI

/**
 *Displays the recent clients section with search and list*
 
 This component shows a list of recent clients with search functionality
 and loading states.
 
 ## Usage
 ```swift
 ProviderRecentClientsSectionView(
     clients: filteredClients,
     isLoading: isLoading,
     onClientTap: { client in /* navigate */ }
 )
 ```
 
 ## Used in
 - ProviderHomeView
 */
struct ProviderRecentClientsSectionView: View {
    let clients: [Client]
    let isLoading: Bool
    let onClientTap: (Client) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - Always visible with transparent background
            HStack {
                Text("Recent Clients")
                    .font(PluckrTheme.subheadingFont())
                    .foregroundColor(PluckrTheme.textPrimary)
                Spacer()
                NavigationLink(destination: ClientsListView()) {
                    Text("See All")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.accent)
                }
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.bottom, 16) // Space between header and content
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 0) {
                    if isLoading {
                        LoadingView(message: "Loading clients...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    } else if clients.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("No clients yet")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Text("Add your first client to get started")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        // Client cards with proper spacing
                        VStack(spacing: 12) {
                            ForEach(clients.prefix(5)) { client in
                                ClientCardView(client: client) {
                                    onClientTap(client)
                                }
                            }
                        }
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                        .padding(.bottom, 20) // Bottom padding for scroll area
                    }
                }
            }
            .scrollClipDisabled(true) // Prevent shadow clipping (iOS 17+)
        }
    }
} 
