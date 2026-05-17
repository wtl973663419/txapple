import Foundation

/// URLSession-based API client with centralized header injection and cache.
/// Replaces Android's OkHttp BackendApi.kt.
final class APIClient: @unchecked Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder = JSONDecoder()
    private var cache: [String: (timestamp: Date, data: Any)] = [:]
    private let cacheQueue = DispatchQueue(label: "com.tianxian.quant.cache")

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.connectTimeout
        config.timeoutIntervalForResource = APIConfig.readTimeout
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-API-Key": APIConfig.apiKey
        ]
        session = URLSession(configuration: config)
    }

    // MARK: - Generic Request

    func request<T: Codable>(_ router: APIRouter) async throws -> T {
        // Check cache for GET requests
        if router.httpMethod == "GET", let cached: T = getCached(router.path) {
            return cached
        }

        guard let url = router.url else {
            throw NetworkError.invalidURL(router.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = router.httpMethod
        request.httpBody = router.httpBody

        // Add Bearer token for authenticated routes (fixes bug #5)
        if router.requiresAuth {
            if let token = KeychainManager.shared.retrieve(key: "auth_token") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkUnreachable(URLError(.badServerResponse))
            }

            if httpResponse.statusCode == 401 {
                throw NetworkError.authFailed("Token invalid or expired")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NetworkError.serverError(httpResponse.statusCode, msg)
            }

            let decoded: T = try decoder.decode(T.self, from: data)

            // Cache successful GET responses
            if router.httpMethod == "GET" {
                setCache(router.path, value: decoded)
            }

            return decoded
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.networkUnreachable(error)
        }
    }

    /// Raw data request (for endpoints returning unstructured JSON)
    func requestRaw(_ router: APIRouter) async throws -> Data {
        guard let url = router.url else {
            throw NetworkError.invalidURL(router.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = router.httpMethod
        request.httpBody = router.httpBody

        if router.requiresAuth {
            if let token = KeychainManager.shared.retrieve(key: "auth_token") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkUnreachable(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode, "HTTP \(httpResponse.statusCode)")
        }
        return data
    }

    // MARK: - Cache

    private func getCached<T>(_ key: String) -> T? {
        cacheQueue.sync {
            guard let entry = cache[key],
                  Date().timeIntervalSince(entry.timestamp) < APIConfig.cacheTTL,
                  let value = entry.data as? T else {
                cache[key] = nil
                return nil
            }
            return value
        }
    }

    private func setCache(_ key: String, value: Any) {
        cacheQueue.sync {
            cache[key] = (timestamp: Date(), data: value)
        }
    }

    func clearCache() {
        cacheQueue.sync { cache.removeAll() }
    }
}
