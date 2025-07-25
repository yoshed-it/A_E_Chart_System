import SwiftUI

struct CustomTagSheet: View {
    @Binding var tagLabel: String
    @Binding var tagColor: String
    @Binding var saveToLibrary: Bool
    let context: TagContext
    let onSave: (Tag) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showingColorPicker = false
    @State private var errorMessage: String? = nil
    @State private var isSaving = false
    
    private let availableColors = [
        "PluckrTagGreen", "PluckrTagBeige", "PluckrTagTan",
        "PluckrTagRed", "PluckrTagYellow", "PluckrTagBlue",
        "PluckrTagPurple", "PluckrTagTeal", "PluckrTagOrange"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tag Details") {
                    TextField("Tag name", text: $tagLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Button {
                            showingColorPicker = true
                        } label: {
                            Circle()
                                .fill(Color(tagColor) ?? .gray)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                
                if context == .client || context == .chart {
                    Section {
                        Toggle("Save to tag library for future use", isOn: $saveToLibrary)
                            .font(.subheadline)
                    } footer: {
                        Text("This tag will be available for all \(context == .client ? "clients" : "charts") in the future")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    HStack {
                        Text("Preview")
                        Spacer()
                        TagView(tag: Tag(label: tagLabel.isEmpty ? "Sample Tag" : tagLabel, colorNameOrHex: tagColor), size: .large)
                    }
                }
            }
            .navigationTitle("Create Custom Tag")
            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isSaving ? "Saving..." : "Save") {
                            saveTag()
                        }
                        .disabled(tagLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    }
                }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(selectedColor: $tagColor)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func saveTag() {
        let trimmedLabel = tagLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLabel.isEmpty else {
            errorMessage = "Tag label cannot be empty"
            return
        }
        
        let newTag = Tag(label: trimmedLabel, colorNameOrHex: tagColor)
        
        isSaving = true
        Task {
            do {
                if saveToLibrary {
                    // Save to library with duplicate checking
                    try await TagService.shared.createTag(newTag, context: context)
                    PluckrLogger.success("Successfully saved custom tag '\(trimmedLabel)' to library")
                    
                    // Only call onSave if successfully saved to library
                    await MainActor.run {
                        onSave(newTag)
                        dismiss()
                    }
                } else {
                    // If not saving to library, just call onSave immediately
                    await MainActor.run {
                        onSave(newTag)
                        dismiss()
                    }
                }
            } catch let tagError as TagError {
                PluckrLogger.error("Failed to save tag: \(tagError.localizedDescription)")
                await MainActor.run {
                    errorMessage = tagError.localizedDescription
                }
            } catch {
                PluckrLogger.error("Failed to save tag: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Failed to save tag: \(error.localizedDescription)"
                }
            }
            
            await MainActor.run {
                isSaving = false
            }
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: String
    @Environment(\.dismiss) var dismiss
    
    private let colors = [
        "PluckrTagGreen", "PluckrTagBeige", "PluckrTagTan",
        "PluckrTagRed", "PluckrTagYellow", "PluckrTagBlue",
        "PluckrTagPurple", "PluckrTagTeal", "PluckrTagOrange"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Color")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                    ForEach(colors, id: \.self) { assetName in
                        Button {
                            selectedColor = assetName
                            dismiss()
                        } label: {
                            Circle()
                                .fill(Color(assetName))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == assetName ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: Color(assetName).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
