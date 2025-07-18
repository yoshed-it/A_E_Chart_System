/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartTagsSection: View {
    let chartTags: [Tag]
    let onShowTagPicker: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Chart Tags")
                    .pluckrSectionHeader()
                Spacer()
                Button(action: onShowTagPicker) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(PluckrTheme.accent)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chartTags) { tag in
                        TagView(tag: tag, size: .large)
                    }
                }
            }
        }
    }
}

#Preview {
    let tags = [
        Tag(label: "Sensitive Skin", colorNameOrHex: "PluckrTagBeige"),
        Tag(label: "Blend", colorNameOrHex: "PluckrTagBlue")
    ]
    return ChartTagsSection(chartTags: tags, onShowTagPicker: {})
        .padding()
        .background(PluckrTheme.background)
} 