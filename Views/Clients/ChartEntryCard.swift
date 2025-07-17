import SwiftUI

struct ChartEntryCard: View {
    let entry: ChartEntry
    @State private var showingTagDetail = false
    @State private var selectedTag: Tag? = nil
    @State private var showingChartDetail = false

    var body: some View {
        Button(action: {
            showingChartDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Date
                Text(entry.createdAt, style: .date)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)

                // Main details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("RF:")
                        Text(entry.rfLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" MHz")
                        Spacer()
                        Text("DC:")
                        Text(entry.dcLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" mA")
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textPrimary)

                    HStack {
                        Text("Probe:")
                        Spacer()
                        Text(entry.probe)
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textPrimary)

                    if let area = entry.treatmentArea {
                        HStack {
                            Text("Treatment Area:")
                            Spacer()
                            Text(area)
                        }
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                    }

                    if let condition = entry.skinCondition {
                        HStack {
                            Text("Skin Condition:")
                            Spacer()
                            Text(condition)
                        }
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                    }

                    if !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes:")
                                .font(PluckrTheme.captionFont())
                                .fontWeight(.semibold)
                            Text(entry.notes)
                                .font(PluckrTheme.bodyFont())
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(PluckrTheme.textPrimary)
                    }
                    
                    // Chart Tags
                    if !entry.chartTags.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tags:")
                                .font(PluckrTheme.captionFont())
                                .fontWeight(.semibold)
                            HStack(spacing: 6) {
                                ForEach(entry.chartTags) { tag in
                                    TagView(tag: tag, onTap: {
                                        selectedTag = tag
                                        showingTagDetail = true
                                    })
                                }
                                Spacer()
                            }
                        }
                    }
                }

                // Image
                if let image = entry.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .pluckrImage()
                }
            }
            .padding(PluckrTheme.verticalPadding)
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowSmall, radius: PluckrTheme.shadowRadiusSmall, x: 0, y: PluckrTheme.shadowYSmall)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTagDetail) {
            if let tag = selectedTag {
                TagDetailView(tag: tag)
            }
        }
        .sheet(isPresented: $showingChartDetail) {
            ChartDetailView(chart: entry, onEdit: {})
        }
    }
}

// MARK: - Tag Detail View
struct TagDetailView: View {
    let tag: Tag
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Tag Display
                VStack(spacing: 16) {
                    Text("Tag Details")
                        .font(PluckrTheme.headingFont(size: 28))
                        .foregroundColor(PluckrTheme.textPrimary)
                    
                    TagView(tag: tag)
                        .scaleEffect(1.2)
                }
                .padding(.top, 32)
                
                // Tag Information
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Label")
                            .font(PluckrTheme.sectionHeaderFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text(tag.label)
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(PluckrTheme.sectionHeaderFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        HStack(spacing: 12) {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 24, height: 24)
                            Text(tag.colorNameOrHex)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
                
                Spacer()
            }
            .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
}
