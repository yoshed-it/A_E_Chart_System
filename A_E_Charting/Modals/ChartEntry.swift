import Foundation
import FirebaseFirestore

struct ChartEntry: Identifiable {
    var id: String?
    var createdAt: Date
    var lastEditedAt: Date
    var modality: String
    var probe: String
    var rfLevel: String
    var dcLevel: String
    var treatmentArea: String
    var notes: String
    var imageURLs: [String]

    init(id: String?, data: [String: Any]) {
        self.id = id

        // Safely unwrap timestamps
        if let createdAtTS = data["createdAt"] as? Timestamp {
            self.createdAt = createdAtTS.dateValue()
        } else {
            self.createdAt = Date()
        }

        if let lastEditedTS = data["lastEditedAt"] as? Timestamp {
            self.lastEditedAt = lastEditedTS.dateValue()
        } else {
            self.lastEditedAt = self.createdAt
        }

        // Safely unwrap all other fields
        self.modality = data["modality"] as? String ?? ""
        self.probe = data["probe"] as? String ?? ""
        self.rfLevel = data["rfLevel"] as? String ?? ""
        self.dcLevel = data["dcLevel"] as? String ?? ""
        self.treatmentArea = data["treatmentArea"] as? String ?? ""
        self.notes = data["notes"] as? String ?? ""

        if let urls = data["imageURLs"] as? [String] {
            self.imageURLs = urls
        } else {
            self.imageURLs = []
        }
    }

    func toDict() -> [String: Any] {
        return [
            "createdAt": Timestamp(date: createdAt),
            "lastEditedAt": Timestamp(date: lastEditedAt),
            "modality": modality,
            "probe": probe,
            "rfLevel": rfLevel,
            "dcLevel": dcLevel,
            "treatmentArea": treatmentArea,
            "notes": notes,
            "imageURLs": imageURLs
        ]
    }
}
