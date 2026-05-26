import Observation
import Foundation

@Observable
@MainActor
final class RegisterViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var phone: String = ""
    var agency: String = ""
    var licenseNumber: String = ""
    var role: UserRole = .buyer
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var registeredUser: AppUser? = nil

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    func register() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        isLoading = true
        errorMessage = nil
        let user = AppUser(
            id: UUID(),
            name: name,
            email: email.lowercased(),
            phone: phone.isEmpty ? nil : phone,
            role: role,
            agency: agency.isEmpty ? nil : agency,
            licenseNumber: licenseNumber.isEmpty ? nil : licenseNumber
        )
        do {
            let registered = try await authService.register(user, password: password)
            registeredUser = registered
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.networkError.errorDescription
        }
        isLoading = false
    }
}
