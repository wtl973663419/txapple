import Foundation

// MARK: - Character WuXing Data Model

struct CharWuxingEntry: Codable {
    let element: String
    let strokes: Int
}

// MARK: - Character WuXing Loader (Singleton)

/// Loads and provides access to the Chinese character five-element (五行) database.
/// Data sourced from char_wuxing.json (2400+ entries).
final class CharWuxingLoader {

    // MARK: - Singleton

    static let shared = CharWuxingLoader()

    // MARK: - Properties

    private var entries: [String: CharWuxingEntry] = [:]
    private var loaded = false
    private let lock = NSLock()

    // MARK: - Init

    private init() {}

    // MARK: - Loading

    /// Lazy-load the character WuXing database on first access.
    private func ensureLoaded() {
        lock.lock()
        defer { lock.unlock() }

        guard !loaded else { return }
        loaded = true

        guard let url = Bundle.main.url(forResource: "char_wuxing", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("[CharWuxingLoader] ERROR: Failed to load char_wuxing.json from bundle")
            return
        }

        do {
            let raw = try JSONDecoder().decode([String: CharWuxingEntry].self, from: data)
            entries = raw
        } catch {
            print("[CharWuxingLoader] ERROR: Failed to decode char_wuxing.json: \(error)")
        }
    }

    // MARK: - Public API

    /// Get the five-element attribute for a single Chinese character.
    /// Returns nil if the character is not in the database.
    func getWuxing(char: String) -> String? {
        ensureLoaded()
        return entries[char]?.element
    }

    /// Get the stroke count for a single Chinese character.
    func getStrokes(char: String) -> Int {
        ensureLoaded()
        return entries[char]?.strokes ?? 0
    }

    /// Get all characters in the database.
    func getAllChars() -> [String] {
        ensureLoaded()
        return Array(entries.keys)
    }

    /// Convert a five-element name to its corresponding emoji.
    func elementEmoji(element: String) -> String {
        switch element {
        case "木": return "\u{1F332}"  // 🌲
        case "火": return "\u{1F525}"  // 🔥
        case "土": return "\u{1F30D}"  // 🌍
        case "金": return "\u{26CF}\u{FE0F}"  // ⛏️
        case "水": return "\u{1F4A7}"  // 💧
        default:   return "❓"
        }
    }

    /// Get the count of characters in the database.
    var count: Int {
        ensureLoaded()
        return entries.count
    }
}
