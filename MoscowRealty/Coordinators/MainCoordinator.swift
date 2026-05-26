import Observation
import SwiftUI

enum MainDestination: Hashable {
    case propertyDetail(Property)
    case catalogMap([Property])
}

@Observable
final class MainCoordinator {
    var path = NavigationPath()

    func showDetail(_ property: Property) {
        path.append(MainDestination.propertyDetail(property))
    }

    func showMap(_ properties: [Property]) {
        path.append(MainDestination.catalogMap(properties))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
