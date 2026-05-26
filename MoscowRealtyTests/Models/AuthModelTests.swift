import XCTest
@testable import MoscowRealty

final class AuthModelTests: XCTestCase {

    func test_appUser_buyerRole() {
        let user = AppUser(
            id: UUID(),
            name: "Иван Петров",
            email: "ivan@example.com",
            phone: nil,
            role: .buyer,
            agency: nil,
            licenseNumber: nil
        )
        XCTAssertEqual(user.role, .buyer)
        XCTAssertNil(user.agency)
    }

    func test_appUser_agentRole() {
        let user = AppUser(
            id: UUID(),
            name: "Мария Агентова",
            email: "agent@realty.ru",
            phone: "+7 999 123-45-67",
            role: .agent,
            agency: "ЦИАНРиелт",
            licenseNumber: "МСК-12345"
        )
        XCTAssertEqual(user.role, .agent)
        XCTAssertEqual(user.agency, "ЦИАНРиелт")
    }

    func test_searchFilter_defaults() {
        let filter = SearchFilter()
        XCTAssertEqual(filter.propertyType, .apartment)
        XCTAssertEqual(filter.listingType, .buy)
        XCTAssertTrue(filter.rooms.isEmpty)
        XCTAssertNil(filter.priceMin)
        XCTAssertNil(filter.priceMax)
    }
}
