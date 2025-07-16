import SwiftUI

struct CustomTagSheet: View {
    @Binding var tagLabel: String
    @Binding var tagColor: String
    @Binding var saveToLibrary: Bool
    let context: TagPickerModal.TagContext
    let onSave: (Tag) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showingColorPicker = false
    
    private let availableColors = [
        "#FFB3BA", "#BAFFC9", "#BAE1FF", "#FFFFBA", "#FFB3F7",
        "#E6B3FF", "#B3FFE6", "#FFE6B3", "#B3E6FF", "#FFB3D9"
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
                                .fill(Color(hex: tagColor) ?? .gray)
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
                        TagView(tag: Tag(label: tagLabel.isEmpty ? "Sample Tag" : tagLabel, colorHex: tagColor))
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
                        Button("Save") {
                            let newTag = Tag(label: tagLabel, colorHex: tagColor)
                            
                            // Save to library if requested
                            if saveToLibrary {
                                Task {
                                    do {
                                        try await TagService.shared.saveCustomTagToLibrary(tag: newTag, context: context)
                                        PluckrLogger.success("Successfully saved custom tag '\(newTag.label)' to library")
                                        
                                        // Call onSave after successful save
                                        await MainActor.run {
                                            onSave(newTag)
                                            dismiss()
                                        }
                                    } catch {
                                        PluckrLogger.error("Failed to save tag to library: \(error.localizedDescription)")
                                        
                                        // Still call onSave even if library save fails
                                        await MainActor.run {
                                            onSave(newTag)
                                            dismiss()
                                        }
                                    }
                                }
                            } else {
                                // If not saving to library, just call onSave immediately
                                onSave(newTag)
                                dismiss()
                            }
                        }
                        .disabled(tagLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(selectedColor: $tagColor)
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: String
    @Environment(\.dismiss) var dismiss
    
    private let colors = [
        "#FFB3BA", "#BAFFC9", "#BAE1FF", "#FFFFBA", "#FFB3F7",
        "#E6B3FF", "#B3FFE6", "#FFE6B3", "#B3E6FF", "#FFB3D9"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Color")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                    ForEach(colors, id: \.self) { colorHex in
                        Button {
                            selectedColor = colorHex
                            dismiss()
                        } label: {
                            Circle()
                                .fill(Color(hex: colorHex) ?? .gray)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorHex ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: Color(hex: colorHex)?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 2)
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