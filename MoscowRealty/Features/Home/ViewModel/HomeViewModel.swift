import Observation
import Foundation

@Observable
@MainActor
final class HomeViewModel {
    var featuredState: ViewState<[Property]> = .idle
    var selectedPropertyType: PropertyType = .apartment
    var selectedListingType: ListingType = .buy

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func load() async {
        featuredState = .loading
        var filter = SearchFilter()
        filter.propertyType = selectedPropertyType
        filter.listingType  = selectedListingType
        let results = await propertyService.fetchProperties(filter: filter)
        featuredState = .loaded(results)
    }

    func selectType(_ type: PropertyType) async {
        selectedPropertyType = type
        await load()
    }

    func selectListingType(_ type: ListingType) async {
        selectedListingType = type
        await load()
    }
}
