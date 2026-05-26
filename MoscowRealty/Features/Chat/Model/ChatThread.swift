import Foundation

struct ChatThread: Identifiable, Codable {
    let id:              UUID
    var propertyId:      UUID
    var propertyTitle:   String
    var participantName: String
    var lastMessage:     String
    var lastMessageDate: Date
    var unreadCount:     Int
    var messages:        [ChatMessage]
}
