import XCTest
@testable import MoscowRealty

@MainActor
final class RegisterViewModelTests: XCTestCase {

    func test_registerBuyer_validData_succeeds() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Тест Пользователь"
        sut.email = "newbuyer@test.ru"
        sut.password = "secure123"
        sut.role = .buyer
        await sut.register()
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.registeredUser)
    }

    func test_registerBuyer_existingEmail_setsError() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Иван"
        sut.email = "buyer@test.ru"
        sut.password = "password"
        sut.role = .buyer
        await sut.register()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_registerAgent_withAgency_succeeds() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Агент Новый"
        sut.email = "newagent@test.ru"
        sut.password = "agent123"
        sut.phone = "+7 999 000-00-00"
        sut.agency = "АгентствоТест"
        sut.role = .agent
        await sut.register()
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.registeredUser?.agency, "АгентствоТест")
    }
}
