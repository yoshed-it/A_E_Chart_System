import Foundation
import FirebaseFirestore
import UIKit

struct ChartEntry: Identifiable {
    var id: String
    var modality: String
    var rfLevel: Double
    var dcLevel: Double
    var probe: String
    var probeIsOnePiece: Bool
    var treatmentArea: String?
    var skinCondition: String?
    var comment: String?
    var notes: String
    var imageURLs: [String]
    var createdAt: Date
    var lastEditedAt: Date?
    var lastEditedBy: String?
    var createdBy: String
    var createdByName: String
    var clientChosenName: String
    var clientLegalName: String
    var chartTags: [Tag]

    // Local-only (not from Firestore)
    var image: UIImage?

    // MARK: - Firestore Initializer
    init(id: String, data: [String: Any]) {
        self.id = id
        self.modality = data["modality"] as? String ?? ""
        self.rfLevel = data["rfLevel"] as? Double ?? 0.0
        self.dcLevel = data["dcLevel"] as? Double ?? 0.0
        self.probe = data["probe"] as? String ?? ""
        self.probeIsOnePiece = data["probeIsOnePiece"] as? Bool ?? true
        self.treatmentArea = data["treatmentArea"] as? String
        self.skinCondition = data["skinCondition"] as? String
        self.comment = data["comment"] as? String
        self.notes = data["notes"] as? String ?? ""
        self.imageURLs = data["imageURLs"] as? [String] ?? []
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lastEditedAt = (data["lastEditedAt"] as? Timestamp)?.dateValue()
        self.lastEditedBy = data["lastEditedBy"] as? String
        self.createdBy = data["createdBy"] as? String ?? ""
        self.createdByName = data["createdByName"] as? String ?? ""
        self.clientChosenName = data["clientChosenName"] as? String ?? ""
        self.clientLegalName = data["clientLegalName"] as? String ?? ""
        let tagsData = data["chartTags"] as? [[String: Any]] ?? []
        self.chartTags = tagsData.compactMap { dict in
            Tag(data: dict, id: UUID().uuidString)
        }
        self.image = nil
    }

    // MARK: - Firestore Write
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "modality": modality,
            "rfLevel": rfLevel,
            "dcLevel": dcLevel,
            "probe": probe,
            "probeIsOnePiece": probeIsOnePiece,
            "notes": notes,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "createdBy": createdBy,
            "createdByName": createdByName,
            "clientChosenName": clientChosenName,
            "clientLegalName": clientLegalName,
            "chartTags": chartTags.map { $0.toDict() }
        ]

        // Optional fields
        if let area = treatmentArea { dict["treatmentArea"] = area }
        if let skin = skinCondition { dict["skinCondition"] = skin }
        if let comment = comment { dict["comment"] = comment }
        if let editedAt = lastEditedAt { dict["lastEditedAt"] = Timestamp(date: editedAt) }

        return dict
    }
}

extension ChartEntry {
    var formattedRFLevel: String {
        String(format: "%.1f MHz", rfLevel)
    }
    var formattedDCLevel: String {
        String(format: "%.1f mA", dcLevel)
    }
    var formattedCreatedAt: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    var formattedLastEditedAt: String? {
        lastEditedAt?.formatted(date: .abbreviated, time: .shortened)
    }
}
