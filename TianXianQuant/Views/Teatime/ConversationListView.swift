import SwiftUI

struct ConversationListView: View {
    var viewModel: TeatimeViewModel

    var body: some View {
        if viewModel.conversations.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "message")
                    .font(.system(size: 40))
                    .foregroundColor(.appTextHint)
                    .padding(.top, 40)
                Text("暂无会话")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                Text("添加好友后开始聊天")
                    .font(.caption)
                    .foregroundColor(.appTextHint)
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.conversations) { conversation in
                        NavigationLink(destination: ChatView(conversationId: conversation.id, viewModel: viewModel)) {
                            ConversationRow(conversation: conversation)
                        }
                        .buttonStyle(.plain)

                        if conversation.id != viewModel.conversations.last?.id {
                            Divider()
                                .foregroundColor(.appDivider)
                                .padding(.leading, 60)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ConversationRow: View {
    let conversation: ChatConversation

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            Image(systemName: conversation.friendAvatar)
                .font(.title3)
                .foregroundColor(.appPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.appPrimaryLight))
                .overlay(alignment: .topTrailing) {
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.appStockUp))
                            .offset(x: 6, y: -6)
                    }
                }

            // Name and last message
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.friendName)
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)

                    if conversation.isVip {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.vipGold)
                    }

                    Spacer()

                    Text(conversation.lastMessageTime)
                        .font(.caption2)
                        .foregroundColor(.appTextHint)
                }

                Text(conversation.lastMessage)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        ConversationListView(viewModel: TeatimeViewModel())
    }
}
