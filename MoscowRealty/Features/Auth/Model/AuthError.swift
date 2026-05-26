import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyTaken
    case requiredFieldEmpty
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:  return "Неверный email или пароль"
        case .emailAlreadyTaken:   return "Этот email уже зарегистрирован"
        case .requiredFieldEmpty:  return "Заполните все обязательные поля"
        case .networkError:        return "Ошибка соединения, попробуйте ещё раз"
        }
    }
}
