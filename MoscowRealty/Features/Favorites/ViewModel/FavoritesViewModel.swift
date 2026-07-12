import Observation
import Foundation

@Observable
@MainActor
final class FavoritesViewModel {
    var state: ViewState<[Property]> = .idle

    private let propertyService: any PropertyServiceProtocol
    private let favoritesService: any FavoritesServiceProtocol

    init(
        propertyService: any PropertyServiceProtocol  = MockPropertyService(),
        favoritesService: any FavoritesServiceProtocol = FavoritesService()
    ) {
        self.propertyService  = propertyService
        self.favoritesService = favoritesService
    }

    func load() async {
        state = .loading
        let ids = favoritesService.fetchAllIds()
        guard !ids.isEmpty else {
            state = .loaded([])
            return
        }
        var all: [Property] = []
        for type in PropertyType.allCases {
            for listing in ListingType.allCases {
                var f = SearchFilter()
                f.propertyType = type
                f.listingType  = listing
                all += await propertyService.fetchProperties(filter: f)
            }
        }
        let favorites = all.filter { ids.contains($0.id) }
        state = .loaded(favorites)
    }

    func removeFavorite(id: UUID) async {
        favoritesService.toggle(id: id)
        await load()
    }
}
