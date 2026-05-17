import SwiftUI
import Observation

/// Network response model for profile updates
struct ProfileResponse: Codable {
    let success: Bool
    let message: String?
}

/// Network response model for password changes
struct ChangePasswordResponse: Codable {
    let success: Bool
    let message: String?
}

enum LoginState: Equatable {
    case idle
    case loading
    case success
    case error(String)

    static func == (lhs: LoginState, rhs: LoginState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let m1), .error(let m2)):
            return m1 == m2
        default:
            return false
        }
    }
}

@Observable
final class ProfileViewModel {
    var loginState: LoginState = .idle
    var errorMessage: String = ""

    /// Update user profile (username, avatar index, bio)
    /// Calls APIRouter.profile with Bearer token automatically injected by APIClient
    func updateProfile(username: String, avatarIndex: Int, bio: String) async {
        loginState = .loading
        do {
            let response: ProfileResponse = try await APIClient.shared.request(
                .profile(username: username, avatarIndex: avatarIndex, bio: bio)
            )
            if response.success {
                // Persist updated values
                UserDefaultsManager.shared.avatarIndex = avatarIndex
                UserDefaultsManager.shared.bio = bio
                KeychainManager.shared.username = username
                loginState = .success
            } else {
                loginState = .error(response.message ?? "更新失败")
            }
        } catch let error as NetworkError {
            loginState = .error(error.localizedDescription)
        } catch {
            loginState = .error("网络请求失败: \(error.localizedDescription)")
        }
    }

    /// Change password with Bearer token (fixes bug #5)
    /// Calls APIRouter.changePassword which requires auth — token added by APIClient
    func changePassword(username: String, oldPassword: String, newPassword: String) async {
        loginState = .loading
        do {
            let response: ChangePasswordResponse = try await APIClient.shared.request(
                .changePassword(username: username, oldPassword: oldPassword, newPassword: newPassword)
            )
            if response.success {
                // Update stored password in Keychain
                KeychainManager.shared.password = newPassword
                loginState = .success
            } else {
                loginState = .error(response.message ?? "密码修改失败")
            }
        } catch let error as NetworkError {
            loginState = .error(error.localizedDescription)
        } catch {
            loginState = .error("网络请求失败: \(error.localizedDescription)")
        }
    }

    func resetState() {
        loginState = .idle
        errorMessage = ""
    }
}
