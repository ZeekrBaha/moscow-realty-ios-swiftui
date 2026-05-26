import Observation
import Foundation

@Observable
@MainActor
final class AgentDashboardViewModel {
    var state: ViewState<[Property]> = .idle
    private let propertyService: any PropertyServiceProtocol
    private let agentId: UUID

    init(propertyService: any PropertyServiceProtocol = MockPropertyService(),
         agentId: UUID = UUID()) {
        self.propertyService = propertyService
        self.agentId = agentId
    }

    func load() async {
        state = .loading
        let listings = await propertyService.fetchAgentListings(agentId: agentId)
        state = .loaded(listings)
    }

    func delete(id: UUID) async {
        await propertyService.deleteListing(id: id)
        await load()
    }
}
