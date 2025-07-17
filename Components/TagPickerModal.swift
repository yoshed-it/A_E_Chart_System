import SwiftUI

struct TagPickerModal: View {
    @Binding var selectedTags: [Tag]
    let availableTags: [Tag]
    let context: TagContext
    @Environment(\.dismiss) var dismiss
    
    @State private var showingCustomTagSheet = false
    @State private var customTagLabel = ""
    @State private var customTagColor = Tag.randomAssetColor()
    @State private var saveToLibrary = false
    @State private var allAvailableTags: [Tag] = []
    @State private var isLoading = false
    
    enum TagContext {
        case client
        case chart
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(Color(.systemGray4))
                    .padding(.top, 8)
                
                HStack {
                    Text("Select Tags")
                        .font(PluckrTheme.subheadingFont(size: 22))
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Add Custom") {
                        showingCustomTagSheet = true
                    }
                    .font(.subheadline)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
            }
            // Tags Grid
            if isLoading {
                ProgressView("Loading tags...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                        ForEach(allAvailableTags) { tag in
                            TagView(tag: tag, isSelected: selectedTags.contains(tag), onTap: {
                                // Haptic feedback for better UX
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                if selectedTags.contains(tag) {
                                    selectedTags.removeAll { $0 == tag }
                                } else {
                                    selectedTags.append(tag)
                                }
                            }, size: .large)
                        }
                    }
                    .padding()
                }
            }
            // Action Buttons
            HStack {
                Button("Cancel") { dismiss() }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.red)
                Spacer()
                Button("Done") { dismiss() }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.accent)
            }
            .padding()
        }
        .background(PluckrTheme.background)
        .cornerRadius(24)
        .onAppear { loadTags() }
        .sheet(isPresented: $showingCustomTagSheet) {
            CustomTagSheet(
                tagLabel: $customTagLabel,
                tagColor: $customTagColor,
                saveToLibrary: $saveToLibrary,
                context: context,
                onSave: { tag in
                    allAvailableTags.append(tag)
                    selectedTags.append(tag)
                }
            )
        }
    }
    
    private func loadTags() {
        isLoading = true
        Task {
            let tags = await TagService.shared.getAvailableTags(context: context)
            await MainActor.run {
                allAvailableTags = tags
                isLoading = false
            }
        }
    }
} 