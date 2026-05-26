import XCTest
@testable import MoscowRealty

@MainActor
final class HomeViewModelTests: XCTestCase {

    func test_load_populatesApartments() async {
        let sut = HomeViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let items) = sut.featuredState else {
            XCTFail("Expected .loaded, got \(sut.featuredState)")
            return
        }
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .apartment })
    }

    func test_load_setsLoadingThenLoaded() async {
        let sut = HomeViewModel(propertyService: MockPropertyService())
        XCTAssertEqual(sut.featuredState.isLoading, false)
        let task = Task { await sut.load() }
        await task.value
        guard case .loaded = sut.featuredState else {
            XCTFail("Expected .loaded after task")
            return
        }
    }
}
