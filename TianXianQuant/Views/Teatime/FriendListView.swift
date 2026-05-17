import SwiftUI

struct FriendListView: View {
    var viewModel: TeatimeViewModel

    @State private var searchText: String = ""
    @State private var showAddFriend = false
    @State private var newFriendName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Friend requests section
            if !viewModel.friendRequests.filter({ $0.status == "pending" }).isEmpty {
                VStack(spacing: 0) {
                    HStack {
                        Text("新的好友申请")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)
                        Spacer()
                        if viewModel.friendRequests.filter({ $0.status == "pending" }).count > 0 {
                            Text("\(viewModel.friendRequests.filter { $0.status == "pending" }.count)条")
                                .font(.caption)
                                .foregroundColor(.appStockUp)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color.appStockUp.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    FriendRequestView(viewModel: viewModel)
                        .padding(.horizontal, 16)

                    Divider()
                        .foregroundColor(.appDivider)
                        .padding(.top, 8)
                }
            }

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.callout)
                    .foregroundColor(.appTextHint)

                TextField("搜索好友", text: $searchText)
                    .font(.subheadline)
                    .onChange(of: searchText) { _, newValue in
                        viewModel.searchFriends(newValue)
                    }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appBackgroundInput)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Friend list
            if viewModel.filteredFriends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                        .padding(.top, 40)
                    Text(searchText.isEmpty ? "暂无好友" : "没有找到相关好友")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredFriends) { friend in
                            NavigationLink(destination: ChatView(conversationId: findOrCreateConversation(for: friend).id, viewModel: viewModel)) {
                                FriendRow(friend: friend)
                            }
                            .buttonStyle(.plain)

                            if friend.id != viewModel.filteredFriends.last?.id {
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddFriend = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.subheadline)
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .alert("添加好友", isPresented: $showAddFriend) {
            TextField("好友名称", text: $newFriendName)
            Button("取消", role: .cancel) { newFriendName = "" }
            Button("添加") {
                let trimmed = newFriendName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    viewModel.addFriend(name: trimmed)
                    newFriendName = ""
                }
            }
        } message: {
            Text("输入好友名称添加好友")
        }
    }

    private func findOrCreateConversation(for friend: Friend) -> ChatConversation {
        if let existing = viewModel.conversations.first(where: { $0.friendId == friend.id }) {
            return existing
        }
        let newConv = ChatConversation(
            id: "conv_\(friend.id)",
            friendId: friend.id,
            friendName: friend.name,
            friendAvatar: friend.avatar,
            isVip: friend.isVip,
            lastMessage: "开始聊天吧",
            lastMessageTime: "刚刚",
            unreadCount: 0
        )
        viewModel.conversations.append(newConv)
        return newConv
    }
}

#Preview {
    NavigationStack {
        FriendListView(viewModel: TeatimeViewModel())
            .task {
                let vm = TeatimeViewModel()
                vm.loadMockData()
            }
    }
}
