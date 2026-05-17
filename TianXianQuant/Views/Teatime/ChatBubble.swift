import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isFromMe {
                // Other's avatar (left side)
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.appPrimaryLight))
            } else {
                Spacer()
            }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(message.isFromMe ? .white : .appTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isFromMe ? Color.appPrimary : Color.white)
                            .shadow(color: .black.opacity(message.isFromMe ? 0 : 0.04), radius: 1, y: 1)
                    )
                    .fixedSize(horizontal: false, vertical: true)

                Text(message.timestamp)
                    .font(.caption2)
                    .foregroundColor(.appTextHint)
            }
            .frame(maxWidth: 280, alignment: message.isFromMe ? .trailing : .leading)

            if !message.isFromMe {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubble(message: ChatMessage(
            id: "1",
            conversationId: "c1",
            senderId: "other",
            content: "最近在看一个新的量化因子，基于北向资金流向的，感觉效果不错",
            timestamp: "10:15",
            isFromMe: false,
            isRead: true
        ))
        ChatBubble(message: ChatMessage(
            id: "2",
            conversationId: "c1",
            senderId: "me",
            content: "能具体说说吗？",
            timestamp: "10:18",
            isFromMe: true,
            isRead: true
        ))
        ChatBubble(message: ChatMessage(
            id: "3",
            conversationId: "c1",
            senderId: "other",
            content: "主要是把北向的净流入数据做EMA平滑，然后用拐点作为信号。回测效果还不错。",
            timestamp: "10:22",
            isFromMe: false,
            isRead: true
        ))
    }
    .padding()
    .background(Color.appBackground)
}
