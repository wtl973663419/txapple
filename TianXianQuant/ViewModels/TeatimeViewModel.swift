import SwiftUI
import Observation

@Observable
final class TeatimeViewModel {
    var friends: [Friend] = []
    var friendRequests: [FriendRequest] = []
    var filteredFriends: [Friend] = []
    var conversations: [ChatConversation] = []
    var messages: [String: [ChatMessage]] = [:]
    var isLoading: Bool = false

    func loadMockData() {
        isLoading = true

        // 5 friends
        friends = [
            Friend(id: "f1", name: "量化猎手", avatar: "person.circle.fill", isVip: true, signature: "量化交易，数据为王"),
            Friend(id: "f2", name: "价值投资者", avatar: "person.circle.fill", isVip: true, signature: "长期持有优质资产"),
            Friend(id: "f3", name: "短线高手", avatar: "person.circle.fill", isVip: false, signature: "快进快出，知行合一"),
            Friend(id: "f4", name: "算法大师", avatar: "person.circle.fill", isVip: true, signature: "用代码解读市场"),
            Friend(id: "f5", name: "盘手日记", avatar: "person.circle.fill", isVip: false, signature: "记录每天的操盘心得")
        ]

        // 3 friend requests
        friendRequests = [
            FriendRequest(
                id: "r1",
                userId: "ru1",
                userName: "股市小虾米",
                userAvatar: "person.circle.fill",
                isVip: false,
                verifyMessage: "看了你的帖子收益良多，想加个好友交流",
                requestTime: "1小时前",
                status: "pending"
            ),
            FriendRequest(
                id: "r2",
                userId: "ru2",
                userName: "趋势为王",
                userAvatar: "person.circle.fill",
                isVip: true,
                verifyMessage: "同是量化交易爱好者，一起探讨策略",
                requestTime: "3小时前",
                status: "pending"
            ),
            FriendRequest(
                id: "r3",
                userId: "ru3",
                userName: "Python股民",
                userAvatar: "person.circle.fill",
                isVip: false,
                verifyMessage: "想请教一下均线策略的代码问题",
                requestTime: "6小时前",
                status: "pending"
            )
        ]

        // 3 conversations
        conversations = [
            ChatConversation(
                id: "conv1",
                friendId: "f1",
                friendName: "量化猎手",
                friendAvatar: "person.circle.fill",
                isVip: true,
                lastMessage: "那个策略的回测结果我发你了，夏普1.8还不错",
                lastMessageTime: "10:32",
                unreadCount: 3
            ),
            ChatConversation(
                id: "conv2",
                friendId: "f2",
                friendName: "价值投资者",
                friendAvatar: "person.circle.fill",
                isVip: true,
                lastMessage: "茅台一季报出来了，晚上聊聊",
                lastMessageTime: "昨天",
                unreadCount: 0
            ),
            ChatConversation(
                id: "conv3",
                friendId: "f4",
                friendName: "算法大师",
                friendAvatar: "person.circle.fill",
                isVip: true,
                lastMessage: "好的，谢谢指点！",
                lastMessageTime: "周一",
                unreadCount: 1
            )
        ]

        // Messages for each conversation
        messages["conv1"] = [
            ChatMessage(id: "m1_1", conversationId: "conv1", senderId: "f1", content: "最近在看一个新的量化因子，基于北向资金流向的，感觉效果不错", timestamp: "10:15", isFromMe: false, isRead: true),
            ChatMessage(id: "m1_2", conversationId: "conv1", senderId: "me", content: "能具体说说吗？我最近也在研究北向数据", timestamp: "10:18", isFromMe: true, isRead: true),
            ChatMessage(id: "m1_3", conversationId: "conv1", senderId: "f1", content: "主要是把北向的净流入数据做EMA平滑，然后用拐点作为信号", timestamp: "10:22", isFromMe: false, isRead: true),
            ChatMessage(id: "m1_4", conversationId: "conv1", senderId: "me", content: "有回测数据吗？胜率怎么样？", timestamp: "10:25", isFromMe: true, isRead: true),
            ChatMessage(id: "m1_5", conversationId: "conv1", senderId: "f1", content: "那个策略的回测结果我发你了，夏普1.8还不错", timestamp: "10:32", isFromMe: false, isRead: false)
        ]

        messages["conv2"] = [
            ChatMessage(id: "m2_1", conversationId: "conv2", senderId: "f2", content: "看了你的白酒分析，观点很相似", timestamp: "昨天 15:20", isFromMe: false, isRead: true),
            ChatMessage(id: "m2_2", conversationId: "conv2", senderId: "me", content: "哈哈，英雄所见略同。茅台你现在什么仓位？", timestamp: "昨天 15:25", isFromMe: true, isRead: true),
            ChatMessage(id: "m2_3", conversationId: "conv2", senderId: "f2", content: "茅台一季报出来了，晚上聊聊", timestamp: "昨天 18:30", isFromMe: false, isRead: true)
        ]

        messages["conv3"] = [
            ChatMessage(id: "m3_1", conversationId: "conv3", senderId: "me", content: "大佬，你那个均线策略的止损逻辑是怎么设计的？", timestamp: "周一 09:15", isFromMe: true, isRead: true),
            ChatMessage(id: "m3_2", conversationId: "conv3", senderId: "f4", content: "用的是ATR动态止损，2倍ATR作为初始止损，然后根据趋势移动", timestamp: "周一 09:30", isFromMe: false, isRead: true),
            ChatMessage(id: "m3_3", conversationId: "conv3", senderId: "me", content: "ATR周期选的多长？", timestamp: "周一 09:35", isFromMe: true, isRead: true),
            ChatMessage(id: "m3_4", conversationId: "conv3", senderId: "f4", content: "我用的是14日ATR，比较经典的参数。如果想更敏感可以用10日", timestamp: "周一 09:40", isFromMe: false, isRead: true),
            ChatMessage(id: "m3_5", conversationId: "conv3", senderId: "me", content: "好的，谢谢指点！", timestamp: "周一 09:45", isFromMe: true, isRead: true)
        ]

        filteredFriends = friends
        isLoading = false
    }

