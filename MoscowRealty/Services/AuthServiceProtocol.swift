import Foundation

protocol AuthServiceProtocol: AnyObject {
    var currentUser: AppUser? { get }
    func login(email: String, password: String) async throws -> AppUser
    func register(_ user: AppUser, password: String) async throws -> AppUser
    func logout()
}
