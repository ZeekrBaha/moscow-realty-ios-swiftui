import Foundation

final class MockAuthService: AuthServiceProtocol {

    private(set) var currentUser: AppUser?

    private let seedBuyer = AppUser(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
        name: "Иван Петров",
        email: "buyer@test.ru",
        phone: nil,
        role: .buyer,
        agency: nil,
        licenseNumber: nil
    )

    private let seedAgent = AppUser(
        id: MockPropertyService.agentAlexId,
        name: "Алекс Агентов",
        email: "agent@test.ru",
        phone: "+7 916 111-22-33",
        role: .agent,
        agency: "МоскваРиелт",
        licenseNumber: "МСК-00001"
    )

    private var registeredUsers: [String: (AppUser, String)] = [:]  // email → (user, password)

    init() {
        registeredUsers["buyer@test.ru"] = (seedBuyer, "password")
        registeredUsers["agent@test.ru"] = (seedAgent, "password")
    }

    func login(email: String, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard let (user, storedPassword) = registeredUsers[email.lowercased()],
              storedPassword == password else {
            throw AuthError.invalidCredentials
        }
        currentUser = user
        return user
    }

    func register(_ user: AppUser, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard !user.email.isEmpty, !password.isEmpty else {
            throw AuthError.requiredFieldEmpty
        }
        guard registeredUsers[user.email.lowercased()] == nil else {
            throw AuthError.emailAlreadyTaken
        }
        registeredUsers[user.email.lowercased()] = (user, password)
        currentUser = user
        return user
    }

    func logout() { currentUser = nil }
}
