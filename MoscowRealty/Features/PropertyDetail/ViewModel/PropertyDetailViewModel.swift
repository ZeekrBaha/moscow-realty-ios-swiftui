import Observation
import Foundation

@Observable
@MainActor
final class PropertyDetailViewModel {
    let property: Property
    var isFavorite: Bool

    private let favoritesService: any FavoritesServiceProtocol

    init(property: Property, favoritesService: any FavoritesServiceProtocol = FavoritesService()) {
        self.property = property
        self.favoritesService = favoritesService
        self.isFavorite = favoritesService.isFavorite(id: property.id)
    }

    func toggleFavorite() {
        favoritesService.toggle(id: property.id)
        isFavorite = favoritesService.isFavorite(id: property.id)
    }

    var specsRows: [(label: String, value: String)] {
        var rows: [(label: String, value: String)] = []
        if let rooms = property.rooms    { rows.append(("Комнат", "\(rooms)")) }
        rows.append(("Площадь", property.formattedArea))
        if let floor = property.floor,
           let total = property.totalFloors { rows.append(("Этаж", "\(floor) из \(total)")) }
        if property.isNewBuilding            { rows.append(("Тип", "Новостройка")) }
        if let heated = property.isHeated   { rows.append(("Отопление", heated ? "Есть" : "Нет")) }
        if let metro = property.metro        { rows.append(("Метро", metro)) }
        rows.append(("Район", property.district))
        return rows
    }
}
