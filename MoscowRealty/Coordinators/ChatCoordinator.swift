import Observation
import SwiftUI

enum ChatDestination: Hashable {
    case threadDetail(ChatThread)
}

@Observable
final class ChatCoordinator {
    var path = NavigationPath()

    func showThread(_ thread: ChatThread) {
        path.append(ChatDestination.threadDetail(thread))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
