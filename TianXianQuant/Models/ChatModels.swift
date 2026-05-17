import Foundation

// MARK: - Chat Models

struct ChatConversation: Codable, Identifiable {
    let id: String
    let friendId: String
    let friendName: String
    let friendAvatar: String
    let isVip: Bool
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let timestamp: String
    let isFromMe: Bool
    let isRead: Bool

    var idValue: String { id } // For Identifiable
}

struct Friend: Codable, Identifiable {
    let id: String
    let name: String
    let avatar: String
    let isVip: Bool
    let signature: String
}

struct FriendRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userAvatar: String
    let isVip: Bool
    let verifyMessage: String
    let requestTime: String
    var status: String = "pending"
}

// MARK: - VIP Models

struct VipPlan: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let duration: String
    let features: [String]
}
