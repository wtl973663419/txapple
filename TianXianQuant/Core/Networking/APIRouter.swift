import Foundation

/// All API endpoint definitions — every endpoint defined once, built from APIConfig.baseURL (fixes bug #2)
enum APIRouter {
    // Market data (public, API key only)
    case hotSectors
    case dragonTiger
    case topGainers
    case topLosers
    case search(keyword: String)
    case stockDetail(code: String)
    case marketOverview
    case limitUpStocks
    case sectorStrength
    case realtimeQuotes(codes: String)
    case version

    // Auth (public, no token)
    case auth(username: String, password: String)
    case health

    // Authenticated endpoints (require Bearer token) — fixes bug #5
    case verifyToken
    case profile(username: String, avatarIndex: Int, bio: String)
    case changePassword(username: String, oldPassword: String, newPassword: String)

    // MARK: - URL Construction

    var path: String {
        switch self {
        case .hotSectors: return "/hot_sectors"
        case .dragonTiger: return "/dragon_tiger"
        case .topGainers: return "/top_gainers"
        case .topLosers: return "/top_losers"
        case .search: return "/search"
        case .stockDetail(let code): return "/stock/\(code)"
        case .marketOverview: return "/market_overview"
        case .limitUpStocks: return "/limit_up_stocks"
        case .sectorStrength: return "/sector_strength"
        case .realtimeQuotes: return "/realtime_quotes"
        case .version: return "/version"
        case .auth: return "/auth"
        case .health: return "/health"
        case .verifyToken: return "/verify_token"
        case .profile: return "/profile"
        case .changePassword: return "/change_password"
        }
    }

    var url: URL? {
        var components = URLComponents(string: APIConfig.baseURL + path)

        switch self {
        case .search(let keyword):
            components?.queryItems = [URLQueryItem(name: "keyword", value: keyword)]
        case .realtimeQuotes(let codes):
            components?.queryItems = [URLQueryItem(name: "codes", value: codes)]
        case .version:
            components?.queryItems = [URLQueryItem(name: "versionCode", value: String(APIConfig.appVersionCode))]
        default:
            break
        }

        return components?.url
    }

    var httpMethod: String {
        switch self {
        case .auth, .profile, .changePassword:
            return "POST"
        case .profile:
            return "PUT"
        default:
            return "GET"
        }
    }

    var httpBody: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .auth(let username, let password):
            return try? encoder.encode(["username": username, "password": password])
        case .profile(let username, let avatarIndex, let bio):
            let payload: [String: Any] = [
                "username": username,
                "avatar_index": avatarIndex,
                "bio": bio
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
        case .changePassword(let username, let oldPwd, let newPwd):
            return try? encoder.encode([
                "username": username,
                "old_password": oldPwd,
                "new_password": newPwd
            ])
        default:
            return nil
        }
    }

    /// Routes that require Bearer token (fixes bug #5)
    var requiresAuth: Bool {
        switch self {
        case .verifyToken, .profile, .changePassword:
            return true
        default:
            return false
        }
    }
}
