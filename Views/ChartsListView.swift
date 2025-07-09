import SwiftUI

struct ChartsListView: View {
    @StateObject private var viewModel = ChartsListViewModel()
    let clientId: String

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading charts...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
            } else {
                List(viewModel.charts) { chart in
                    ChartRowView(chart: chart)
                }
            }
        }
        .onAppear {
            viewModel.fetchCharts(for: clientId)
        }
        .navigationTitle("Charts")
    }
}
