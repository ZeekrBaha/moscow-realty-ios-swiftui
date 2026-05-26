import Observation
import Foundation

@Observable
@MainActor
final class ChatDetailViewModel {
    var thread: ChatThread
    var draftText: String = ""
    var isSending: Bool = false

    private let chatService: any ChatServiceProtocol
    private let senderId: UUID

    init(thread: ChatThread,
         chatService: any ChatServiceProtocol = MockChatService(),
         senderId: UUID = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!) {
        self.thread = thread
        self.chatService = chatService
        self.senderId = senderId
    }

    func send() async {
        let text = draftText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        isSending = true
        draftText = ""
        let message = await chatService.sendMessage(text, threadId: thread.id, senderId: senderId)
        thread.messages.append(message)
        thread.lastMessage = message.text
        thread.lastMessageDate = message.date
        isSending = false
    }

    func markRead() async {
        await chatService.markAsRead(threadId: thread.id)
        thread.unreadCount = 0
    }
}
