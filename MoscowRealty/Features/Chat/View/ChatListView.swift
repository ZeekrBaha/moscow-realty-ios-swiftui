import SwiftUI

struct ChatListView: View {
    @Environment(ChatCoordinator.self) private var coordinator
    @Environment(\.chatService) private var chatService
    @State private var viewModel: ChatListViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Чат")
        .task {
            let vm = ChatListViewModel(chatService: chatService)
            viewModel = vm
            await vm.load()
        }
    }

    @ViewBuilder
    private func content(vm: ChatListViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let threads):
            if threads.isEmpty {
                ContentUnavailableView(
                    "Нет сообщений",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Напишите агенту с карточки объявления")
                )
            } else {
                List(threads) { thread in
                    Button {
                        coordinator.showThread(thread)
                    } label: {
                        threadRow(thread)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        case .error(let msg):
            Text(msg).foregroundStyle(.red).padding()
        }
    }

    private func threadRow(_ thread: ChatThread) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "house.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.participantName)
                        .font(.headline)
                    Spacer()
                    Text(thread.lastMessageDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(thread.propertyTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(thread.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if thread.unreadCount > 0 {
                Text("\(thread.unreadCount)")
                    .font(.caption2).bold()
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.red, in: Circle())
            }
        }
        .padding(.vertical, 4)
    }
}
