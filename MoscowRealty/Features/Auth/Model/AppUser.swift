import Foundation

enum UserRole: String, Codable, Equatable {
    case buyer = "buyer"
    case agent = "agent"
}

struct AppUser: Identifiable, Codable, Equatable {
    let id:            UUID
    var name:          String
    var email:         String
    var phone:         String?
    var role:          UserRole
    var agency:        String?
    var licenseNumber: String?

    var isAgent: Bool { role == .agent }
    var initials: String {
        name.split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}
