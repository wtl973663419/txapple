import SwiftUI

// MARK: - GuBanXian Chat View

/// Full chat view for the 股半仙 AI fortune-telling bot.
struct GuBanXianChatView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: GuBanXianViewModel
    @State private var inputText = ""
    @State private var scrollToID: String?

    init() {
        _viewModel = State(initialValue: GuBanXianViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Messages
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        // Thinking indicator
                        if viewModel.isThinking {
                            thinkingView
                        }

                        // Bottom spacer
                        Color.clear.frame(height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .background(Color.appBackground)
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMsg = viewModel.messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(lastMsg.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isThinking) { _, thinking in
                    if thinking {
                        withAnimation {
                            scrollProxy.scrollTo("thinkingIndicator", anchor: .bottom)
                        }
                    }
                }
            }

            Divider().background(Color.appDivider)

            // Input bar
            inputBar
        }
        .onAppear {
            viewModel.isVip = appState.isVip
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Text("仙")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("股半仙")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("在线 · 无所不算")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Info button
            Button {
                // Show bot capabilities
                let capabilityMsg = GuBanXianKeywordRouter().route(text: "你是谁", isVip: appState.isVip)
                viewModel.messages.append(ChatMessage(
                    id: UUID().uuidString,
                    conversationId: "gubanxian_bot",
                    senderId: "gubanxian_bot",
                    content: capabilityMsg,
                    timestamp: ISO8601DateFormatter().string(from: Date()),
                    isFromMe: false,
                    isRead: true
                ))
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    // MARK: - Thinking Indicator

    private var thinkingView: some View {
        HStack(spacing: 6) {
            ProgressView()
                .scaleEffect(0.7)
                .tint(.appTextSecondary)
            Text("股半仙正在掐指推算...")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .id("thinkingIndicator")
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("说点什么...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appBackgroundInput)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.appDivider, lineWidth: 1)
                )
                .disabled(viewModel.isThinking)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(canSend ? Color.appPrimary : Color.gray.opacity(0.4))
                    )
            }
            .disabled(!canSend || viewModel.isThinking)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        viewModel.processMessage(text: text)
    }
}

// MARK: - Chat Bubble View

struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isFromMe {
                // Bot avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    Text("仙")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                if !message.isFromMe {
                    Text("股半仙")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                        .padding(.leading, 4)
                }

                Text(message.content)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isFromMe ? Color.appPrimary : Color.white)
                    )
                    .foregroundColor(message.isFromMe ? .white : .appTextPrimary)
                    .shadow(color: .black.opacity(0.04), radius: 1, y: 1)

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.appTextHint)
                    .padding(.horizontal, 4)
            }

            if message.isFromMe {
                // User avatar placeholder
                ZStack {
                    Circle()
                        .fill(Color.appChipBlue)
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.appPrimary)
                }
            } else {
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }

    private func formatTime(_ iso: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: iso) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    GuBanXianChatView()
        .environment(AppState())
}
