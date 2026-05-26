import Foundation

final class MockPropertyService: PropertyServiceProtocol {

    private var listings: [Property] = MockPropertyService.seedData()

    func fetchProperties(filter: SearchFilter) async -> [Property] {
        listings.filter { matches(filter, property: $0) }
    }

    func fetchProperty(id: UUID) async -> Property? {
        listings.first { $0.id == id }
    }

    func fetchAgentListings(agentId: UUID) async -> [Property] {
        listings.filter { $0.agentId == agentId }
    }

    func addListing(_ property: Property) async {
        listings.append(property)
    }

    func updateListing(_ property: Property) async {
        if let idx = listings.firstIndex(where: { $0.id == property.id }) {
            listings[idx] = property
        }
    }

    func deleteListing(id: UUID) async {
        listings.removeAll { $0.id == id }
    }

    // MARK: - Filter logic
    private func matches(_ filter: SearchFilter, property: Property) -> Bool {
        guard property.propertyType == filter.propertyType else { return false }
        guard property.listingType == filter.listingType else { return false }
        if !filter.rooms.isEmpty, let rooms = property.rooms {
            guard filter.rooms.contains(rooms) else { return false }
        }
        if let min = filter.priceMin { guard property.price >= min else { return false } }
        if let max = filter.priceMax { guard property.price <= max else { return false } }
        if let min = filter.areaMin  { guard property.area  >= min else { return false } }
        if let max = filter.areaMax  { guard property.area  <= max else { return false } }
        if let metro = filter.metro, !metro.isEmpty {
            guard property.metro?.localizedCaseInsensitiveContains(metro) == true else { return false }
        }
        if let district = filter.district, !district.isEmpty {
            guard property.district.localizedCaseInsensitiveContains(district) else { return false }
        }
        return true
    }

    // MARK: - Seed data
    static let agentAlexId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let agentMaria   = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    static func seedData() -> [Property] {
        [
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                propertyType: .apartment, listingType: .buy,
                title: "3-комн. квартира, Арбат",
                price: 28_500_000,
                address: "ул. Арбат, 15, кв. 42",
                metro: "Арбатская",
                district: "Центральный",
                area: 87.5,
                imageNames: ["apt_arbat_1", "apt_arbat_2"],
                coordinates: Coordinates(latitude: 55.7517, longitude: 37.5960),
                agentId: agentAlexId,
                description: "Просторная квартира в историческом центре. Высокие потолки, паркет, свежий ремонт. Вид на Арбат.",
                rooms: 3, floor: 4, totalFloors: 9, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                propertyType: .apartment, listingType: .buy,
                title: "2-комн. новостройка, Юго-Запад",
                price: 14_200_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 58.0,
                imageNames: ["apt_south_1", "apt_south_2"],
                coordinates: Coordinates(latitude: 55.6610, longitude: 37.4845),
                agentId: agentMaria,
                description: "Современная новостройка с отделкой под ключ. Закрытая территория, подземный паркинг.",
                rooms: 2, floor: 12, totalFloors: 25, isNewBuilding: true, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                propertyType: .apartment, listingType: .buy,
                title: "1-комн. квартира, Север",
                price: 9_800_000,
                address: "Дмитровское ш., 45",
                metro: "Дмитровская",
                district: "Северный",
                area: 38.0,
                imageNames: ["apt_north_1"],
                coordinates: Coordinates(latitude: 55.8097, longitude: 37.5711),
                agentId: agentAlexId,
                description: "Уютная квартира-студия. Рядом парк Дружбы, metro в 5 минутах ходьбы.",
                rooms: 1, floor: 7, totalFloors: 17, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                propertyType: .apartment, listingType: .rent,
                title: "2-комн. аренда, Сокол",
                price: 85_000,
                address: "ул. Балтийская, 3",
                metro: "Сокол",
                district: "Северный",
                area: 54.0,
                imageNames: ["apt_north_1", "apt_arbat_2"],
                coordinates: Coordinates(latitude: 55.8077, longitude: 37.5146),
                agentId: agentMaria,
                description: "Светлая двушка с евроремонтом. Вся необходимая мебель и техника.",
                rooms: 2, floor: 3, totalFloors: 5, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                propertyType: .apartment, listingType: .buy,
                title: "4-комн. квартира, Раменки",
                price: 32_000_000,
                address: "Мичуринский пр-т, 7",
                metro: "Раменки",
                district: "Западный",
                area: 120.0,
                imageNames: ["apt_south_1", "apt_arbat_1"],
                coordinates: Coordinates(latitude: 55.7188, longitude: 37.4460),
                agentId: agentAlexId,
                description: "Элитная квартира с панорамными окнами. Три санузла, гардеробная, два балкона.",
                rooms: 4, floor: 18, totalFloors: 22, isNewBuilding: true, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                propertyType: .parking, listingType: .buy,
                title: "Машиноместо, Центр",
                price: 2_800_000,
                address: "ул. Тверская, 10",
                metro: "Тверская",
                district: "Центральный",
                area: 18.0,
                imageNames: ["parking_center_1"],
                coordinates: Coordinates(latitude: 55.7648, longitude: 37.6024),
                agentId: agentMaria,
                description: "Охраняемый подземный паркинг. Видеонаблюдение 24/7. Высота 2.2 м.",
                rooms: nil, floor: -1, totalFloors: nil, isNewBuilding: false, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
                propertyType: .parking, listingType: .buy,
                title: "Машиноместо, Юго-Запад",
                price: 1_500_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 15.5,
                imageNames: ["parking_south_1"],
                coordinates: Coordinates(latitude: 55.6612, longitude: 37.4847),
                agentId: agentAlexId,
                description: "Паркинг в новом ЖК. Отапливаемый. Рядом с лифтом.",
                rooms: nil, floor: -2, totalFloors: nil, isNewBuilding: true, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000008")!,
                propertyType: .parking, listingType: .rent,
                title: "Аренда машиноместа, Сокол",
                price: 8_000,
                address: "ул. Балтийская, 3",
                metro: "Сокол",
                district: "Северный",
                area: 16.0,
                imageNames: ["parking_center_1"],
                coordinates: Coordinates(latitude: 55.8079, longitude: 37.5148),
                agentId: agentMaria,
                description: "Охраняемое машиноместо. Шлагбаум, видеокамеры.",
                rooms: nil, floor: 1, totalFloors: nil, isNewBuilding: false, isHeated: false
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000009")!,
                propertyType: .storage, listingType: .buy,
                title: "Кладовая, Юго-Запад",
                price: 450_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 5.2,
                imageNames: ["storage_1"],
                coordinates: Coordinates(latitude: 55.6613, longitude: 37.4846),
                agentId: agentAlexId,
                description: "Кладовая на -1 этаже ЖК. Сухая, тёплая, видеонаблюдение.",
                rooms: nil, floor: -1, totalFloors: nil, isNewBuilding: true, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000010")!,
                propertyType: .storage, listingType: .rent,
                title: "Аренда кладовой, Центр",
                price: 3_500,
                address: "ул. Тверская, 10",
                metro: "Тверская",
                district: "Центральный",
                area: 4.0,
                imageNames: ["storage_2"],
                coordinates: Coordinates(latitude: 55.7649, longitude: 37.6025),
                agentId: agentMaria,
                description: "Кладовое помещение в цокольном этаже. Доступ круглосуточно.",
                rooms: nil, floor: 0, totalFloors: nil, isNewBuilding: false, isHeated: false
            )
        ]
    }
}
