import FirebaseFirestore
import UIKit

struct ChartEntryData {
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
    var lastEditedAt: Date? = nil
    var lastEditedBy: String? = nil
    var createdBy: String
    var createdByName: String
    var clientChosenName: String?
    var clientLegalName: String?

    var asDictionary: [String: Any] {
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
            "clientChosenName": clientChosenName ?? "",
            "clientLegalName": clientLegalName ?? ""
        ]

        // Optional fields
        if let area = treatmentArea { dict["treatmentArea"] = area }
        if let skin = skinCondition { dict["skinCondition"] = skin }
        if let comment = comment { dict["comment"] = comment }
        if let editedAt = lastEditedAt { dict["lastEditedAt"] = Timestamp(date: editedAt) }

        return dict
    }
}
