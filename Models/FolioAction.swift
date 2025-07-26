import Foundation

/**
 *Enum representing folio actions for undo functionality*
 
 This enum is used to track the last action performed on the folio
 so that it can be undone if needed.
 */
enum FolioAction {
    case added(Client)
    case removed(Client)
} 