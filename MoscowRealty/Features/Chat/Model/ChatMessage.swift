import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id:                UUID
    var text:              String
    var senderId:          UUID
    var date:              Date
    var isFromCurrentUser: Bool
}
