import Foundation

/// Non-sensitive user preferences — replaces Android SharedPreferences
final class UserDefaultsManager: @unchecked Sendable {
    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults(suiteName: "com.tianxian.quant.ios.prefs")!

    // MARK: - VIP State

    var isVip: Bool {
        get { defaults.bool(forKey: "is_vip") }
        set { defaults.set(newValue, forKey: "is_vip") }
    }

    var vipExpireTime: String? {
        get { defaults.string(forKey: "vip_expire_time") }
        set { defaults.set(newValue, forKey: "vip_expire_time") }
    }

    // MARK: - User Profile

    var userId: String? {
        get { defaults.string(forKey: "user_id") }
        set { defaults.set(newValue, forKey: "user_id") }
    }

    var avatarIndex: Int {
        get { defaults.integer(forKey: "avatar_index") }
        set { defaults.set(newValue, forKey: "avatar_index") }
    }

    var bio: String {
        get { defaults.string(forKey: "bio") ?? "" }
        set { defaults.set(newValue, forKey: "bio") }
    }

    // MARK: - Update

    var skippedVersionCode: Int {
        get { defaults.integer(forKey: "skipped_version_code") }
        set { defaults.set(newValue, forKey: "skipped_version_code") }
    }

    // MARK: - Plan Storage

    var planAlertEnabled: Bool {
        get { defaults.bool(forKey: "plan_alert_enabled") }
        set { defaults.set(newValue, forKey: "plan_alert_enabled") }
    }

    var triggeredAlerts: Set<String> {
        get {
            let arr = defaults.stringArray(forKey: "triggered_alerts") ?? []
            return Set(arr)
        }
        set {
            defaults.set(Array(newValue), forKey: "triggered_alerts")
        }
    }

    func clearTriggeredAlerts() {
        defaults.set([], forKey: "triggered_alerts")
    }

    func markAlertTriggered(_ planId: String) {
        var alerts = triggeredAlerts
        alerts.insert(planId)
        triggeredAlerts = alerts
    }

    // MARK: - Generic

    func saveCodable<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    func loadCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func remove(_ key: String) {
        defaults.removeObject(forKey: key)
    }

    func clearAll() {
        let domain = "com.tianxian.quant.ios.prefs"
        defaults.removePersistentDomain(forName: domain)
    }
}
