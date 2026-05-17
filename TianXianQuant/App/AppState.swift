import SwiftUI
import Observation

/// Global application state, observed by all views
@Observable
final class AppState {
    var isAuthenticated = false
    var token: String?
    var userId: String?
    var username: String?
    var avatarIndex = 0
    var bio = ""
    var isVip = false
    var isLoading = true

    // Prevent multiple auth check calls
    private var authCheckPerformed = false

    init() {
        // Load cached state immediately
        token = KeychainManager.shared.authToken
        username = KeychainManager.shared.username
        userId = UserDefaultsManager.shared.userId
        avatarIndex = UserDefaultsManager.shared.avatarIndex
        bio = UserDefaultsManager.shared.bio
        isVip = UserDefaultsManager.shared.isVip
    }

    /// Verify stored token validity (runs on app launch)
    func verifyAuth() async {
        guard !authCheckPerformed else { return }
        authCheckPerformed = true

        guard let token = KeychainManager.shared.authToken, !token.isEmpty else {
            isAuthenticated = false
            isLoading = false
            return
        }

        do {
            let response: VerifyTokenResponse = try await APIClient.shared.request(.verifyToken)
            if response.success {
                isAuthenticated = true
                isVip = response.vip?.enabled ?? false
                UserDefaultsManager.shared.isVip = isVip
            } else {
                // Token invalid — try auto re-login
                let reloginSuccess = await autoRelogin()
                isAuthenticated = reloginSuccess
            }
        } catch let error as NetworkError {
            // NEVER auto-pass auth on network error (fixes bug #4)
            // Only pass if we have stored credentials to attempt re-login
            if await autoRelogin() {
                isAuthenticated = true
            } else {
                isAuthenticated = !error.isAuthFailure
            }
        } catch {
            // Try re-login as last resort
            isAuthenticated = await autoRelogin()
        }
        isLoading = false
    }

    /// Attempt re-login with stored credentials from Keychain
    private func autoRelogin() async -> Bool {
        guard let username = KeychainManager.shared.username,
              let password = KeychainManager.shared.password else {
            return false
        }

        do {
            let response: AuthResponse = try await APIClient.shared.request(
                .auth(username: username, password: password)
            )
            if response.success, let newToken = response.token {
                KeychainManager.shared.authToken = newToken
                KeychainManager.shared.username = username

                if let user = response.user {
                    UserDefaultsManager.shared.userId = user.id
                    UserDefaultsManager.shared.avatarIndex = user.avatarIndex ?? 0
                    UserDefaultsManager.shared.bio = user.bio ?? ""
                    UserDefaultsManager.shared.isVip = user.vip?.enabled ?? false
                    self.username = user.username
                    self.userId = user.id
                    self.avatarIndex = user.avatarIndex ?? 0
                    self.bio = user.bio ?? ""
                    self.isVip = user.vip?.enabled ?? false
                }
                self.token = newToken
                return true
            }
            return false
        } catch {
            return false
        }
    }

    func login(username: String, password: String) async -> Bool {
        do {
            let response: AuthResponse = try await APIClient.shared.request(
                .auth(username: username, password: password)
            )
            if response.success, let newToken = response.token {
                KeychainManager.shared.authToken = newToken
                KeychainManager.shared.username = username
                KeychainManager.shared.password = password

                if let user = response.user {
                    UserDefaultsManager.shared.userId = user.id
                    UserDefaultsManager.shared.avatarIndex = user.avatarIndex ?? 0
                    UserDefaultsManager.shared.bio = user.bio ?? ""
                    UserDefaultsManager.shared.isVip = user.vip?.enabled ?? false
                    self.username = user.username
                    self.userId = user.id
                    self.avatarIndex = user.avatarIndex ?? 0
                    self.bio = user.bio ?? ""
                    self.isVip = user.vip?.enabled ?? false
                }
                self.token = newToken
                self.isAuthenticated = true
                return true
            }
            return false
        } catch {
            return false
        }
    }

    func logout() {
        KeychainManager.shared.authToken = nil
        KeychainManager.shared.password = nil
        UserDefaultsManager.shared.remove("user_id")
        token = nil
        userId = nil
        username = nil
        isAuthenticated = false
        isVip = false
        avatarIndex = 0
        bio = ""
    }
}
