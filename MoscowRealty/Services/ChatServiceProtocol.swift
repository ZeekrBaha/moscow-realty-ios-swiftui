import Foundation

protocol ChatServiceProtocol {
    func fetchThreads(for userId: UUID) async -> [ChatThread]
    func fetchThread(id: UUID) async -> ChatThread?
    func sendMessage(_ text: String, threadId: UUID, senderId: UUID) async -> ChatMessage
    func markAsRead(threadId: UUID) async
}
