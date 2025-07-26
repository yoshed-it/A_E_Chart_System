import Foundation
import Firebase
import FirebaseFirestore

// MARK: - Tag Errors
enum TagError: LocalizedError, Equatable {
    case duplicateTag(label: String)
    case invalidTag
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .duplicateTag(let label):
            return "A tag with the label '\(label)' already exists"
        case .invalidTag:
            return "Invalid tag data"
        case .saveFailed:
            return "Failed to save tag"
        }
    }
}

// MARK: - Firestore Protocol for Dependency Injection
protocol FirestoreProtocol {
    func collection(_ path: String) -> CollectionReferenceProtocol
}

protocol CollectionReferenceProtocol {
    func document(_ id: String) -> DocumentReferenceProtocol
    func getDocuments() async throws -> QuerySnapshot
}

protocol DocumentReferenceProtocol {
    func setData(_ data: [String: Any]) async throws
    func updateData(_ data: [String: Any]) async throws
    func delete() async throws
    func getDocument() async throws -> DocumentSnapshot
    func collection(_ path: String) -> CollectionReferenceProtocol
}

// MARK: - Firestore Adapter
class FirestoreAdapter: FirestoreProtocol {
    private let firestore: Firestore
    init(_ firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    func collection(_ path: String) -> CollectionReferenceProtocol {
        return CollectionReferenceAdapter(firestore.collection(path))
    }
}

class CollectionReferenceAdapter: CollectionReferenceProtocol {
    private let collection: CollectionReference
    init(_ collection: CollectionReference) {
        self.collection = collection
    }
    func document(_ id: String) -> DocumentReferenceProtocol {
        return DocumentReferenceAdapter(collection.document(id))
    }
    func getDocuments() async throws -> QuerySnapshot {
        return try await collection.getDocuments()
    }
}

class DocumentReferenceAdapter: DocumentReferenceProtocol {
    private let document: DocumentReference
    init(_ document: DocumentReference) {
        self.document = document
    }
    func setData(_ data: [String: Any]) async throws {
        try await document.setData(data)
    }
    func updateData(_ data: [String: Any]) async throws {
        try await document.updateData(data)
    }
    func delete() async throws {
        try await document.delete()
    }
    func getDocument() async throws -> DocumentSnapshot {
        return try await document.getDocument()
    }
    func collection(_ path: String) -> CollectionReferenceProtocol {
        return CollectionReferenceAdapter(document.collection(path))
    }
}

@MainActor
class TagService: ObservableObject {
    static let shared = TagService()
    private let db: FirestoreProtocol
    
    // Allow dependency injection for testing
    init(db: FirestoreProtocol = FirestoreAdapter()) {
        self.db = db
    }
    
    // MARK: - Update Client Tags
    func updateClientTags(clientId: String, tags: [Tag]) async throws {
        let tagsData = tags.map { $0.toDict() }
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
        try await db.collection("organizations")
            .document(orgId)
            .collection("clients")
            .document(clientId)
            .updateData([
                "clientTags": tagsData
            ])
        PluckrLogger.info("Updated client tags for client \(clientId) in org \(orgId): \(tags.count) tags")
    }
    
    // MARK: - Save Custom Tag to Library
    func saveCustomTagToLibrary(tag: Tag, context: TagContext) async throws {
        let tagData = tag.toDict()
        let collectionName = context == TagContext.client ? "clientTagsLibrary" : "chartTagsLibrary"
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
        PluckrLogger.info("Attempting to save tag '\(tag.label)' to org \(orgId)/\(collectionName) with ID: \(tag.id)")
        PluckrLogger.info("Tag data: \(tagData)")
        try await db.collection("organizations")
            .document(orgId)
            .collection(collectionName)
            .document(tag.id)
            .setData(tagData)
        PluckrLogger.success("Successfully saved custom \(context == TagContext.client ? "client" : "chart") tag to library: \(tag.label) in org \(orgId)/\(collectionName)")
    }
    
