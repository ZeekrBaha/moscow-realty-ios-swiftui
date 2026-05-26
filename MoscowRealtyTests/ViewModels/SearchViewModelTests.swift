import XCTest
@testable import MoscowRealty

@MainActor
final class SearchViewModelTests: XCTestCase {

    func test_search_emptyQuery_returnsAll() async {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        await sut.search()
        guard case .loaded(let items) = sut.state else { XCTFail(); return }
        XCTAssertFalse(items.isEmpty)
    }

    func test_search_withParkingFilter_onlyParking() async {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        sut.filter.propertyType = .parking
        await sut.search()
        guard case .loaded(let items) = sut.state else { XCTFail(); return }
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .parking })
    }

    func test_resetFilter_clearsFilter() {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        sut.filter.priceMin = 5_000_000
        sut.filter.rooms = [2, 3]
        sut.resetFilter()
        XCTAssertNil(sut.filter.priceMin)
        XCTAssertTrue(sut.filter.rooms.isEmpty)
    }
}
