import Foundation

/// Persists chat message history as JSON files in the app's Documents directory.
/// One file per conversation, keyed by conversationId.
enum ChatStorage {
    private static let fileManager = FileManager.default
    private static let directoryName = "ChatHistory"

    // MARK: - Directory

    private static var chatDirectory: URL? {
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = documents.appendingPathComponent(directoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static func fileURL(for conversationId: String) -> URL? {
        chatDirectory?.appendingPathComponent("\(conversationId).json")
    }

    // MARK: - CRUD

    /// Save messages for a conversation. Overwrites any existing file.
    static func saveMessages(conversationId: String, messages: [ChatMessage]) {
        guard let fileURL = fileURL(for: conversationId) else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(messages)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Disk write failure — non-critical for chat persistence
        }
    }

    /// Load all messages for a given conversation. Returns an empty array if none exist.
    static func loadMessages(conversationId: String) -> [ChatMessage] {
        guard let fileURL = fileURL(for: conversationId),
              fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
            return messages
        } catch {
            return []
        }
    }

    /// Delete all stored chat history files.
    static func clearAll() {
        guard let directory = chatDirectory else { return }
        try? fileManager.removeItem(at: directory)
        // Recreate empty directory
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// Delete messages for a specific conversation.
    static func deleteConversation(conversationId: String) {
        guard let fileURL = fileURL(for: conversationId) else { return }
        try? fileManager.removeItem(at: fileURL)
    }

    /// List all conversation IDs that have saved messages.
    static func savedConversationIds() -> [String] {
        guard let directory = chatDirectory else { return [] }
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        return contents.compactMap { url in
            guard url.pathExtension == "json" else { return nil }
            return url.deletingPathExtension().lastPathComponent
        }
    }
}
