import SwiftUI

// MARK: - Property Service
private struct PropertyServiceKey: EnvironmentKey {
    static let defaultValue: any PropertyServiceProtocol = MockPropertyService()
}

// MARK: - Auth Service
private struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: any AuthServiceProtocol = MockAuthService()
}

// MARK: - Chat Service
private struct ChatServiceKey: EnvironmentKey {
    static let defaultValue: any ChatServiceProtocol = MockChatService()
}

// MARK: - Favorites Service
private struct FavoritesServiceKey: EnvironmentKey {
    static let defaultValue: any FavoritesServiceProtocol = FavoritesService()
}

extension EnvironmentValues {
    var propertyService: any PropertyServiceProtocol {
        get { self[PropertyServiceKey.self] }
        set { self[PropertyServiceKey.self] = newValue }
    }
    var authService: any AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
    var chatService: any ChatServiceProtocol {
        get { self[ChatServiceKey.self] }
        set { self[ChatServiceKey.self] = newValue }
    }
    var favoritesService: any FavoritesServiceProtocol {
        get { self[FavoritesServiceKey.self] }
        set { self[FavoritesServiceKey.self] = newValue }
    }
}
