import SwiftUI

struct ClientJournalTagsSection: View {
    let clientTags: [Tag]
    let onShowTagPicker: () -> Void
    var onRemoveTag: ((Tag) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("CLIENT TAGS")
                    .pluckrSectionHeader()
                Button(action: onShowTagPicker) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                        .font(PluckrTheme.subheadingFont(size: 22))
                }
                .padding(.leading, 2)
            }
            if clientTags.isEmpty {
                Text("No tags added yet")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 90), spacing: 10)],
                    alignment: .leading,
                    spacing: 10
                ) {
                    ForEach(clientTags) { tag in
                        TagView(tag: tag, size: .large, onRemove: onRemoveTag == nil ? nil : { onRemoveTag?(tag) })
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PluckrTheme.horizontalPadding)
            }
        }
        .padding(.vertical, PluckrTheme.verticalPadding)
    }
}

// MARK: - Preview Section for Tag Wrapping Experiments
#if DEBUG
struct ClientJournalTagsSection_Preview: View {
    @State private var tags: [Tag] = [
        Tag(label: "Short", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Medium Tag", colorNameOrHex: "PluckrTagTan"),
        Tag(label: "A Very Long Tag That Should Wrap", colorNameOrHex: "PluckrTagGreen"),
        Tag(label: "New Client", colorNameOrHex: "PluckrTagYellow"),
        Tag(label: "Another Tag", colorNameOrHex: "PluckrTagBlue"),
        Tag(label: "X", colorNameOrHex: "PluckrTagRed")
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Preview: Client Tags Wrapping")
                .font(.title2)
                .padding(.bottom, 8)
            ClientJournalTagsSection(
                clientTags: tags,
                onShowTagPicker: {},
                onRemoveTag: { tag in
                    tags.removeAll { $0 == tag }
                }
            )
            Button("Add Random Tag") {
                let random = Int.random(in: 1...20)
                tags.append(Tag(label: String(repeating: "A", count: random), colorNameOrHex: "PluckrTagGreen"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    ClientJournalTagsSection_Preview()
}
#endif 