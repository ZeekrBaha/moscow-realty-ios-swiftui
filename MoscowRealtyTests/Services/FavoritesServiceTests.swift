import XCTest
@testable import MoscowRealty

final class FavoritesServiceTests: XCTestCase {

    var sut: FavoritesService!
    let testKey = "favorites_test"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
        sut = FavoritesService(userDefaultsKey: testKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }

    func test_isFavorite_returnsFalseByDefault() {
        let id = UUID()
        XCTAssertFalse(sut.isFavorite(id: id))
    }

    func test_toggle_addsFavorite() {
        let id = UUID()
        sut.toggle(id: id)
        XCTAssertTrue(sut.isFavorite(id: id))
    }

    func test_toggle_removesFavoriteOnSecondCall() {
        let id = UUID()
        sut.toggle(id: id)
        sut.toggle(id: id)
        XCTAssertFalse(sut.isFavorite(id: id))
    }

    func test_fetchAllIds_returnsToggled() {
        let id1 = UUID()
        let id2 = UUID()
        sut.toggle(id: id1)
        sut.toggle(id: id2)
        let all = sut.fetchAllIds()
        XCTAssertTrue(all.contains(id1))
        XCTAssertTrue(all.contains(id2))
    }

    func test_persistence_acrossInstances() {
        let id = UUID()
        sut.toggle(id: id)
        let sut2 = FavoritesService(userDefaultsKey: testKey)
        XCTAssertTrue(sut2.isFavorite(id: id))
    }
}
