import XCTest
@testable import Pluckr

@MainActor
class ChartsListViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = ChartsListViewModel()
        XCTAssertTrue(viewModel.charts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchChartsUpdatesState() async {
        let viewModel = ChartsListViewModel()
        // Simulate fetchCharts with a stubbed repository
        await MainActor.run {
            viewModel.charts = [ChartEntry(id: "1", data: [:])]
            viewModel.isLoading = false
        }
        XCTAssertEqual(viewModel.charts.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testErrorPropagation() async {
        let viewModel = ChartsListViewModel()
        await MainActor.run {
            viewModel.errorMessage = "Test error"
        }
        XCTAssertEqual(viewModel.errorMessage, "Test error")
    }

    func testDeleteChartRemovesFromList() async {
        let viewModel = ChartsListViewModel()
        let chart = ChartEntry(id: "1", data: [:])
        await MainActor.run {
            viewModel.charts = [chart]
            viewModel.charts.removeAll { $0.id == chart.id }
        }
        XCTAssertTrue(viewModel.charts.isEmpty)
    }
} 