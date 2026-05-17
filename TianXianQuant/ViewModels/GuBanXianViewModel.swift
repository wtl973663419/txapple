import Foundation
import Observation

// MARK: - GuBanXian ViewModel

@Observable
final class GuBanXianViewModel {

    // MARK: - Properties

    var messages: [ChatMessage] = []
    var isThinking = false
    var isVip: Bool = false

    private let router = GuBanXianKeywordRouter()

    // MARK: - Init

    init(isVip: Bool = false) {
        self.isVip = isVip
        addGreeting()
    }

    // MARK: - Greeting

    private func addGreeting() {
        let greeting = ChatMessage(
            id: UUID().uuidString,
            conversationId: "gubanxian_bot",
            senderId: "gubanxian_bot",
            content: "阿弥陀佛，施主有缘相见。老衲俗名股半仙，精通八字算命、股票预测、姻缘事业，无所不算。施主有何疑问，尽管道来。",
            timestamp: isoNow(),
            isFromMe: false,
            isRead: true
        )
        messages.append(greeting)
    }

    // MARK: - Message Processing

    func processMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            conversationId: "gubanxian_bot",
            senderId: "user",
            content: text,
            timestamp: isoNow(),
            isFromMe: true,
            isRead: true
        )
        messages.append(userMessage)

        // Start thinking
        isThinking = true

        // Route message to appropriate calculator based on keywords
        let responseText = routeToBot(text: text)

        // Simulate bot thinking delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + Double.random(in: 0...0.5)) { [weak self] in
            guard let self = self else { return }

            let botMessage = ChatMessage(
                id: UUID().uuidString,
                conversationId: "gubanxian_bot",
                senderId: "gubanxian_bot",
                content: responseText,
                timestamp: self.isoNow(),
                isFromMe: false,
                isRead: true
            )
            self.messages.append(botMessage)
            self.isThinking = false
        }
    }

    // MARK: - Routing

    private func routeToBot(text: String) -> String {
        return router.route(text: text, isVip: isVip)
    }

    // MARK: - Helpers

    private func isoNow() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }
}
