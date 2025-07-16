import Foundation
import FirebaseFirestore

struct Organization: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var description: String?
    var createdAt: Date
    var createdBy: String
    var isActive: Bool
    var settings: OrganizationSettings
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        createdBy: String,
        settings: OrganizationSettings = OrganizationSettings()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = Date()
        self.createdBy = createdBy
        self.isActive = true
        self.settings = settings
    }
    
    init?(data: [String: Any], id: String?) {
        guard let name = data["name"] as? String,
              let documentId = id, !documentId.isEmpty,
              let createdBy = data["createdBy"] as? String else {
            return nil
        }
        
        self.id = documentId
        self.name = name
        self.description = data["description"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.createdBy = createdBy
        self.isActive = data["isActive"] as? Bool ?? true
        
        if let settingsData = data["settings"] as? [String: Any] {
            self.settings = OrganizationSettings(data: settingsData)
        } else {
            self.settings = OrganizationSettings()
        }
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "createdAt": Timestamp(date: createdAt),
            "createdBy": createdBy,
            "isActive": isActive,
            "settings": settings.toDict()
        ]
        
        if let description = description {
            dict["description"] = description
        }
        
        return dict
    }
}

struct OrganizationSettings: Codable, Equatable {
    var allowCustomTags: Bool
    var requireClientConsent: Bool
    var enableImageEncryption: Bool
    var maxImageSizeMB: Int
    var retentionDays: Int
    
    init(
        allowCustomTags: Bool = true,
        requireClientConsent: Bool = false,
        enableImageEncryption: Bool = true,
        maxImageSizeMB: Int = 10,
        retentionDays: Int = 2555 // 7 years
    ) {
        self.allowCustomTags = allowCustomTags
        self.requireClientConsent = requireClientConsent
        self.enableImageEncryption = enableImageEncryption
        self.maxImageSizeMB = maxImageSizeMB
        self.retentionDays = retentionDays
    }
    
    init(data: [String: Any]) {
        self.allowCustomTags = data["allowCustomTags"] as? Bool ?? true
        self.requireClientConsent = data["requireClientConsent"] as? Bool ?? false
        self.enableImageEncryption = data["enableImageEncryption"] as? Bool ?? true
        self.maxImageSizeMB = data["maxImageSizeMB"] as? Int ?? 10
        self.retentionDays = data["retentionDays"] as? Int ?? 2555
    }
    
    func toDict() -> [String: Any] {
        return [
            "allowCustomTags": allowCustomTags,
            "requireClientConsent": requireClientConsent,
            "enableImageEncryption": enableImageEncryption,
            "maxImageSizeMB": maxImageSizeMB,
            "retentionDays": retentionDays
        ]
    }
} 