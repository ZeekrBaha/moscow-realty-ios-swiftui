import Foundation

enum PropertyType: String, CaseIterable, Codable {
    case apartment = "apartment"
    case parking   = "parking"
    case storage   = "storage"

    var displayName: String {
        switch self {
        case .apartment: return "Квартира"
        case .parking:   return "Машиноместо"
        case .storage:   return "Кладовая"
        }
    }
}

enum ListingType: String, CaseIterable, Codable {
    case buy  = "buy"
    case rent = "rent"

    var displayName: String {
        switch self {
        case .buy:  return "Купить"
        case .rent: return "Аренда"
        }
    }
}

struct Coordinates: Codable, Equatable, Hashable {
    let latitude:  Double
    let longitude: Double
}

struct Property: Identifiable, Codable, Equatable, Hashable {
    let id:           UUID
    var propertyType: PropertyType
    var listingType:  ListingType
    var title:        String
    var price:        Int
    var address:      String
    var metro:        String?
    var district:     String
    var area:         Double
    var imageNames:   [String]
    var coordinates:  Coordinates
    var agentId:      UUID
    var description:  String
    // Apartment-only
    var rooms:        Int?
    var floor:        Int?
    var totalFloors:  Int?
    var isNewBuilding: Bool
    // Parking & Storage
    var isHeated:     Bool?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return listingType == .rent ? "\(formatted) ₽/мес" : "\(formatted) ₽"
    }

    var formattedArea: String { "\(Int(area)) м²" }
}
