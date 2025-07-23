// DEPRECATED: This file is no longer used in the current app flow as of [date].
// Retained for reference only. Safe to delete after migration is complete.


//import Foundation
//import SwiftUI
//
//@MainActor
//class ChartsListViewModel: ObservableObject {
//    @Published var charts: [ChartEntry] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var activeTagPickerChart: ChartEntry?
//    
//    let availableTags: [Tag] = TagConstants.defaultChartTags
//    
//    private let clientRepository = ClientRepository()
//    
//    // MARK: - Chart Management
//    
//    func fetchCharts(for clientId: String) {
//        isLoading = true
//        errorMessage = nil
//        
//        clientRepository.fetchCharts(for: clientId) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success(let charts):
//                    self?.charts = charts
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//    
//    // MARK: - Tag Management
//    
//    func addTag(_ tag: Tag, to chart: ChartEntry, clientId: String) {
//        guard let index = charts.firstIndex(where: { $0.id == chart.id }) else { return }
//        var updatedChart = chart
//        if !updatedChart.chartTags.contains(tag) {
//            updatedChart.chartTags.append(tag)
//            charts[index] = updatedChart
//            saveChartTags(updatedChart, clientId: clientId)
//        }
//    }
//    
//    func removeTag(_ tag: Tag, from chart: ChartEntry, clientId: String) {
//        guard let index = charts.firstIndex(where: { $0.id == chart.id }) else { return }
//        var updatedChart = chart
//        updatedChart.chartTags.removeAll { $0 == tag }
//        charts[index] = updatedChart
//        saveChartTags(updatedChart, clientId: clientId)
//    }
//    
//    func updateTags(_ tags: [Tag], for chart: ChartEntry) {
//        guard let index = charts.firstIndex(where: { $0.id == chart.id }) else { return }
//        var updatedChart = chart
//        updatedChart.chartTags = tags
//        charts[index] = updatedChart
//    }
//    
//    func persistTags(_ tags: [Tag], for chart: ChartEntry, clientId: String) {
//        guard let index = charts.firstIndex(where: { $0.id == chart.id }) else { return }
//        var updatedChart = chart
//        updatedChart.chartTags = tags
//        charts[index] = updatedChart
//        saveChartTags(updatedChart, clientId: clientId)
//    }
//    
//    private func saveChartTags(_ chart: ChartEntry, clientId: String) {
//        let chartData = ChartEntryData(
//            modality: chart.modality,
//            rfLevel: chart.rfLevel,
//            dcLevel: chart.dcLevel,
//            probe: chart.probe,
//            probeIsOnePiece: chart.probeIsOnePiece,
//            treatmentArea: chart.treatmentArea,
//            skinCondition: chart.skinCondition,
//            comment: chart.comment,
//            notes: chart.notes,
//            imageURLs: chart.imageURLs,
//            createdAt: chart.createdAt,
//            lastEditedAt: Date(),
//            lastEditedBy: nil,
//            createdBy: chart.createdBy,
//            createdByName: chart.createdByName,
//            clientChosenName: chart.clientChosenName,
//            clientLegalName: chart.clientLegalName,
//            chartTags: chart.chartTags
//        )
//        
//        ChartService.shared.saveChartEntry(for: clientId, chartData: chartData, chartId: chart.id) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    break
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//    
//    func showTagPicker(for chart: ChartEntry) {
//        activeTagPickerChart = chart
//    }
//    
//    func hideTagPicker() {
//        activeTagPickerChart = nil
//    }
//    
//    // MARK: - Chart Deletion
//    
//    func deleteChart(for clientId: String, chartId: String, completion: @escaping (Bool) -> Void) {
//        Task {
//            await ChartEntryService.deleteEntry(for: clientId, chartId: chartId)
//            await MainActor.run {
//                // Remove from local array
//                charts.removeAll { $0.id == chartId }
//                completion(true)
//            }
//        }
//    }
//}
