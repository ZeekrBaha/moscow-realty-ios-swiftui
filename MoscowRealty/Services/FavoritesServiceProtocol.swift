import Foundation

protocol FavoritesServiceProtocol: AnyObject {
    func isFavorite(id: UUID) -> Bool
    func toggle(id: UUID)
    func fetchAllIds() -> Set<UUID>
}
