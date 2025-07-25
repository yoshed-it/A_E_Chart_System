import SwiftUI

// MARK: - TagPickerModal
// NOTE: Used for both chart and client tags. Update this comment if usage changes. See // MARK: usage notes in Components folder. [[memory:3581768]]
struct TagPickerModal: View {
    @Binding var selectedTags: [Tag]
    let availableTags: [Tag]
    let context: TagContext
    var onDone: (([Tag]) -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var showingCustomTagSheet = false
    @State private var customTagLabel = ""
    @State private var customTagColor = Tag.randomAssetColor()
    @State private var saveToLibrary = false
    @State private var allAvailableTags: [Tag] = []
    @State private var isLoading = false
    
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
                    Button(action: { showingCustomTagSheet = true }) {
                        Label("Add Custom", systemImage: "tag")
                            .font(.subheadline)
                            .font(PluckrTheme.captionFont())
                    }
                    .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
            }
            // Tags Grid
            if isLoading {
                ProgressView("Loading tags...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                tagGrid
            }
            // Action Buttons
            HStack {
                Button("Cancel") { dismiss() }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.red)
                Spacer()
                Button("Done") {
                    onDone?(selectedTags)
                    dismiss()
                }
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
                    // Check if tag already exists in available tags
                    let tagExists = allAvailableTags.contains { $0.label.lowercased() == tag.label.lowercased() }
                    if !tagExists {
                        allAvailableTags.append(tag)
                        PluckrLogger.info("TagPickerModal: Added new custom tag '\(tag.label)' to available tags")
                    } else {
                        PluckrLogger.info("TagPickerModal: Skipped duplicate custom tag '\(tag.label)'")
                    }
                    
                    // Check if tag is already selected
                    let isSelected = selectedTags.contains { $0.label.lowercased() == tag.label.lowercased() }
                    if !isSelected {
                        selectedTags.append(tag)
                        PluckrLogger.info("TagPickerModal: Added custom tag '\(tag.label)' to selected tags")
                    } else {
                        PluckrLogger.info("TagPickerModal: Skipped adding duplicate selected tag '\(tag.label)'")
                    }
                }
            )
        }
    }
    
    private var tagGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                ForEach(allAvailableTags) { tag in
                    TagView(
                        tag: tag,
                        size: .large,
                        onRemove: selectedTags.contains(where: { $0.label.lowercased() == tag.label.lowercased() }) ? {
                            selectedTags.removeAll { $0.label.lowercased() == tag.label.lowercased() }
                        } : nil
                    )
                    .overlay(
                        Group {
                            if selectedTags.contains(where: { $0.label.lowercased() == tag.label.lowercased() }) {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            }
                        }
                    )
                    .onTapGesture {
                        // Haptic feedback for better UX
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        if selectedTags.contains(where: { $0.label.lowercased() == tag.label.lowercased() }) {
                            // Remove tag if already selected
                            selectedTags.removeAll { $0.label.lowercased() == tag.label.lowercased() }
                            PluckrLogger.info("TagPickerModal: Removed tag '\(tag.label)' from selection")
                        } else {
                            // Add tag if not selected (prevent duplicates)
                            if !selectedTags.contains(where: { $0.label.lowercased() == tag.label.lowercased() }) {
                                selectedTags.append(tag)
                                PluckrLogger.info("TagPickerModal: Added tag '\(tag.label)' to selection")
                            } else {
                                PluckrLogger.info("TagPickerModal: Skipped adding duplicate tag '\(tag.label)'")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadTags() {
        isLoading = true
        Task {
            PluckrLogger.info("TagPickerModal: loadTags() called")
            PluckrLogger.info("TagPickerModal: availableTags count: \(availableTags.count)")
            PluckrLogger.info("TagPickerModal: selectedTags count: \(selectedTags.count)")
            
            // Always use provided availableTags if they exist, otherwise load from Firestore
            let tags: [Tag]
            if availableTags.count > 0 {
                tags = availableTags
                PluckrLogger.info("TagPickerModal: Using provided availableTags (\(tags.count) tags)")
                for tag in tags {
                    PluckrLogger.info("TagPickerModal: Available tag: '\(tag.label)'")
                }
            } else {
                PluckrLogger.info("TagPickerModal: No availableTags provided, loading from Firestore")
                tags = await TagService.shared.getAvailableTags(context: context)
                PluckrLogger.info("TagPickerModal: Loaded tags from Firestore (\(tags.count) tags)")
            }
            
            await MainActor.run {
                allAvailableTags = tags
                PluckrLogger.info("TagPickerModal: Set allAvailableTags to \(tags.count) tags")
                PluckrLogger.info("TagPickerModal: selectedTags count: \(selectedTags.count)")
                
                // Debug: Check which tags should be highlighted
                for tag in selectedTags {
                    let isInAvailable = allAvailableTags.contains { $0.label.lowercased() == tag.label.lowercased() }
                    PluckrLogger.info("TagPickerModal: Selected tag '\(tag.label)' is in available: \(isInAvailable)")
                }
                
                isLoading = false
            }
        }
    }
} 
