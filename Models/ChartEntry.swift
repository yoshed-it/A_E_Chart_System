import Foundation
import FirebaseFirestore

struct ChartEntry: Identifiable {
    var id: String
    var modality: String
    var rfLevel: Double
    var dcLevel: Double
    var probe: String
    var probeIsOnePiece: Bool
    var treatmentArea: String
    var notes: String
    var imageURLs: [String]
    var createdAt: Date
    var lastEditedAt: Date?
    var createdBy: String
    var createdByName: String
    var clientChosenName: String
    var clientLegalName: String

    init(
        id: String,
        modality: String,
        rfLevel: Double,
        dcLevel: Double,
        probe: String,
        probeIsOnePiece: Bool,
        treatmentArea: String,
        notes: String,
        imageURLs: [String],
        createdAt: Date,
        lastEditedAt: Date? = nil,
        createdBy: String,
        createdByName: String,
        clientChosenName: String,
        clientLegalName: String
    ) {
        self.id = id
        self.modality = modality
        self.rfLevel = rfLevel
        self.dcLevel = dcLevel
        self.probe = probe
        self.probeIsOnePiece = probeIsOnePiece
        self.treatmentArea = treatmentArea
        self.notes = notes
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.lastEditedAt = lastEditedAt
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.clientChosenName = clientChosenName
        self.clientLegalName = clientLegalName
    }

    init(id: String, data: [String: Any]) {
        self.id = id
        self.modality = data["modality"] as? String ?? ""
        self.rfLevel = data["rfLevel"] as? Double ?? 0.0
        self.dcLevel = data["dcLevel"] as? Double ?? 0.0
        self.probe = data["probe"] as? String ?? ""
        self.probeIsOnePiece = data["probeIsOnePiece"] as? Bool ?? true
        self.treatmentArea = data["treatmentArea"] as? String ?? ""
        self.notes = data["notes"] as? String ?? ""
        self.imageURLs = data["imageURLs"] as? [String] ?? []
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lastEditedAt = (data["lastEditedAt"] as? Timestamp)?.dateValue()
        self.createdBy = data["createdBy"] as? String ?? ""
        self.createdByName = data["createdByName"] as? String ?? ""
        self.clientChosenName = data["clientChosenName"] as? String ?? ""
        self.clientLegalName = data["clientLegalName"] as? String ?? ""
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "modality": modality,
            "rfLevel": rfLevel,
            "dcLevel": dcLevel,
            "probe": probe,
            "probeIsOnePiece": probeIsOnePiece,
            "treatmentArea": treatmentArea,
            "notes": notes,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "createdBy": createdBy,
            "createdByName": createdByName,
            "clientChosenName": clientChosenName,
            "clientLegalName": clientLegalName,
        ]
        if let editedAt = lastEditedAt {
            dict["lastEditedAt"] = Timestamp(date: editedAt)
        }
        return dict
    }
}
