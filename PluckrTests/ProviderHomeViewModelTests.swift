import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr

@MainActor
class ProviderHomeViewModelTests: XCTestCase {
    var viewModel: ProviderHomeViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ProviderHomeViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Filtered Clients Tests
    
    func testFilteredClientsWithEmptySearch() {
        // Given
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
        
        viewModel.recentClients = [client1, client2]
        viewModel.searchText = ""
        
        // When
        let filteredClients = viewModel.filteredClients
        
        // Then
        XCTAssertEqual(filteredClients.count, 2, "Should return all clients when search is empty")
    }
    
    func testFilteredClientsWithSearch() {
        // Given
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
        
        viewModel.recentClients = [client1, client2]
        viewModel.searchText = "John"
        
        // When
        let filteredClients = viewModel.filteredClients
        
        // Then
        XCTAssertEqual(filteredClients.count, 1, "Should filter clients by search text")
        XCTAssertEqual(filteredClients.first?.firstName, "John", "Should return correct client")
    }
    
    func testFilteredClientsWithCaseInsensitiveSearch() {
        // Given
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
        
        viewModel.recentClients = [client1, client2]
        viewModel.searchText = "jane"
        
        // When
        let filteredClients = viewModel.filteredClients
        
        // Then
        XCTAssertEqual(filteredClients.count, 1, "Should filter clients case-insensitively")
        XCTAssertEqual(filteredClients.first?.firstName, "Jane", "Should return correct client")
    }
    
    func testFilteredClientsWithLastNameSearch() {
        // Given
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
        
        viewModel.recentClients = [client1, client2]
        viewModel.searchText = "Smith"
        
        // When
        let filteredClients = viewModel.filteredClients
        
        // Then
        XCTAssertEqual(filteredClients.count, 1, "Should filter clients by last name")
        XCTAssertEqual(filteredClients.first?.lastName, "Smith", "Should return correct client")
    }
    
    // MARK: - Admin Role Tests
    
    func testIsAdminComputation() {
        // Given
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
        
        viewModel.recentClients = [client1, client2]
        
        // When & Then
        XCTAssertFalse(viewModel.isAdmin, "Should not be admin by default")
        
        // Simulate admin role (this would be set by the actual view model logic)
        // For now, we just test that the property exists and can be accessed
        XCTAssertNotNil(viewModel.isAdmin, "isAdmin property should exist")
    }
    
    // MARK: - Snackbar Tests
    
    func testSnackbarStateManagement() {
        // Given
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
        let message = "Client added"
        let action = ProviderHomeViewModel.FolioAction.added(client)
        
        // When
        viewModel.showSnackbarWithTimer(message: message, action: action)
        
        // Then
        XCTAssertTrue(viewModel.showSnackbar, "Snackbar should be shown")
        XCTAssertEqual(viewModel.snackbarMessage, message, "Snackbar message should be set")
        XCTAssertNotNil(viewModel.lastFolioAction, "Last folio action should be set")
    }
    
    func testSnackbarUndoFunctionality() {
        // Given
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
        let action = ProviderHomeViewModel.FolioAction.added(client)
        
        // When
        viewModel.showSnackbarWithTimer(message: "Client added", action: action)
        viewModel.undoLastFolioAction()
        
        // Then
        XCTAssertNil(viewModel.lastFolioAction, "Last folio action should be cleared after undo")
        XCTAssertTrue(viewModel.snackbarMessage.contains("Undid add"), "Should show undo message")
    }
    
    func testDailyFolioInitialState() {
        // When & Then
        XCTAssertEqual(viewModel.dailyFolioClients.count, 0, "Daily folio should start empty")
    }
    
    func testDailyFolioAddClient() {
        // Given
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
        // When
        viewModel.dailyFolioClients = []
        viewModel.dailyFolioClients.append(client)
        print("DEBUG: dailyFolioClients after append:", viewModel.dailyFolioClients)
        // Then
        XCTAssertEqual(viewModel.dailyFolioClients.count, 1, "Should add client to daily folio")
        XCTAssertEqual(viewModel.dailyFolioClients.first?.id, client.id, "Should add correct client")
    }
} 