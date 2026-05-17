import Foundation

/// Strongly-typed network errors with NO silent auth bypass (fixes bug #4)
enum NetworkError: LocalizedError {
    case invalidURL(String)
    case noData
    case decodingFailed(Error)
    case serverError(Int, String)
    case authFailed(String)
    case networkUnreachable(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "无效请求地址: \(url)"
        case .noData: return "服务器无响应"
        case .decodingFailed(let e): return "数据解析失败: \(e.localizedDescription)"
        case .serverError(let code, let msg): return "[\(code)] \(msg)"
        case .authFailed(let msg): return "认证失败: \(msg)"
        case .networkUnreachable(let e): return "网络不可达: \(e.localizedDescription)"
        case .unknown(let e): return "未知错误: \(e.localizedDescription)"
        }
    }

    /// Auth never auto-passes on network error (unlike SplashActivity.kt:162-163)
    var isAuthFailure: Bool {
        if case .authFailed = self { return true }
        if case .networkUnreachable = self { return true }
        return false
    }
}
