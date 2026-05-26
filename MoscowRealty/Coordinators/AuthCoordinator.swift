import Observation
import SwiftUI

enum AuthDestination: Hashable {
    case registerBuyer
    case registerAgent
}

@Observable
final class AuthCoordinator {
    var path = NavigationPath()
    var onSuccess: ((AppUser) -> Void)?

    func showRegisterBuyer() {
        path.append(AuthDestination.registerBuyer)
    }

    func showRegisterAgent() {
        path.append(AuthDestination.registerAgent)
    }

    func complete(user: AppUser) {
        onSuccess?(user)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
