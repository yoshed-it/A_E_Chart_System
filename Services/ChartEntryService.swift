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
            PluckrLogger.error("Error loading chart entries: \(error.localizedDescription)")
        }

        return results
    }

    static func deleteEntry(for clientId: String, chartId: String) async {
        let docRef = Firestore.firestore()
            .collection("clients")
            .document(clientId)
            .collection("charts")
            .document(chartId)
        do {
            try await docRef.delete()
        } catch {
            PluckrLogger.error("Error deleting chart entry: \(error.localizedDescription)")
        }
    }
}
