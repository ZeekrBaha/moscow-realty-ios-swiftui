import Observation
import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var loggedInUser: AppUser?

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    func login() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        guard !password.isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authService.login(email: email.lowercased(), password: password)
            loggedInUser = user
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.networkError.errorDescription
        }
        isLoading = false
    }
}
