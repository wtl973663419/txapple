import SwiftUI

struct ChatView: View {
    let conversationId: String
    var viewModel: TeatimeViewModel

    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var scrollToBottom: Bool = false

    private var conversation: ChatConversation? {
        viewModel.conversations.first { $0.id == conversationId }
    }

    private var messages: [ChatMessage] {
        viewModel.messages[conversationId] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onAppear {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            VStack(spacing: 0) {
                Divider().foregroundColor(.appDivider)

                HStack(spacing: 12) {
                    TextField("输入消息...", text: $messageText, axis: .vertical)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appBackgroundInput)
                        )
                        .focused($isInputFocused)
                        .lineLimit(1...4)

                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                          ? Color.appTextHint : Color.appPrimary)
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        .background(Color.appBackground)
        .navigationTitle(conversation?.friendName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if let conv = conversation {
                        Image(systemName: conv.friendAvatar)
                            .font(.caption)
                            .foregroundColor(.appPrimary)

                        Text(conv.friendName)
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)

                        if conv.isVip {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundColor(.vipGold)
                        }
                    }
                }
            }
        }
    }

    private func send() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.sendMessage(conversationId: conversationId, content: trimmed)
        messageText = ""
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversationId: "conv1",
            viewModel: TeatimeViewModel()
        )
        .task {
            let vm = TeatimeViewModel()
            vm.loadMockData()
        }
    }
}
