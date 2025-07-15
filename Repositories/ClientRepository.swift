import Foundation
import FirebaseFirestore
import FirebaseAuth

/**
 *Repository for managing client data operations*
 
 This repository handles all client-related data operations including
 CRUD operations, real-time updates, and provider information fetching.
 It serves as the data layer between the ViewModels and Firestore.
 
 ## Features
 - Real-time client list observation
 - Client creation, updates, and archiving
 - Provider name fetching
 - Firestore integration
 
 ## Usage
 ```swift
 let repository = ClientRepository()
 
 // Observe clients in real-time
 repository.observeClients { clients in
     // Handle updated clients
 }
 
 // Create a new client
 repository.createClient(from: clientInput) { success in
     // Handle result
 }
 ```
 
 ## Error Handling
 All methods include proper error handling and logging. Failed operations
 are logged using the Logger utility and appropriate completion handlers
 are called with failure status.
 */
final class ClientRepository {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

        /**
         *Starts real-time observation of all clients*
         
         This method sets up a Firestore listener that automatically updates
         when client data changes. The listener is ordered by last seen date
         in descending order.
         
         - Parameter onUpdate: Closure called with updated client array
         - Note: Automatically removes any existing listener before creating a new one
         - Note: Logs errors using Logger utility
         */
        func observeClients(onUpdate: @escaping ([Client]) -> Void) {
            listener?.remove() // Clear any existing listener before attaching a new one

            listener = db.collection("clients")
                .order(by: "lastSeenAt", descending: true)
                .addSnapshotListener { snapshot, error in
                                    guard let docs = snapshot?.documents else {
                    PluckrLogger.error("Failed to observe clients: \(error?.localizedDescription ?? "Unknown error")")
                    onUpdate([])
                    return
                }

                    let clients = docs.compactMap { doc in
                        Client(data: doc.data(), id: doc.documentID)
                    }

                    onUpdate(clients)
                }
        }

        func stopObservingClients() {
            listener?.remove()
            listener = nil
        }
    
    func fetchClients(completion: @escaping ([Client]) -> Void) {
        db.collection("clients")
            .order(by: "lastSeenAt", descending: true)
            .getDocuments { snapshot, error in
                            if let error = error {
                PluckrLogger.error("Error fetching clients: \(error.localizedDescription)")
                completion([])
                return
            }
                
                let clients = snapshot?.documents.compactMap { doc in
                    Client(data: doc.data(), id: doc.documentID)
                } ?? []
                
                completion(clients)
            }
    }
    
    func fetchProviderName(completion: @escaping (String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion("")
            return
        }
        
        db.collection("providers").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                completion(name)
            } else {
                completion("")
            }
        }
    }
    
    func createClient(from input: ClientInput, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "firstName": input.firstName,
            "lastName": input.lastName,
            "phone": input.phone as Any,
            "email": input.email as Any,
            "pronouns": input.pronouns as Any,
            "createdBy": input.createdBy,
            "createdByName": input.createdByName,
            "createdAt": Timestamp(date: input.createdAt),
            "lastSeenAt": Timestamp(date: input.createdAt)
        ]
        
        db.collection("clients").addDocument(data: data) { error in
            if let error = error {
                PluckrLogger.error("Failed to create client: \(error.localizedDescription)")
                completion(false)
            } else {
                PluckrLogger.success("Client created successfully")
                completion(true)
            }
        }
    }
    func updateClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "firstName": client.firstName,
            "lastName": client.lastName,
            "pronouns": client.pronouns as Any,
            "phone": client.phone as Any,
            "email": client.email as Any,
            "lastSeenAt": Timestamp(date: client.lastSeenAt ?? Date())
        ]

        db.collection("clients").document(client.id).updateData(data) { error in
            if let error = error {
                PluckrLogger.error("Failed to update client: \(error.localizedDescription)")
                completion(false)
            } else {
                PluckrLogger.success("Client updated successfully")
                completion(true)
            }
        }
    }
    func archiveClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("clients").document(client.id)
        docRef.updateData([
            "deletedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                PluckrLogger.error("Failed to archive client: \(error.localizedDescription)")
                completion(false)
            } else {
                PluckrLogger.success("Client archived successfully")
                completion(true)
            }
        }
    }
    
    /**
     *Fetches chart entries for a specific client*
     
     - Parameter clientId: The ID of the client
     - Parameter completion: Closure called with the result containing chart entries or error
     */
    func fetchCharts(for clientId: String, completion: @escaping (Result<[ChartEntry], Error>) -> Void) {
        db.collection("clients")
            .document(clientId)
            .collection("charts")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    PluckrLogger.error("Failed to fetch charts: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    let charts = snapshot?.documents.compactMap { doc in
                        ChartEntry(id: doc.documentID, data: doc.data())
                    } ?? []
                    PluckrLogger.success("Fetched \(charts.count) charts for client \(clientId)")
                    completion(.success(charts))
                }
            }
    }
}

