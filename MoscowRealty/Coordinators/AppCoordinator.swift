import Observation
import Foundation

@Observable
final class AppCoordinator {
    let propertyService: any PropertyServiceProtocol
    let authService: any AuthServiceProtocol
    let chatService: any ChatServiceProtocol
    let favoritesService: any FavoritesServiceProtocol

    var currentUser: AppUser? { authService.currentUser }

    init(
        propertyService: any PropertyServiceProtocol  = MockPropertyService(),
        authService: any AuthServiceProtocol      = MockAuthService(),
        chatService: any ChatServiceProtocol      = MockChatService(),
        favoritesService: any FavoritesServiceProtocol = FavoritesService()
    ) {
        self.propertyService  = propertyService
        self.authService      = authService
        self.chatService      = chatService
        self.favoritesService = favoritesService
    }
}
