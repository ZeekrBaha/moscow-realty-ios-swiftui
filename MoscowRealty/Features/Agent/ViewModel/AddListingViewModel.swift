import Observation
import Foundation

@Observable
@MainActor
final class AddListingViewModel {
    var propertyType: PropertyType = .apartment
    var listingType: ListingType = .buy
    var address: String = ""
    var district: String = ""
    var metro: String = ""
    var title: String = ""
    var area: Double = 0
    var price: Int = 0
    var rooms: Int = 1
    var floor: Int = 1
    var totalFloors: Int = 1
    var isNewBuilding: Bool = false
    var isHeated: Bool = false
    var description: String = ""
    var selectedImageNames: [String] = []
    var isSubmitting: Bool = false
    var isSubmitted: Bool = false
    var errorMessage: String?

    let availableImages = [
        "apt_arbat_1", "apt_arbat_2", "apt_south_1", "apt_south_2",
        "apt_north_1", "parking_center_1", "parking_south_1", "storage_1", "storage_2"
    ]

    private let propertyService: any PropertyServiceProtocol
    private let agentId: UUID

    init(propertyService: any PropertyServiceProtocol = MockPropertyService(),
         agentId: UUID = UUID()) {
        self.propertyService = propertyService
        self.agentId = agentId
    }

    func submit() async {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Укажите название объявления"
            return
        }
        guard !address.isEmpty else {
            errorMessage = "Укажите адрес"
            return
        }
        guard area > 0 else {
            errorMessage = "Укажите площадь"
            return
        }
        guard price > 0 else {
            errorMessage = "Укажите цену"
            return
        }
        isSubmitting = true
        errorMessage = nil
        let property = Property(
            id: UUID(),
            propertyType: propertyType,
            listingType: listingType,
            title: title,
            price: price,
            address: address,
            metro: metro.isEmpty ? nil : metro,
            district: district,
            area: area,
            imageNames: selectedImageNames.isEmpty ? ["placeholder"] : selectedImageNames,
            coordinates: Coordinates(latitude: 55.7558, longitude: 37.6176),
            agentId: agentId,
            description: description,
            rooms: propertyType == .apartment ? rooms : nil,
            floor: floor,
            totalFloors: propertyType == .apartment ? totalFloors : nil,
            isNewBuilding: isNewBuilding,
            isHeated: propertyType != .apartment ? isHeated : nil
        )
        await propertyService.addListing(property)
        isSubmitting = false
        isSubmitted = true
    }

    func populate(from existing: Property) {
        propertyType = existing.propertyType
        listingType = existing.listingType
        title = existing.title
        address = existing.address
        district = existing.district
        metro = existing.metro ?? ""
        area = existing.area
        price = existing.price
        rooms = existing.rooms ?? 1
        floor = existing.floor ?? 1
        totalFloors = existing.totalFloors ?? 1
        isNewBuilding = existing.isNewBuilding
        isHeated = existing.isHeated ?? false
        description = existing.description
        selectedImageNames = existing.imageNames
    }
}
