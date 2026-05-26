import XCTest
@testable import MoscowRealty

@MainActor
final class AgentDashboardViewModelTests: XCTestCase {

    func test_load_returnsAgentListings() async {
        let sut = AgentDashboardViewModel(
            propertyService: MockPropertyService(),
            agentId: MockPropertyService.agentAlexId
        )
        await sut.load()
        guard case .loaded(let items) = sut.state else { XCTFail("Expected .loaded"); return }
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.agentId == MockPropertyService.agentAlexId })
    }

    func test_delete_removesListing() async {
        let service = MockPropertyService()
        let sut = AgentDashboardViewModel(propertyService: service, agentId: MockPropertyService.agentAlexId)
        await sut.load()
        guard case .loaded(let items) = sut.state, let first = items.first else { XCTFail(); return }
        await sut.delete(id: first.id)
        guard case .loaded(let updated) = sut.state else { XCTFail(); return }
        XCTAssertFalse(updated.contains { $0.id == first.id })
    }
}
