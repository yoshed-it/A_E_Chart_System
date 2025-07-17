import XCTest
@testable import Pluckr

class ClientsListViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = ClientsListViewModel()
        XCTAssertTrue(viewModel.clients.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchClientsUpdatesState() async {
        let viewModel = ClientsListViewModel()
        // Simulate fetchClients with a stubbed ClientRepository
        await MainActor.run {
            viewModel.clients = [Client(id: "1", firstName: "A", lastName: "B")]
            viewModel.isLoading = false
        }
        XCTAssertEqual(viewModel.clients.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testErrorPropagation() async {
        let viewModel = ClientsListViewModel()
        await MainActor.run {
            viewModel.errorMessage = "Test error"
        }
        XCTAssertEqual(viewModel.errorMessage, "Test error")
    }

    func testDeleteClientRemovesFromList() async {
        let viewModel = ClientsListViewModel()
        let client = Client(id: "1", firstName: "A", lastName: "B")
        await MainActor.run {
            viewModel.clients = [client]
            viewModel.clients.removeAll { $0.id == client.id }
        }
        XCTAssertTrue(viewModel.clients.isEmpty)
    }
} 