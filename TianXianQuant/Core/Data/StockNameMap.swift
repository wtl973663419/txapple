import Foundation

// MARK: - Stock Name Map (Singleton)

/// Maps stock codes to names and vice versa, supporting fuzzy search with pinyin.
/// Data sourced from stock_list.json (5000+ entries).
final class StockNameMap {

    // MARK: - Singleton

    static let shared = StockNameMap()

    // MARK: - Properties

    /// code -> name
    private(set) var nameMap: [String: String] = [:]

    /// name -> code (lowercased key for case-insensitive lookup)
    private(set) var reverseMap: [String: String] = [:]

    private var loaded = false
    private let lock = NSLock()

    // MARK: - Pinyin cache

    /// Stock name -> pinyin first letters (e.g. "平安银行" -> "payx")
    private var pinyinCache: [String: String] = [:]

    // MARK: - Init

    private init() {}

    // MARK: - Loading

    private func ensureLoaded() {
        lock.lock()
        defer { lock.unlock() }

        guard !loaded else { return }
        loaded = true

        guard let url = Bundle.main.url(forResource: "stock_list", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("[StockNameMap] ERROR: Failed to load stock_list.json from bundle")
            return
        }

        do {
            let list = try JSONDecoder().decode([StockListEntry].self, from: data)
            for entry in list {
                let cleanedName = entry.name.trimmingCharacters(in: .whitespaces)
                nameMap[entry.code] = cleanedName
                reverseMap[cleanedName.lowercased()] = entry.code
                // Precompute pinyin
                pinyinCache[cleanedName] = cleanedName.pinyinFirstLetters()
            }
        } catch {
            print("[StockNameMap] ERROR: Failed to decode stock_list.json: \(error)")
        }
    }

    // MARK: - Public API

    /// Get stock name by code, or return the default value.
    func getNameOrDefault(code: String, default defaultValue: String = "") -> String {
        ensureLoaded()
        return nameMap[code] ?? defaultValue
    }

    /// Get stock code by exact name (case-insensitive).
    func getCode(name: String) -> String? {
        ensureLoaded()
        return reverseMap[name.lowercased()]
    }

    /// Fuzzy match stock by input string. Supports:
    /// - Exact code match (e.g. "000001")
    /// - Substring code match (e.g. "0000")
    /// - Exact name match (e.g. "平安银行")
    /// - Substring name match (e.g. "平安")
    /// - Pinyin first-letter match (e.g. "payx" for 平安银行)
    ///
    /// Returns up to 20 matching (code, name) pairs.
    func fuzzyMatchCode(input: String) -> [(code: String, name: String)] {
        ensureLoaded()

        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }

        var results: [(code: String, name: String)] = []
        var seen = Set<String>()

        // 1. Exact code match (highest priority)
        if let name = nameMap[trimmed] {
            results.append((trimmed, name))
            seen.insert(trimmed)
        }

        // 2. Exact name match (case-insensitive)
        for (code, name) in nameMap where !seen.contains(code) {
            if name == trimmed {
                results.append((code, name))
                seen.insert(code)
                break
            }
        }

        // 3. Code starts with input
        for (code, name) in nameMap where !seen.contains(code) {
            if code.hasPrefix(trimmed) {
                results.append((code, name))
                seen.insert(code)
            }
        }

        // 4. Name contains input
        for (code, name) in nameMap where !seen.contains(code) {
            if name.contains(trimmed) {
                results.append((code, name))
                seen.insert(code)
            }
        }

        // 5. Pinyin first-letter match
        let inputLower = trimmed.lowercased()
        for (code, name) in nameMap where !seen.contains(code) {
            let py = pinyinCache[name] ?? name.pinyinFirstLetters()
            if py.contains(inputLower) || py.hasPrefix(inputLower) {
                results.append((code, name))
                seen.insert(code)
            }
        }

        return Array(results.prefix(20))
    }

    /// Check if a string matches a known stock name exactly.
    func isKnownStock(name: String) -> Bool {
        ensureLoaded()
        return reverseMap[name.lowercased()] != nil
    }
}

// MARK: - Internal JSON Model

private struct StockListEntry: Codable {
    let code: String
    let name: String
}

// MARK: - Pinyin Extension

extension String {

    /// Convert Chinese string to pinyin first letters (e.g. "平安银行" -> "payx").
    func pinyinFirstLetters() -> String {
        let mutable = NSMutableString(string: self)
        CFStringTransform(mutable, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutable, nil, kCFStringTransformStripDiacritics, false)
        // Split by spaces, take first letter of each word
        let words = (mutable as String).components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return words.map { String($0.prefix(1)) }.joined().lowercased()
    }
}
