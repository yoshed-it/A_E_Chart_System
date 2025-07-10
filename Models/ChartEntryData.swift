import FirebaseFirestore

struct ChartEntryData {
    var modality: String
    var rfLevel: Double
    var dcLevel: Double
    var probe: String
    var probeIsOnePiece: Bool
    var treatmentArea: String
    var notes: String
    var imageURLs: [String]
    var createdAt: Date
    var createdBy: String
    var createdByName: String
    var clientChosenName: String?
    var clientLegalName: String?
    var lastEditedAt: Date? = nil
    var lastEditedBy: String? = nil

    var asDictionary: [String: Any] {
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
            "clientChosenName": clientChosenName ?? "",
            "clientLegalName": clientLegalName ?? ""
        ]

        if let lastEditedAt = lastEditedAt {
            dict["lastEditedAt"] = Timestamp(date: lastEditedAt)
        }

        if let lastEditedBy = lastEditedBy {
            dict["lastEditedBy"] = lastEditedBy
        }

        return dict
    }
}
