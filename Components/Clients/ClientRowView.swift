/// Used in: ClientsListView (Views/Clients/ClientListView.swift)
import SwiftUI

struct ClientRowView: View {
    let client: Client
    let isInFolio: Bool
    let onSelect: () -> Void
    let onAddToFolio: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(client.fullName)
                            .font(PluckrTheme.subheadingFont())
                            .foregroundColor(PluckrTheme.textPrimary)
                        if let pronouns = client.pronouns, !pronouns.isEmpty {
                            Text(pronouns)
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
            if isInFolio {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(PluckrTheme.accent)
                    .padding(.trailing, 8)
                    .accessibilityLabel("In Folio")
            } else {
                Button(action: onAddToFolio) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(PluckrTheme.accent)
                        .font(.title2)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 8)
                .accessibilityLabel("Add to Folio")
            }
        }
        .background(PluckrTheme.card)
        .cornerRadius(PluckrTheme.cardCornerRadius)
        .shadow(color: PluckrTheme.shadowSmall.opacity(0.5), radius: 4, x: 0, y: 1)
        .padding(.vertical, 4)
    }
} 