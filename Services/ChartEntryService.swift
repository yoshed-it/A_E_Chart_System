import FirebaseFirestore

struct ChartEntryService {
    static func loadEntries(for clientId: String) async -> [ChartEntry] {
        var results: [ChartEntry] = []

        do {
            let snapshot = try await Firestore.firestore()
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .order(by: "createdAt", descending: true)
                .getDocuments()

            for doc in snapshot.documents {
                let entry = ChartEntry(id: doc.documentID, data: doc.data())
                results.append(entry)
            }
        } catch {
            print("Error loading chart entries: \(error.localizedDescription)")
        }

        return results
    }
}
