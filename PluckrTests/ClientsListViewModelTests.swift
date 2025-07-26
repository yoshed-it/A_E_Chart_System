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

    func testSearchFunctionality() async {
        // Given
        let viewModel = ClientsListViewModel()
        let client1 = Client(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            phone: "123-456-7890",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider1",
            createdByName: "Provider One",
            clientTags: []
        )
        let client2 = Client(
            id: "2",
            firstName: "Jane",
            lastName: "Smith",
            phone: "098-765-4321",
            email: "jane@example.com",
            pronouns: "she/her",
            createdBy: "provider1",
            createdByName: "Provider One",
            clientTags: []
        )
        
        await MainActor.run {
            viewModel.clients = [client1, client2]
            viewModel.searchText = "John"
        }
        
        // When
        let filteredClients = await MainActor.run { viewModel.filteredClients }
        
        // Then
        XCTAssertEqual(filteredClients.count, 1, "Should filter clients by search text")
        XCTAssertEqual(filteredClients.first?.firstName, "John", "Should return correct client")
    }

    func testStateManagement() async {
        // Given
        let viewModel = ClientsListViewModel()
        
        // When & Then
        await MainActor.run {
            viewModel.isLoading = true
            XCTAssertTrue(viewModel.isLoading, "Loading state should be settable")
            
            viewModel.errorMessage = "Test error"
            XCTAssertEqual(viewModel.errorMessage, "Test error", "Error message should be settable")
            
            viewModel.searchText = "test search"
            XCTAssertEqual(viewModel.searchText, "test search", "Search text should be settable")
        }
    }
    
    func testSnackbarFunctionality() async {
        // Given
        let viewModel = ClientsListViewModel()
        let client = Client(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            phone: "123-456-7890",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider1",
            createdByName: "Provider One",
            clientTags: []
        )
        let action = ClientsListViewModel.FolioAction.added(client)
        
        // When
        await MainActor.run {
            viewModel.showSnackbar(message: "Client added", action: action)
        }
        
        // Then
        await MainActor.run {
            XCTAssertTrue(viewModel.showSnackbar, "Snackbar should be shown")
            XCTAssertEqual(viewModel.snackbarMessage, "Client added", "Snackbar message should be set")
            XCTAssertTrue(viewModel.canUndo, "Should be able to undo when action is set")
            
            if case .added(let addedClient) = viewModel.lastFolioAction {
                XCTAssertEqual(addedClient.id, client.id, "Action should contain correct client")
            } else {
                XCTFail("Last folio action should be 'added'")
            }
        }
    }
    
    func testUndoFunctionality() async {
        // Given
        let viewModel = ClientsListViewModel()
        let client = Client(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            phone: "123-456-7890",
            email: "john@example.com",
            pronouns: "he/him",
            createdBy: "provider1",
            createdByName: "Provider One",
            clientTags: []
        )
        let action = ClientsListViewModel.FolioAction.removed(client)
        
        await MainActor.run {
            viewModel.showSnackbar(message: "Client removed", action: action)
        }
        
        // When
        await MainActor.run {
            viewModel.undoLastFolioAction()
        }
        
        // Then
        await MainActor.run {
            XCTAssertTrue(viewModel.snackbarMessage.contains("Undid remove"), "Should show undo message")
            XCTAssertNil(viewModel.lastFolioAction, "Action should be cleared after undo")
        }
    }
} 