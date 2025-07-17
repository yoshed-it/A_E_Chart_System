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
                            TagView(tag: tag, isSelected: selectedTags.contains(tag)) {
                                // Haptic feedback for better UX
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                if selectedTags.contains(tag) {
                                    selectedTags.removeAll { $0 == tag }
                                } else {
                                    selectedTags.append(tag)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button("Done") { dismiss() }
                    .font(PluckrTheme.subheadingFont())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PluckrTheme.accent)
                    .cornerRadius(PluckrTheme.buttonCornerRadius)
                
                if !selectedTags.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .font(PluckrTheme.captionFont())
                        Text("\(selectedTags.count) tag\(selectedTags.count == 1 ? "" : "s") selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(PluckrTheme.card)
                .shadow(color: PluckrTheme.shadow, radius: 16, x: 0, y: 4)
        )
        .sheet(isPresented: $showingCustomTagSheet) {
            CustomTagSheet(
                tagLabel: $customTagLabel,
                tagColor: $customTagColor,
                saveToLibrary: $saveToLibrary,
                context: context,
                onSave: { newTag in
                    // Add to selected tags
                    selectedTags.append(newTag)
                    
                    // Add to available tags immediately so it shows up
                    allAvailableTags.append(newTag)
                    
                    // Sort the tags alphabetically
                    allAvailableTags.sort { $0.label < $1.label }
                    
                    showingCustomTagSheet = false
                    customTagLabel = ""
                    customTagColor = Tag.randomAssetColor()
                    
                    // Reload available tags if this was a client tag (to get any library updates)
                    if context == .client {
                        Task {
                            await loadAvailableTags()
                        }
                    }
                }
            )
        }
        .onAppear {
            Task {
                await loadAvailableTags()
            }
        }
    }
    
    // MARK: - Load Available Tags
    private func loadAvailableTags() async {
        isLoading = true
        
        allAvailableTags = await TagService.shared.getAvailableTags(context: context)
        
        isLoading = false
    }
}

