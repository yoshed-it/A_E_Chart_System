import Foundation
import SwiftUI

@MainActor
class ClientJournalViewModel: ObservableObject {
    @Published var entries: [ChartEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let clientId: String
    
    init(clientId: String) {
        self.clientId = clientId
    }
    
    func loadEntries() async {
        isLoading = true
        errorMessage = nil
        do {
            entries = await ChartEntryService.loadEntries(for: clientId)
        } catch {
            errorMessage = "Failed to load chart entries."
        }
        isLoading = false
    }
    
    func deleteEntry(chartId: String) async {
        isLoading = true
        errorMessage = nil
        await ChartEntryService.deleteEntry(for: clientId, chartId: chartId)
        await loadEntries()
        isLoading = false
    }
}
