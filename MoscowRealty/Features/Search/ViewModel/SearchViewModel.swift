import Observation
import Foundation

@Observable
@MainActor
final class SearchViewModel {
    var state: ViewState<[Property]> = .idle
    var filter: SearchFilter = SearchFilter()
    var queryText: String = ""

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func search() async {
        state = .loading
        var f = filter
        if !queryText.trimmingCharacters(in: .whitespaces).isEmpty {
            f.metro = queryText
        }
        let results = await propertyService.fetchProperties(filter: f)
        state = .loaded(results)
    }

    func resetFilter() {
        filter = SearchFilter()
        queryText = ""
    }
}
