// TagViewModel.swift
// Used for all tag management in Pluckr (ClientJournalView, ChartEntryFormView, TagPickerModal, etc.)
import Foundation
import SwiftUI

@MainActor
class TagViewModel: ObservableObject {
    @Published var allTags: [Tag] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Fetch all tags for a given context (e.g., client, chart)
    func fetchTags(context: TagContext) async {
        isLoading = true
        errorMessage = nil
        allTags = await TagService.shared.getAvailableTags(context: context)
        isLoading = false
    }
    
    // Create a new tag
    func createTag(label: String, color: String) async {
        isLoading = true
        errorMessage = nil
        
        // Trim whitespace and validate
        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLabel.isEmpty else {
            errorMessage = "Tag label cannot be empty"
            isLoading = false
            return
        }
        
        do {
            let newTag = Tag(label: trimmedLabel, colorNameOrHex: color)
            try await TagService.shared.createTag(newTag, context: TagContext.client) // Default to .client, or pass as needed
            allTags.append(newTag)
            PluckrLogger.success("Successfully created tag: \(trimmedLabel)")
        } catch let tagError as TagError {
            errorMessage = tagError.localizedDescription
            PluckrLogger.error("Tag creation failed: \(tagError.localizedDescription)")
        } catch {
            errorMessage = "Failed to create tag: \(error.localizedDescription)"
            PluckrLogger.error("Tag creation failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // Update an existing tag
    func updateTag(_ tag: Tag, context: TagContext) async {
        isLoading = true
        errorMessage = nil
        do {
            try await TagService.shared.updateTag(tag, context: context)
            if let idx = allTags.firstIndex(where: { $0.id == tag.id }) {
                allTags[idx] = tag
            }
        } catch {
            errorMessage = "Failed to update tag: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // Delete a tag
    func deleteTag(tagId: String, context: TagContext) async {
        isLoading = true
        errorMessage = nil
        do {
            try await TagService.shared.deleteTag(tagId: tagId, context: context)
            allTags.removeAll { $0.id == tagId }
        } catch {
            errorMessage = "Failed to delete tag: \(error.localizedDescription)"
        }
        isLoading = false
    }
} 