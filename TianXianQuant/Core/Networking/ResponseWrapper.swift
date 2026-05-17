import Foundation

/// Generic wrapper matching backend JSON: { "success": bool, "data": T, "error": string }
struct ResponseWrapper<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

/// For endpoints returning arrays: { "success": true, "data": [...] }
typealias ArrayResponse<T: Codable> = ResponseWrapper<[T]>

/// For endpoints returning a single object
typealias SingleResponse<T: Codable> = ResponseWrapper<T>

/// For auth responses: { "success": true, "token": "...", "user": {...} }
struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let user: UserResponse?
    let error: String?

    struct UserResponse: Codable {
        let id: String?
        let username: String?
        let avatarIndex: Int?
        let bio: String?
        let createdAt: String?
        let lastLogin: String?
        let vip: VipStatus?

        enum CodingKeys: String, CodingKey {
            case id, username, bio
            case avatarIndex = "avatar_index"
            case createdAt = "created_at"
            case lastLogin = "last_login"
            case vip
        }
    }

    struct VipStatus: Codable {
        let enabled: Bool?
    }
}

/// For verify token responses
struct VerifyTokenResponse: Codable {
    let success: Bool
    let vip: VipStatus?

    struct VipStatus: Codable {
        let enabled: Bool?
    }
}

/// For version check
struct VersionResponse: Codable {
    let success: Bool
    let data: VersionInfo?

    struct VersionInfo: Codable {
        let versionCode: Int?
        let versionName: String?
        let updateLog: String?
        let forceUpdate: Bool?
        let apkUrl: String?

        enum CodingKeys: String, CodingKey {
            case versionCode, versionName, updateLog, forceUpdate
            case apkUrl = "apkUrl"
        }
    }
}

/// For realtime quotes: { "success": true, "data": [{ "code": "...", "price": 0.0, "name": "..." }] }
struct RealtimeQuote: Codable {
    let code: String?
    let price: Double?
    let name: String?
}
