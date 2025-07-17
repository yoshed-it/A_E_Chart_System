/// Used in: ClientJournalView (Views/Clients/ClientJournalView.swift)
import SwiftUI

struct ClientJournalTagsSection: View {
    let clientTags: [Tag]
    let onShowTagPicker: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CLIENT TAGS")
                    .pluckrSectionHeader()
                Spacer()
                Button(action: onShowTagPicker) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                        .font(PluckrTheme.subheadingFont(size: 22))
                }
            }
            if clientTags.isEmpty {
                Text("No tags added yet")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 6) {
                    ForEach(clientTags) { tag in
                        TagView(tag: tag)
                    }
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
            }
        }
        .padding(.horizontal, PluckrTheme.horizontalPadding)
        .padding(.vertical, PluckrTheme.verticalPadding)
    }
}

#Preview {
    ClientJournalTagsSection(clientTags: [Tag(label: "Sensitive Skin"), Tag(label: "Blend")], onShowTagPicker: {})
} 