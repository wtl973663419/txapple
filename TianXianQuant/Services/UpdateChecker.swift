import SwiftUI

/// Checks for app updates by comparing the server's versionCode against the
/// current bundle version. Presents an alert prompting the user to update.
@Observable
final class UpdateChecker {
    static let shared = UpdateChecker()

    private let storeURLString = "itms-apps://itunes.apple.com/app/idXXXXXXXXXX"

    private init() {}

    // MARK: - Public API

    /// Fetches version info from the server. Returns nil if up-to-date or on error.
    func checkForUpdate() async -> UpdateInfo? {
        do {
            let response: VersionResponse = try await APIClient.shared.request(.version)

            guard response.success, let versionInfo = response.data else {
                return nil
            }

            let currentVersionCode = APIConfig.appVersionCode
            let serverVersionCode = versionInfo.versionCode ?? 0
            let skippedVersion = UserDefaultsManager.shared.skippedVersionCode

            // No update available
            guard serverVersionCode > currentVersionCode else { return nil }

            // User previously skipped this version
            if serverVersionCode == skippedVersion { return nil }

            let forceUpdate = versionInfo.forceUpdate ?? false

            return UpdateInfo(
                hasUpdate: true,
                versionCode: serverVersionCode,
                versionName: versionInfo.versionName ?? "",
                updateLog: versionInfo.updateLog ?? "发现新版本，请更新",
                forceUpdate: forceUpdate
            )
        } catch {
            return nil
        }
    }

    /// Open the App Store page for this app.
    func openAppStore() {
        guard let url = URL(string: storeURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// Mark the current server version as skipped so it won't prompt again.
    func skipVersion(_ versionCode: Int) {
        UserDefaultsManager.shared.skippedVersionCode = versionCode
    }

    // MARK: - Alert Presenter

    /// Presents an update alert on the root view controller.
    /// - Parameter info: The update information from the server.
    func showUpdateAlert(info: UpdateInfo) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: "发现新版本 \(info.versionName)",
            message: info.updateLog,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "立即更新", style: .default) { _ in
            openAppStore()
        })

        if !info.forceUpdate {
            alert.addAction(UIAlertAction(title: "稍后再说", style: .cancel) { _ in
                skipVersion(info.versionCode)
            })
        }

        rootVC.present(alert, animated: true)
    }
}

// MARK: - Model

struct UpdateInfo {
    let hasUpdate: Bool
    let versionCode: Int
    let versionName: String
    let updateLog: String
    let forceUpdate: Bool
}
