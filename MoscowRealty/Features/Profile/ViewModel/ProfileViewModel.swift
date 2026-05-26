import Observation
import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    var currentUser: AppUser? { authService.currentUser }
    var isLoggedIn: Bool { authService.currentUser != nil }
    var isAgent: Bool { authService.currentUser?.isAgent == true }

    func logout() { authService.logout() }
}
