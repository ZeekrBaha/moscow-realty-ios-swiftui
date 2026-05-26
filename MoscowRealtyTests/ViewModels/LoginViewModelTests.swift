import XCTest
@testable import MoscowRealty

@MainActor
final class LoginViewModelTests: XCTestCase {

    func test_login_validCredentials_succeeds() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = "buyer@test.ru"
        sut.password = "password"
        await sut.login()
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.loggedInUser)
        XCTAssertEqual(sut.loggedInUser?.email, "buyer@test.ru")
    }

    func test_login_invalidCredentials_setsError() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = "wrong@test.ru"
        sut.password = "wrongpass"
        await sut.login()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.loggedInUser)
    }

    func test_login_emptyEmail_setsError() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = ""
        sut.password = "password"
        await sut.login()
        XCTAssertNotNil(sut.errorMessage)
    }
}
