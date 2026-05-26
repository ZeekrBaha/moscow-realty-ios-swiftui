import Foundation

final class FavoritesService: FavoritesServiceProtocol {

    private let key: String
    private var ids: Set<UUID>

    init(userDefaultsKey: String = "com.baha.moscowrealty.favorites") {
        self.key = userDefaultsKey
        let strings = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        self.ids = Set(strings.compactMap { UUID(uuidString: $0) })
    }

    func isFavorite(id: UUID) -> Bool { ids.contains(id) }

    func toggle(id: UUID) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        persist()
    }

    func fetchAllIds() -> Set<UUID> { ids }

    private func persist() {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: key)
    }
}
