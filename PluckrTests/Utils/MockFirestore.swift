import Foundation
import FirebaseFirestore
@testable import Pluckr

// MARK: - Shared Mock Firestore Classes for Testing

class MockFirestore {
    var documents: [String: [String: Any]] = [:]
    var batchOperations: [String: [String: Any]] = [:]
    var calledPaths: [String] = []
    
    func collection(_ path: String) -> MockCollectionReference {
        calledPaths.append(path)
        return MockCollectionReference(path: path, firestore: self)
    }
    
    func batch() -> MockWriteBatch {
        return MockWriteBatch(firestore: self)
    }
    
    func verifyPathWasCalled(_ expectedPath: String) -> Bool {
        return calledPaths.contains { $0.contains(expectedPath) }
    }
}

extension MockFirestore: FirestoreProtocol {
    func collection(_ path: String) -> CollectionReferenceProtocol {
        return MockCollectionReference(path: path, firestore: self)
    }
}

class MockCollectionReference: CollectionReferenceProtocol {
    let path: String
    let firestore: MockFirestore
    
    init(path: String, firestore: MockFirestore) {
        self.path = path
        self.firestore = firestore
    }
    
    func document(_ id: String) -> DocumentReferenceProtocol {
        let fullPath = "\(path)/\(id)"
        firestore.calledPaths.append(fullPath)
        return MockDocumentReference(path: fullPath, firestore: firestore)
    }
    
    func getDocuments() async throws -> QuerySnapshot {
        firestore.calledPaths.append(path)
        // Create empty QuerySnapshot - this will work for basic testing
        // In a real implementation, you'd need to mock QuerySnapshot properly
        throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock QuerySnapshot not fully implemented"])
    }
    
    func addSnapshotListener(_ listener: @escaping (MockQuerySnapshot?, Error?) -> Void) -> MockListenerRegistration {
        firestore.calledPaths.append(path)
        return MockListenerRegistration()
    }
    
    func order(by field: String, descending: Bool = false) -> MockCollectionReference {
        return self
    }
}

class MockDocumentReference: DocumentReferenceProtocol {
    let path: String
    let firestore: MockFirestore
    
    init(path: String, firestore: MockFirestore) {
        self.path = path
        self.firestore = firestore
    }
    
    func setData(_ data: [String: Any]) async throws {
        firestore.documents[path] = data
        firestore.calledPaths.append(path)
    }
    
    func updateData(_ data: [String: Any]) async throws {
        firestore.documents[path] = data
        firestore.calledPaths.append(path)
    }
    
    func delete() async throws {
        firestore.documents.removeValue(forKey: path)
        firestore.calledPaths.append(path)
    }
    
    func getDocument() async throws -> DocumentSnapshot {
        firestore.calledPaths.append(path)
        // Create empty DocumentSnapshot - this will work for basic testing
        // In a real implementation, you'd need to mock DocumentSnapshot properly
        throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock DocumentSnapshot not fully implemented"])
    }
    
    func collection(_ path: String) -> CollectionReferenceProtocol {
        let fullPath = "\(self.path)/\(path)"
        firestore.calledPaths.append(fullPath)
        return MockCollectionReference(path: fullPath, firestore: firestore)
    }
}

class MockWriteBatch {
    let firestore: MockFirestore
    var operations: [String: [String: Any]] = [:]
    
    init(firestore: MockFirestore) {
        self.firestore = firestore
    }
    
    func setData(_ data: [String: Any], forDocument document: MockDocumentReference) {
        operations[document.path] = data
        firestore.calledPaths.append(document.path)
    }
    
    func deleteDocument(_ document: MockDocumentReference) {
        operations[document.path] = nil
        firestore.calledPaths.append(document.path)
    }
    
    func commit() async throws {
        firestore.batchOperations.merge(operations) { _, new in new }
    }
}

class MockQuerySnapshot {
    let documents: [MockQueryDocumentSnapshot]
    
    init(documents: [MockQueryDocumentSnapshot]) {
        self.documents = documents
    }
}

class MockQueryDocumentSnapshot {
    let documentID: String
    let data: [String: Any]
    
    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.data = data
    }
    
    var reference: MockDocumentReference {
        return MockDocumentReference(path: documentID, firestore: MockFirestore())
    }
}

class MockDocumentSnapshot {
    let data: [String: Any]
    let documentID: String
    
    init(data: [String: Any], documentID: String) {
        self.data = data
        self.documentID = documentID
    }
}

class MockListenerRegistration {
    func remove() {
        // Mock implementation
    }
}

// MARK: - Mock Client Repository for Testing
class MockClientRepository {
    var clients: [Client] = []
    var shouldSucceed = true
    var errorMessage: String?
    
    func updateClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        if shouldSucceed {
            if let index = clients.firstIndex(where: { $0.id == client.id }) {
                clients[index] = client
            }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func deleteClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        if shouldSucceed {
            clients.removeAll { $0.id == client.id }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func deleteClient(_ clientId: String, completion: @escaping (Bool) -> Void) {
        if shouldSucceed {
            clients.removeAll { $0.id == clientId }
            completion(true)
        } else {
            completion(false)
        }
    }
} 