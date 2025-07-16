import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class ClientTagService: ObservableObject {
    static let shared = ClientTagService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Update Client Tags
    func updateClientTags(clientId: String, tags: [Tag]) async throws {
        let tagsData = tags.map { $0.toDict() }
        
        try await db.collection("clients").document(clientId).updateData([
            "clientTags": tagsData
        ])
        
        PluckrLogger.info("Updated client tags for client \(clientId): \(tags.count) tags")
    }
    
    // MARK: - Save Custom Tag to Library (for client tags only)
    func saveCustomTagToLibrary(tag: Tag) async throws {
        let tagData = tag.toDict()
        
        try await db.collection("clientTagsLibrary").document(tag.id).setData(tagData)
        
        PluckrLogger.info("Saved custom tag to library: \(tag.label)")
    }
    
    // MARK: - Load Tags from Library
    func loadTagsFromLibrary() async throws -> [Tag] {
        let snapshot = try await db.collection("clientTagsLibrary").getDocuments()
        
        let tags = snapshot.documents.compactMap { document in
            Tag(data: document.data(), id: document.documentID)
        }
        
        PluckrLogger.info("Loaded \(tags.count) tags from library")
        return tags
    }
    
    // MARK: - Get Available Tags (default + library)
    func getAvailableClientTags() async -> [Tag] {
        do {
            let libraryTags = try await loadTagsFromLibrary()
            let allTags = TagConstants.defaultClientTags + libraryTags
            
            // Remove duplicates based on label
            let uniqueTags = Array(Set(allTags.map { $0.label })).compactMap { label in
                allTags.first { $0.label == label }
            }
            
            return uniqueTags.sorted { $0.label < $1.label }
        } catch {
            PluckrLogger.error("Failed to load library tags: \(error.localizedDescription)")
            return TagConstants.defaultClientTags
        }
    }
} 