import SwiftUI
struct ChatDetailView: View {
    let thread: ChatThread
    var body: some View { Text(thread.propertyTitle) }
}
