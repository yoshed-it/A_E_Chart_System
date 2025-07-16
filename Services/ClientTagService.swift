import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class TagService: ObservableObject {
    static let shared = TagService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Update Client Tags
    func updateClientTags(clientId: String, tags: [Tag]) async throws {
        let tagsData = tags.map { $0.toDict() }
        
        // Try organization-based structure first
        if let orgId = OrganizationService.shared.getCurrentOrganizationId() {
            try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .updateData([
                    "clientTags": tagsData
                ])
            
            PluckrLogger.info("Updated client tags for client \(clientId) in org \(orgId): \(tags.count) tags")
        } else {
            // Fallback to root-level structure
            try await db.collection("clients")
                .document(clientId)
                .updateData([
                    "clientTags": tagsData
                ])
            
            PluckrLogger.info("Updated client tags for client \(clientId) at root level: \(tags.count) tags")
        }
    }
    
    // MARK: - Save Custom Tag to Library
    func saveCustomTagToLibrary(tag: Tag, context: TagPickerModal.TagContext) async throws {
        let tagData = tag.toDict()
        let collectionName = context == .client ? "clientTagsLibrary" : "chartTagsLibrary"
        
        // Try organization-based structure first
        if let orgId = OrganizationService.shared.getCurrentOrganizationId() {
            PluckrLogger.info("Attempting to save tag '\(tag.label)' to org \(orgId)/\(collectionName) with ID: \(tag.id)")
            PluckrLogger.info("Tag data: \(tagData)")
            
            try await db.collection("organizations")
                .document(orgId)
                .collection(collectionName)
                .document(tag.id)
                .setData(tagData)
            
            PluckrLogger.success("Successfully saved custom \(context == .client ? "client" : "chart") tag to library: \(tag.label) in org \(orgId)/\(collectionName)")
        } else {
            // Fallback to root-level structure
            PluckrLogger.info("Attempting to save tag '\(tag.label)' to \(collectionName) with ID: \(tag.id)")
            PluckrLogger.info("Tag data: \(tagData)")
            
            try await db.collection(collectionName)
                .document(tag.id)
                .setData(tagData)
            
            PluckrLogger.success("Successfully saved custom \(context == .client ? "client" : "chart") tag to library: \(tag.label) in \(collectionName)")
        }
    }
    
    // MARK: - Load Tags from Library
    func loadTagsFromLibrary(context: TagPickerModal.TagContext) async throws -> [Tag] {
        let collectionName = context == .client ? "clientTagsLibrary" : "chartTagsLibrary"
        
        // Try organization-based structure first
        if let orgId = OrganizationService.shared.getCurrentOrganizationId() {
            PluckrLogger.info("Loading tags from org \(orgId)/\(collectionName) collection")
            
            let snapshot = try await db.collection("organizations")
                .document(orgId)
                .collection(collectionName)
                .getDocuments()
            
            PluckrLogger.info("Found \(snapshot.documents.count) documents in org \(orgId)/\(collectionName) collection")
            
            let tags = snapshot.documents.compactMap { document in
                PluckrLogger.info("Processing document \(document.documentID) with data: \(document.data())")
                return Tag(data: document.data(), id: document.documentID)
            }
            
            PluckrLogger.success("Successfully loaded \(tags.count) \(context == .client ? "client" : "chart") tags from org \(orgId) library")
            return tags
        } else {
            // Fallback to root-level structure
            PluckrLogger.info("Loading tags from \(collectionName) collection")
            
            let snapshot = try await db.collection(collectionName)
                .getDocuments()
            
            PluckrLogger.info("Found \(snapshot.documents.count) documents in \(collectionName) collection")
            
            let tags = snapshot.documents.compactMap { document in
                PluckrLogger.info("Processing document \(document.documentID) with data: \(document.data())")
                return Tag(data: document.data(), id: document.documentID)
            }
            
            PluckrLogger.success("Successfully loaded \(tags.count) \(context == .client ? "client" : "chart") tags from library")
            return tags
        }
    }
    
    // MARK: - Get Available Tags (default + library)
    func getAvailableTags(context: TagPickerModal.TagContext) async -> [Tag] {
        do {
            let libraryTags = try await loadTagsFromLibrary(context: context)
            let defaultTags = context == .client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
            let allTags = defaultTags + libraryTags
            
            // Remove duplicates based on label
            let uniqueTags = Array(Set(allTags.map { $0.label })).compactMap { label in
                allTags.first { $0.label == label }
            }
            
            return uniqueTags.sorted { $0.label < $1.label }
        } catch {
            let orgId = OrganizationService.shared.getCurrentOrganizationId()
            PluckrLogger.error("Failed to load library tags from \(orgId != nil ? "org \(orgId!)" : "root level"): \(error.localizedDescription)")
            return context == .client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
        }
    }
}

// MARK: - Backward Compatibility
@MainActor
class ClientTagService: ObservableObject {
    static let shared = TagService.shared
    
    private init() {}
    
    func updateClientTags(clientId: String, tags: [Tag]) async throws {
        try await TagService.shared.updateClientTags(clientId: clientId, tags: tags)
    }
    
    func saveCustomTagToLibrary(tag: Tag) async throws {
        try await TagService.shared.saveCustomTagToLibrary(tag: tag, context: .client)
    }
    
    func loadTagsFromLibrary() async throws -> [Tag] {
        try await TagService.shared.loadTagsFromLibrary(context: .client)
    }
    
    func getAvailableClientTags() async -> [Tag] {
        await TagService.shared.getAvailableTags(context: .client)
    }
} 