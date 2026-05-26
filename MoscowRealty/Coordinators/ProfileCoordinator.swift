import Observation
import SwiftUI

enum ProfileDestination: Hashable {
    case propertyDetail(Property)
    case editListing(Property)
}

@Observable
final class ProfileCoordinator {
    var path = NavigationPath()
    var isAuthPresented = false

    func showLogin() { isAuthPresented = true }

    func showPropertyDetail(_ property: Property) {
        path.append(ProfileDestination.propertyDetail(property))
    }

    func showEditListing(_ property: Property) {
        path.append(ProfileDestination.editListing(property))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
