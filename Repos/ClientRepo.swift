import Foundation
import FirebaseFirestore
import FirebaseAuth

final class ClientRepository {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

        func observeClients(onUpdate: @escaping ([Client]) -> Void) {
            listener?.remove() // Clear any existing listener before attaching a new one

            listener = db.collection("clients")
                .order(by: "lastSeenAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let docs = snapshot?.documents else {
                        print("⚠️ Failed to observe clients: \(error?.localizedDescription ?? "Unknown error")")
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
                    print("❌ Error fetching clients: \(error.localizedDescription)")
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
                print("❌ Failed to create client: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func updateClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        guard let id = client.id else {
            print("❌ Missing client ID.")
            completion(false)
            return
        }

        let data: [String: Any] = [
            "firstName": client.firstName,
            "lastName": client.lastName,
            "pronouns": client.pronouns as Any,
            "phone": client.phone as Any,
            "email": client.email as Any,
            "lastSeenAt": Timestamp(date: client.lastSeenAt ?? Date())
        ]

        db.collection("clients").document(id).updateData(data) { error in
            if let error = error {
                print("❌ Failed to update client: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func archiveClient(_ client: Client, completion: @escaping (Bool) -> Void) {
        guard let id = client.id else {
            completion(false)
            return
        }

        let docRef = db.collection("clients").document(id)
        docRef.updateData([
            "deletedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Failed to archive client: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