    // MARK: - Load Tags from Library
    func loadTagsFromLibrary(context: TagContext) async throws -> [Tag] {
        let collectionName = context == TagContext.client ? "clientTagsLibrary" : "chartTagsLibrary"
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
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
        PluckrLogger.success("Successfully loaded \(tags.count) \(context == TagContext.client ? "client" : "chart") tags from org \(orgId) library")
        return tags
    }
    
    // MARK: - Create Tag in Library
    func createTag(_ tag: Tag, context: TagContext) async throws {
        // Check if tag with same label already exists
        let existingTags = try await loadTagsFromLibrary(context: context)
        let defaultTags = context == TagContext.client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
        let allExistingTags = existingTags + defaultTags
        
        if allExistingTags.contains(where: { $0.label.lowercased() == tag.label.lowercased() }) {
            throw TagError.duplicateTag(label: tag.label)
        }
        
        let tagData = tag.toDict()
        let collectionName = context == TagContext.client ? "clientTagsLibrary" : "chartTagsLibrary"
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
        try await db.collection("organizations")
            .document(orgId)
            .collection(collectionName)
            .document(tag.id)
            .setData(tagData)
        PluckrLogger.success("Created tag \(tag.label) in org \(orgId)/\(collectionName)")
    }

    // MARK: - Update Tag in Library
    func updateTag(_ tag: Tag, context: TagContext) async throws {
        let tagData = tag.toDict()
        let collectionName = context == TagContext.client ? "clientTagsLibrary" : "chartTagsLibrary"
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
        try await db.collection("organizations")
            .document(orgId)
            .collection(collectionName)
            .document(tag.id)
            .updateData(tagData)
        PluckrLogger.success("Updated tag \(tag.label) in org \(orgId)/\(collectionName)")
    }

    // MARK: - Delete Tag from Library
    func deleteTag(tagId: String, context: TagContext) async throws {
        let collectionName = context == TagContext.client ? "clientTagsLibrary" : "chartTagsLibrary"
        let orgId = await OrganizationService.shared.getCurrentOrganizationId()!
        try await db.collection("organizations")
            .document(orgId)
            .collection(collectionName)
            .document(tagId)
            .delete()
        PluckrLogger.success("Deleted tag \(tagId) from org \(orgId)/\(collectionName)")
    }
    
    // MARK: - Get Available Tags (default + library)
    func getAvailableTags(context: TagContext) async -> [Tag] {
        do {
            let libraryTags = try await loadTagsFromLibrary(context: context)
            let defaultTags = context == TagContext.client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
            
            // Create a dictionary to track unique tags by label (case-insensitive)
            var uniqueTagsDict: [String: Tag] = [:]
            
            // Add default tags first (they take precedence)
            for tag in defaultTags {
                uniqueTagsDict[tag.label.lowercased()] = tag
            }
            
            // Add library tags (only if not already present)
            for tag in libraryTags {
                if uniqueTagsDict[tag.label.lowercased()] == nil {
                    uniqueTagsDict[tag.label.lowercased()] = tag
                }
            }
            
            // Convert back to array and sort
            let uniqueTags = Array(uniqueTagsDict.values).sorted { $0.label < $1.label }
            
            PluckrLogger.info("Returning \(uniqueTags.count) unique tags for context: \(context)")
            return uniqueTags
        } catch {
            let orgId = OrganizationService.shared.getCurrentOrganizationId()
            PluckrLogger.error("Failed to load library tags from \(orgId != nil ? "org \(orgId!)" : "root level"): \(error.localizedDescription)")
            return context == TagContext.client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
        }
    }

    // MARK: - Check if Tag Exists
    func tagExists(label: String, context: TagContext) async -> Bool {
        do {
            let existingTags = try await loadTagsFromLibrary(context: context)
            let defaultTags = context == TagContext.client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
            let allExistingTags = existingTags + defaultTags
            
            return allExistingTags.contains { $0.label.lowercased() == label.lowercased() }
        } catch {
            PluckrLogger.error("Failed to check if tag exists: \(error.localizedDescription)")
            // Fall back to checking only default tags when library loading fails
            let defaultTags = context == TagContext.client ? TagConstants.defaultClientTags : TagConstants.defaultChartTags
            return defaultTags.contains { $0.label.lowercased() == label.lowercased() }
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