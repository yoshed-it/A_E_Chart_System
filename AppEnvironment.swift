import Foundation
import SwiftUI

// MARK: - AppEnvironment
/// Centralizes all shared services and repositories for dependency injection and testability.
struct AppEnvironment {
    let clientRepository: ClientRepository
    let chartService: ChartService
    let authService: AuthService
    let tagService: TagService
    // Add other shared services/repositories as needed

    /// Default production environment using current singletons
    static let live = AppEnvironment(
        clientRepository: ClientRepository(),
        chartService: ChartService.shared,
        authService: AuthService.shared,
        tagService: TagService.shared
    )
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
} 