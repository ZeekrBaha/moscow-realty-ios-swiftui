import XCTest
@testable import MoscowRealty

@MainActor
final class AddListingViewModelTests: XCTestCase {

    func test_submit_validData_succeeds() async {
        let service = MockPropertyService()
        let sut = AddListingViewModel(propertyService: service, agentId: MockPropertyService.agentAlexId)
        sut.title = "Тест квартира"
        sut.address = "ул. Тестовая, 1"
        sut.district = "Центральный"
        sut.area = 60
        sut.price = 10_000_000
        sut.rooms = 2
        await sut.submit()
        XCTAssertTrue(sut.isSubmitted)
        XCTAssertNil(sut.errorMessage)
    }

    func test_submit_missingTitle_setsError() async {
        let sut = AddListingViewModel(propertyService: MockPropertyService(), agentId: MockPropertyService.agentAlexId)
        sut.title = ""
        await sut.submit()
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNotNil(sut.errorMessage)
    }
}
