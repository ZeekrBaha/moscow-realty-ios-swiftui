import Observation
import SwiftUI

enum SearchDestination: Hashable {
    case propertyDetail(Property)
}

@Observable
final class SearchCoordinator {
    var path = NavigationPath()
    var isFilterSheetPresented = false

    func showDetail(_ property: Property) {
        path.append(SearchDestination.propertyDetail(property))
    }

    func showFilter() {
        isFilterSheetPresented = true
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
