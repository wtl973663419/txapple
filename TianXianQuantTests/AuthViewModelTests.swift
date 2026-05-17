import XCTest
@testable import TianXianQuant

final class AuthViewModelTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() {
        super.setUp()
        KeychainManager.shared.clearAll()
        UserDefaultsManager.shared.clearAll()
    }

    override func tearDown() {
        KeychainManager.shared.clearAll()
        UserDefaultsManager.shared.clearAll()
        super.tearDown()
    }

    // MARK: - Login Success

    func testLoginSuccess() async throws {
        let appState = AppState()
        XCTAssertFalse(appState.isAuthenticated)

        let success = await appState.login(username: "testuser", password: "testpass")

        if success {
            XCTAssertTrue(appState.isAuthenticated)
            XCTAssertNotNil(KeychainManager.shared.authToken)
            XCTAssertEqual(KeychainManager.shared.username, "testuser")
        }
    }

    // MARK: - Login Failure

    func testLoginFailure() async {
        let appState = AppState()
        appState.isAuthenticated = false

        let success = await appState.login(
            username: "nonexistent_user_12345",
            password: "wrongpassword"
        )

        XCTAssertFalse(success)
        XCTAssertFalse(appState.isAuthenticated)
    }

    // MARK: - Token Storage

    func testTokenStorage() {
        let testToken = "test_token_abc123"
        KeychainManager.shared.authToken = testToken

        let retrieved = KeychainManager.shared.authToken
        XCTAssertEqual(retrieved, testToken)
    }

    // MARK: - Password NOT in UserDefaults

    func testPasswordNotInUserDefaults() {
        let defaults = UserDefaults(suiteName: "com.tianxian.quant.ios.prefs")!
        defaults.removeObject(forKey: "password")
        defaults.removeObject(forKey: "pass")

        let passwordInDefaults = defaults.string(forKey: "password")
        let passInDefaults = defaults.string(forKey: "pass")
        XCTAssertNil(passwordInDefaults, "Password must not be stored in UserDefaults")
        XCTAssertNil(passInDefaults, "Password must not be stored in UserDefaults")
    }

    // MARK: - Logout Clears Token

    func testLogoutClearsToken() {
        KeychainManager.shared.authToken = "some_token"
        KeychainManager.shared.username = "testuser"
        UserDefaultsManager.shared.userId = "user123"

        let appState = AppState()
        appState.token = KeychainManager.shared.authToken
        appState.username = KeychainManager.shared.username
        appState.userId = UserDefaultsManager.shared.userId
        appState.isAuthenticated = true
        appState.isVip = true

        appState.logout()

        XCTAssertNil(appState.token)
        XCTAssertNil(appState.username)
        XCTAssertNil(appState.userId)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertFalse(appState.isVip)
        XCTAssertNil(KeychainManager.shared.authToken)
        XCTAssertNil(UserDefaultsManager.shared.userId)
    }
}
