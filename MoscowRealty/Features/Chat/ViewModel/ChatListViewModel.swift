import Observation
import Foundation

@Observable
@MainActor
final class ChatListViewModel {
    var state: ViewState<[ChatThread]> = .idle
    private let chatService: any ChatServiceProtocol
    private let userId: UUID

    init(chatService: any ChatServiceProtocol = MockChatService(),
         userId: UUID = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!) {
        self.chatService = chatService
        self.userId = userId
    }

    func load() async {
        state = .loading
        let threads = await chatService.fetchThreads(for: userId)
        state = .loaded(threads.sorted { $0.lastMessageDate > $1.lastMessageDate })
    }
}
