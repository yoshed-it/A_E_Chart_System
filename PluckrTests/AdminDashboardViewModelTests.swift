import XCTest
import Firebase
import FirebaseFirestore
@testable import Pluckr

@MainActor
class AdminDashboardViewModelTests: XCTestCase {
    // no instance vars needed
    
    // MARK: - Admin Dashboard ViewModel Tests
    
    func testAdminDashboardViewModelInitialization() {
        // Given & When
        let viewModel = AdminDashboardViewModel()
        
        // Then
        XCTAssertNotNil(viewModel, "AdminDashboardViewModel should be initialized")
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(viewModel.errorMessage, "Initial error message should be nil")
        XCTAssertNil(viewModel.successMessage, "Initial success message should be nil")
    }
    
    func testAdminDashboardViewModelStateManagement() {
        // Given
        let viewModel = AdminDashboardViewModel()
        
        // When
        viewModel.isLoading = true
        viewModel.errorMessage = "Test error"
        viewModel.successMessage = "Test success"
        
        // Then
        XCTAssertTrue(viewModel.isLoading, "Loading state should be settable")
        XCTAssertEqual(viewModel.errorMessage, "Test error", "Error message should be settable")
        XCTAssertEqual(viewModel.successMessage, "Test success", "Success message should be settable")
    }
} 