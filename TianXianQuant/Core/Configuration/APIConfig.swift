import Foundation

/// SINGLE SOURCE OF TRUTH for all API configuration — fixes bugs #1, #2, #6
/// In production, load these from a .xcconfig file excluded from git.
enum APIConfig {
    static let baseURL = "https://bec3168.r29.cpolar.top/api"
    static let apiKey = "txquant2025secret"

    static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2.0"
    }()

    static let appVersionCode: Int = {
        Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "120") ?? 120
    }()

    static let connectTimeout: TimeInterval = 8
    static let readTimeout: TimeInterval = 10
    static let cacheTTL: TimeInterval = 60
}
