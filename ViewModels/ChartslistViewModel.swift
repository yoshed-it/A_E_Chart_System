import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ChartsListViewModel: ObservableObject {
    @Published var charts: [ChartEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let clientRepo = ClientRepository()

    func fetchCharts(for clientId: String) {
        isLoading = true
        errorMessage = nil
        
        clientRepo.fetchCharts(for: clientId) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let entries):
                    self?.charts = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                self?.isLoading = false
            }
        }
    }

    func deleteChart(for clientId: String, chartId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        let docRef = db.collection("clients").document(clientId).collection("charts").document(chartId)
        docRef.delete { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    // Remove from local list
                    self?.charts.removeAll { $0.id == chartId }
                    completion(true)
                }
                self?.isLoading = false
            }
        }
    }
}
