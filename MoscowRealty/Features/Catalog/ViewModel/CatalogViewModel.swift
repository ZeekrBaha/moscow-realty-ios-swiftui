import Observation
import Foundation

@Observable
@MainActor
final class CatalogViewModel {
    var state: ViewState<[Property]> = .idle
    var filter: SearchFilter = SearchFilter()
    var showMap: Bool = false

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func load() async {
        state = .loading
        let results = await propertyService.fetchProperties(filter: filter)
        state = .loaded(results)
    }

    func toggleView() { showMap.toggle() }
}
