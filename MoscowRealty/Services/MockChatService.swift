import Foundation

final class MockChatService: ChatServiceProtocol {

    private var threads: [ChatThread] = MockChatService.seedThreads()

    func fetchThreads(for userId: UUID) async -> [ChatThread] {
        threads
    }

    func fetchThread(id: UUID) async -> ChatThread? {
        threads.first { $0.id == id }
    }

    func sendMessage(_ text: String, threadId: UUID, senderId: UUID) async -> ChatMessage {
        let message = ChatMessage(
            id: UUID(),
            text: text,
            senderId: senderId,
            date: Date(),
            isFromCurrentUser: true
        )
        if let idx = threads.firstIndex(where: { $0.id == threadId }) {
            threads[idx].messages.append(message)
            threads[idx].lastMessage = text
            threads[idx].lastMessageDate = Date()
            threads[idx].unreadCount = 0
        }
        return message
    }

    func markAsRead(threadId: UUID) async {
        if let idx = threads.firstIndex(where: { $0.id == threadId }) {
            threads[idx].unreadCount = 0
        }
    }

    static func seedThreads() -> [ChatThread] {
        let agentId = MockPropertyService.agentAlexId
        let buyerId = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!

        return [
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                propertyTitle: "3-комн. квартира, Арбат",
                participantName: "Алекс Агентов",
                lastMessage: "Да, можем организовать показ в субботу",
                lastMessageDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                unreadCount: 1,
                messages: [
                    ChatMessage(id: UUID(), text: "Здравствуйте! Меня интересует квартира на Арбате. Когда можно посмотреть?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Добрый день! Квартира свободна для просмотра. Когда вам удобно?",
                                senderId: agentId, date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, isFromCurrentUser: false),
                    ChatMessage(id: UUID(), text: "Можно в субботу утром?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .minute, value: -90, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Да, можем организовать показ в субботу",
                                senderId: agentId, date: Calendar.current.date(byAdding: .minute, value: -120, to: Date())!, isFromCurrentUser: false)
                ]
            ),
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                propertyTitle: "2-комн. новостройка, Юго-Запад",
                participantName: "Мария Агентова",
                lastMessage: "Цена окончательная, торга нет",
                lastMessageDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                unreadCount: 0,
                messages: [
                    ChatMessage(id: UUID(), text: "Возможен ли торг по цене?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Цена окончательная, торга нет",
                                senderId: MockPropertyService.agentMaria, date: Calendar.current.date(byAdding: .hour, value: -20, to: Date())!, isFromCurrentUser: false)
                ]
            ),
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                propertyTitle: "Машиноместо, Центр",
                participantName: "Мария Агентова",
                lastMessage: "Высота въезда 2 метра 10 сантиметров",
                lastMessageDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                unreadCount: 0,
                messages: [
                    ChatMessage(id: UUID(), text: "Какая высота въезда в паркинг?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Высота въезда 2 метра 10 сантиметров",
                                senderId: MockPropertyService.agentMaria, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, isFromCurrentUser: false)
                ]
            )
        ]
    }
}
