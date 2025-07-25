// Used in ClientJournalView for displaying and managing client tags
import SwiftUI

struct ClientJournalTagsSection: View {
    let clientTags: [Tag]
    let onShowTagPicker: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CLIENT TAGS")
                    .pluckrSectionHeader()
                Button {
                    onShowTagPicker()
                } label: {
                    Image(systemName: "tag.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                        .font(PluckrTheme.subheadingFont(size: 22))
                }
            }

            if clientTags.isEmpty {
                Text("No tags added yet")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
            } else {
                TagFlowLayout(tags: clientTags)
            }
            
        }
        .padding(.vertical, PluckrTheme.verticalPadding)
    }
}

// --- FLOW LAYOUT FOR TAGS ---
struct TagFlowLayout: View {
    let tags: [Tag]
    @State private var totalHeight: CGFloat = .zero
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: TagFlowHeightPreferenceKey.self, value: geo.size.height)
                    }
                )
        }
        .frame(height: totalHeight)
        .onPreferenceChange(TagFlowHeightPreferenceKey.self) { self.totalHeight = $0 }
    }
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var rows: [[Tag]] = [[]]
        for tag in tags {
            let tagSize = tag.label.size(withAttributes: [.font: UIFont.systemFont(ofSize: 13)])
            let tagWidth = tagSize.width + 32 // padding fudge factor
            if width + tagWidth > geometry.size.width {
                rows.append([tag])
                width = tagWidth
            } else {
                rows[rows.count - 1].append(tag)
                width += tagWidth
            }
        }
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<rows.count, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(rows[row], id: \.id) { tag in
                        TagView(tag: tag)
                    }
                }
            }
        }
    }
}

private struct TagFlowHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    ClientJournalTagsSection(clientTags: [Tag(label: "Sensitive Skin"), Tag(label: "Blend")], onShowTagPicker: {})
} 
