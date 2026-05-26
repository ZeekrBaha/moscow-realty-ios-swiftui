import Observation
import Foundation

@Observable
@MainActor
final class HomeViewModel {
    var featuredState: ViewState<[Property]> = .idle
    var selectedPropertyType: PropertyType = .apartment
    var selectedListingType: ListingType = .buy
    var selectedRooms: Int? = nil
    var priceMin: Int? = nil
    var priceMax: Int? = nil
    var metroQuery: String = ""

    var roomsLabel: String {
        guard let r = selectedRooms else { return "Комнаты" }
        return r < 4 ? "\(r) комн." : "4+ комн."
    }

    var priceLabel: String {
        if let min = priceMin, let max = priceMax {
            return "\(Self.shortPrice(min))–\(Self.shortPrice(max)) ₽"
        } else if let min = priceMin {
            return "от \(Self.shortPrice(min)) ₽"
        } else if let max = priceMax {
            return "до \(Self.shortPrice(max)) ₽"
        }
        return "Цена"
    }

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func load() async {
        featuredState = .loading
        // Fetch both listing types for home grid (shown in separate sections)
        async let buyResults  = propertyService.fetchProperties(filter: buildFilter(.buy))
        async let rentResults = propertyService.fetchProperties(filter: buildFilter(.rent))
        let all = await buyResults + rentResults
        featuredState = .loaded(all)
    }

    func applyFilters() async {
        await load()
    }

    private func buildFilter(_ listingType: ListingType) -> SearchFilter {
        var filter = SearchFilter()
        filter.propertyType = selectedPropertyType
        filter.listingType  = listingType
        if let r = selectedRooms { filter.rooms = [r] }
        filter.priceMin = priceMin
        filter.priceMax = priceMax
        filter.metro = metroQuery.isEmpty ? nil : metroQuery
        return filter
    }

    private static func shortPrice(_ value: Int) -> String {
        if value >= 1_000_000 {
            let m = Double(value) / 1_000_000
            return m.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(m)) млн"
                : String(format: "%.1f млн", m)
        } else if value >= 1_000 {
            return "\(value / 1_000) тыс"
        }
        return "\(value)"
    }
}
