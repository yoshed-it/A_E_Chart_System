import Foundation
import FirebaseFirestore

struct ChartEntry: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore handles this
    var createdAt: Date = Date()
    var createdBy: String = ""
    var modality: String = ""
    var rfLevel: Int = 0
    var dcLevel: Int = 0
    var probe: String = ""
    var treatmentArea: String = ""
    var notes: String = ""
    var images: [String] = []
    var lastEditedAt: Date = Date()
    var lastEditedBy: String = ""

    init(id: String, data: [String: Any]) {
        self.id = id
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.createdBy = data["createdBy"] as? String ?? ""
        self.modality = data["modality"] as? String ?? ""
        self.rfLevel = data["rfLevel"] as? Int ?? 0
        self.dcLevel = data["dcLevel"] as? Int ?? 0
        self.probe = data["probe"] as? String ?? ""
        self.treatmentArea = data["treatmentArea"] as? String ?? ""
        self.notes = data["notes"] as? String ?? ""
        self.images = data["images"] as? [String] ?? []
        self.lastEditedAt = (data["lastEditedAt"] as? Timestamp)?.dateValue() ?? self.createdAt
        self.lastEditedBy = data["lastEditedBy"] as? String ?? self.createdBy
    }
}
