import XCTest
@testable import MoscowRealty

@MainActor
final class CatalogViewModelTests: XCTestCase {

    func test_load_returnsPropertiesMatchingFilter() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        sut.filter.propertyType = .parking
        sut.filter.listingType  = .buy
        await sut.load()
        guard case .loaded(let items) = sut.state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .parking && $0.listingType == .buy })
    }

    func test_load_apartments_returnsNonEmpty() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let items) = sut.state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertFalse(items.isEmpty)
    }

    func test_applyFilter_updatesResults() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let allApartments) = sut.state else { XCTFail(); return }

        sut.filter.rooms = [1]
        await sut.load()
        guard case .loaded(let oneRoom) = sut.state else { XCTFail(); return }
        XCTAssertTrue(oneRoom.count <= allApartments.count)
        XCTAssertFalse(oneRoom.isEmpty, "1-room filter should match at least one property in seed data")
        XCTAssertTrue(oneRoom.allSatisfy { $0.rooms == 1 })
    }
}
