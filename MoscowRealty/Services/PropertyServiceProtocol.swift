import Foundation

protocol PropertyServiceProtocol {
    func fetchProperties(filter: SearchFilter) async -> [Property]
    func fetchProperty(id: UUID) async -> Property?
    func fetchAgentListings(agentId: UUID) async -> [Property]
    func addListing(_ property: Property) async
    func updateListing(_ property: Property) async
    func deleteListing(id: UUID) async
}
