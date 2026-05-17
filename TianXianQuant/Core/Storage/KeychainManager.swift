import Foundation
import Security

/// Secure credential storage using iOS Keychain — fixes bug #3 (plaintext password)
final class KeychainManager: @unchecked Sendable {
    static let shared = KeychainManager()

    private let service = "com.tianxian.quant.ios"

    func store(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Convenience

    var authToken: String? {
        get { retrieve(key: "auth_token") }
        set {
            if let newValue { store(key: "auth_token", value: newValue) }
            else { delete(key: "auth_token") }
        }
    }

    var password: String? {
        get { retrieve(key: "password") }
        set {
            if let newValue { store(key: "password", value: newValue) }
            else { delete(key: "password") }
        }
    }

    var username: String? {
        get { retrieve(key: "username") }
        set {
            if let newValue { store(key: "username", value: newValue) }
            else { delete(key: "username") }
        }
    }
}
