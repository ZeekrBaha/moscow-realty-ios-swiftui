import XCTest
@testable import MoscowRealty

final class PropertyModelTests: XCTestCase {

    func test_property_defaultsCorrect() {
        let coords = Coordinates(latitude: 55.7558, longitude: 37.6176)
        let property = Property(
            id: UUID(),
            propertyType: .apartment,
            listingType: .buy,
            title: "3-комн. квартира",
            price: 15_000_000,
            address: "ул. Арбат, 1",
            metro: "Арбатская",
            district: "Центральный",
            area: 85.0,
            imageNames: ["apt_center_1"],
            coordinates: coords,
            agentId: UUID(),
            description: "Просторная квартира",
            rooms: 3,
            floor: 5,
            totalFloors: 12,
            isNewBuilding: true,
            isHeated: nil
        )
        XCTAssertEqual(property.propertyType, .apartment)
        XCTAssertEqual(property.listingType, .buy)
        XCTAssertEqual(property.rooms, 3)
        XCTAssertEqual(property.price, 15_000_000)
        XCTAssertEqual(property.formattedPrice, "15 000 000 ₽")
        XCTAssertEqual(property.formattedArea, "85 м²")
    }

    func test_propertyType_allCasesExist() {
        XCTAssertEqual(PropertyType.allCases.count, 3)
        XCTAssertTrue(PropertyType.allCases.contains(.apartment))
        XCTAssertTrue(PropertyType.allCases.contains(.parking))
        XCTAssertTrue(PropertyType.allCases.contains(.storage))
    }

    func test_viewState_loadedContainsValue() {
        let state: ViewState<[String]> = .loaded(["a", "b"])
        guard case .loaded(let items) = state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertEqual(items, ["a", "b"])
    }
}
