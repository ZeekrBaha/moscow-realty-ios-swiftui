import SwiftUI

struct ChatDetailView: View {
    let thread: ChatThread
    @Environment(\.chatService) private var chatService
    @State private var viewModel: ChatDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                VStack(spacing: 0) {
                    messagesList(vm: vm)
                    Divider()
                    inputBar(vm: vm)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(thread.participantName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let vm = ChatDetailViewModel(thread: thread, chatService: chatService)
            viewModel = vm
            await vm.markRead()
        }
    }

    private func messagesList(vm: ChatDetailViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(vm.thread.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: vm.thread.messages.count) { _, _ in
                if let last = vm.thread.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isFromCurrentUser { Spacer(minLength: 60) }
            Text(message.text)
                .padding(10)
                .background(message.isFromCurrentUser ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if !message.isFromCurrentUser { Spacer(minLength: 60) }
        }
    }

    private func inputBar(vm: ChatDetailViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(spacing: 8) {
            TextField("Сообщение...", text: $vm.draftText, axis: .vertical)
                .lineLimit(1...4)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                Task { await vm.send() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : Color.accentColor)
                    .clipShape(Circle())
            }
            .disabled(vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSending)
        }
        .padding(12)
    }
}