    func searchFriends(_ keyword: String) {
        if keyword.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { $0.name.contains(keyword) || $0.signature.contains(keyword) }
        }
    }

    func acceptFriendRequest(id: String) {
        guard let index = friendRequests.firstIndex(where: { $0.id == id }) else { return }
        friendRequests[index].status = "accepted"

        let request = friendRequests[index]
        let newFriend = Friend(
            id: "f_new_\(UUID().uuidString.prefix(8))",
            name: request.userName,
            avatar: request.userAvatar,
            isVip: request.isVip,
            signature: "新朋友"
        )
        friends.append(newFriend)
        filteredFriends = friends
    }

    func rejectFriendRequest(id: String) {
        guard let index = friendRequests.firstIndex(where: { $0.id == id }) else { return }
        friendRequests[index].status = "rejected"
    }

    func addFriend(name: String) {
        let newFriend = Friend(
            id: "f_\(UUID().uuidString.prefix(8))",
            name: name,
            avatar: "person.circle.fill",
            isVip: false,
            signature: "新朋友"
        )
        friends.append(newFriend)
        filteredFriends = friends
    }

    func sendMessage(conversationId: String, content: String) {
        let newMessage = ChatMessage(
            id: "msg_\(UUID().uuidString.prefix(8))",
            conversationId: conversationId,
            senderId: "me",
            content: content,
            timestamp: formatCurrentTime(),
            isFromMe: true,
            isRead: false
        )
        if messages[conversationId] != nil {
            messages[conversationId]?.append(newMessage)
        } else {
            messages[conversationId] = [newMessage]
        }

        // Update conversation's last message
        if let convIndex = conversations.firstIndex(where: { $0.id == conversationId }) {
            let updatedConv = ChatConversation(
                id: conversations[convIndex].id,
                friendId: conversations[convIndex].friendId,
                friendName: conversations[convIndex].friendName,
                friendAvatar: conversations[convIndex].friendAvatar,
                isVip: conversations[convIndex].isVip,
                lastMessage: content,
                lastMessageTime: formatCurrentTime(),
                unreadCount: conversations[convIndex].unreadCount
            )
            conversations[convIndex] = updatedConv
        }
    }

    func loadMessages(conversationId: String) -> [ChatMessage] {
        return messages[conversationId] ?? []
    }

    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
