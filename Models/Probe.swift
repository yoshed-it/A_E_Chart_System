import Foundation
import FirebaseFirestore

/**
 *Represents a probe in the Pluckr system*
 
 This struct contains probe information including type, specifications,
 and metadata for both predefined and custom probes.
 
 ## Properties
 - `id`: Unique Firestore document identifier
 - `name`: Display name of the probe
 - `type`: Type of probe (one-piece or two-piece)
 - `specifications`: Technical specifications
 - `isCustom`: Whether this is a custom probe added by the user
 - `createdBy`: ID of the provider who created this probe (for custom probes)
 - `createdByName`: Display name of the creating provider
 - `createdAt`: Date when the probe was created
 - `isActive`: Whether the probe is available for use
 
 ## Usage
 ```swift
 let probe = Probe(
     id: "probe123",
     name: "F2 Gold",
     type: .onePiece,
     specifications: "0.1mm diameter, gold-plated"
 )
 ```
 
 ## Firestore Integration
 This struct can be initialized from Firestore data using the `init?(data:id:)` method
 and converted back to a dictionary using the `toDict()` method.
 */
struct Probe: Identifiable, Hashable, Codable, Equatable {
    var id: String
    var name: String
    var type: ProbeType
    var specifications: String
    var isCustom: Bool
    var createdBy: String?
    var createdByName: String?
    var createdAt: Date
    var isActive: Bool
    
    enum ProbeType: String, CaseIterable, Codable {
        case onePiece = "one-piece"
        case twoPiece = "two-piece"
        
        var displayName: String {
            switch self {
            case .onePiece:
                return "One-Piece"
            case .twoPiece:
                return "Two-Piece"
            }
        }
    }
    
    /**
     *Creates a new Probe instance*
     
     - Parameter id: Unique identifier for the probe
     - Parameter name: Display name of the probe
     - Parameter type: Type of probe (one-piece or two-piece)
     - Parameter specifications: Technical specifications
     - Parameter isCustom: Whether this is a custom probe
     - Parameter createdBy: ID of the creating provider
     - Parameter createdByName: Display name of the creating provider
     - Parameter createdAt: Date when probe was created
     - Parameter isActive: Whether the probe is available for use
     */
    init(
        id: String,
        name: String,
        type: ProbeType,
        specifications: String,
        isCustom: Bool = false,
        createdBy: String? = nil,
        createdByName: String? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.specifications = specifications
        self.isCustom = isCustom
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.isActive = isActive
    }
    
    /**
     *Creates a Probe instance from Firestore data*
     
     This initializer is used to create Probe instances from Firestore document data.
     It validates required fields and handles optional data appropriately.
     
     - Parameter data: Dictionary containing Firestore document data
     - Parameter id: Document ID from Firestore
     - Returns: A Probe instance if valid data is provided, nil otherwise
     
     ## Example
     ```swift
     if let probe = Probe(data: documentData, id: documentID) {
         // Use the probe
     }
     ```
     */
    init?(data: [String: Any], id: String) {
        guard let name = data["name"] as? String,
              let typeString = data["type"] as? String,
              let type = ProbeType(rawValue: typeString),
              let specifications = data["specifications"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.type = type
        self.specifications = specifications
        self.isCustom = data["isCustom"] as? Bool ?? false
        self.createdBy = data["createdBy"] as? String
        self.createdByName = data["createdByName"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.isActive = data["isActive"] as? Bool ?? true
    }
    
    /**
     *Converts the probe to a Firestore dictionary*
     
     - Returns: Dictionary representation suitable for Firestore storage
     */
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "type": type.rawValue,
            "specifications": specifications,
            "isCustom": isCustom,
            "createdAt": Timestamp(date: createdAt),
            "isActive": isActive
        ]
        
        if let createdBy = createdBy {
            dict["createdBy"] = createdBy
        }
        if let createdByName = createdByName {
            dict["createdByName"] = createdByName
        }
        
        return dict
    }
}

// MARK: - Predefined Probes
extension Probe {
    /**
     *Returns the default predefined probes*
     
     These are the standard probes that come with the system.
     - Returns: Array of predefined probe configurations
     */
    static var predefinedProbes: [Probe] {
        let onePieceProbes = [
            Probe(id: "f2-gold-1p", name: "F2 Gold", type: .onePiece, specifications: "0.1mm diameter, gold-plated tip"),
            Probe(id: "f3-gold-1p", name: "F3 Gold", type: .onePiece, specifications: "0.15mm diameter, gold-plated tip"),
            Probe(id: "f4-gold-1p", name: "F4 Gold", type: .onePiece, specifications: "0.2mm diameter, gold-plated tip"),
            Probe(id: "f5-gold-1p", name: "F5 Gold", type: .onePiece, specifications: "0.25mm diameter, gold-plated tip"),
            Probe(id: "f2-insulated-1p", name: "F2 Insulated", type: .onePiece, specifications: "0.1mm diameter, insulated tip"),
            Probe(id: "f3-insulated-1p", name: "F3 Insulated", type: .onePiece, specifications: "0.15mm diameter, insulated tip"),
            Probe(id: "f4-insulated-1p", name: "F4 Insulated", type: .onePiece, specifications: "0.2mm diameter, insulated tip"),
            Probe(id: "f5-insulated-1p", name: "F5 Insulated", type: .onePiece, specifications: "0.25mm diameter, insulated tip")
        ]
        
        let twoPieceProbes = [
            Probe(id: "f2-gold-2p", name: "F2 Gold", type: .twoPiece, specifications: "0.1mm diameter, gold-plated tip"),
            Probe(id: "f3-gold-2p", name: "F3 Gold", type: .twoPiece, specifications: "0.15mm diameter, gold-plated tip"),
            Probe(id: "f4-gold-2p", name: "F4 Gold", type: .twoPiece, specifications: "0.2mm diameter, gold-plated tip"),
            Probe(id: "f5-gold-2p", name: "F5 Gold", type: .twoPiece, specifications: "0.25mm diameter, gold-plated tip"),
            Probe(id: "f2-insulated-2p", name: "F2 Insulated", type: .twoPiece, specifications: "0.1mm diameter, insulated tip"),
            Probe(id: "f3-insulated-2p", name: "F3 Insulated", type: .twoPiece, specifications: "0.15mm diameter, insulated tip"),
            Probe(id: "f4-insulated-2p", name: "F4 Insulated", type: .twoPiece, specifications: "0.2mm diameter, insulated tip"),
            Probe(id: "f5-insulated-2p", name: "F5 Insulated", type: .twoPiece, specifications: "0.25mm diameter, insulated tip")
        ]
        
        return onePieceProbes + twoPieceProbes
    }
} 