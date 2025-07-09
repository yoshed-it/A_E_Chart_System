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
}
