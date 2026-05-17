import Foundation
import BackgroundTasks

/// Registers and handles BGAppRefreshTaskRequests so the system can wake
/// the app periodically to check prices even when backgrounded.
enum BackgroundTaskManager {
    static let priceCheckIdentifier = "com.tianxian.quant.pricecheck"

    /// Register the background task handler. Call this in application(_:didFinishLaunchingWithOptions:).
    static func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: priceCheckIdentifier, using: nil) { task in
            handlePriceCheckRefresh(task: task as! BGAppRefreshTask)
        }
    }

    /// Schedule the next background refresh. iOS enforces a minimum interval (~15 min).
    static func schedulePriceCheckRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: priceCheckIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Scheduling can fail if the app has used too many tasks —
            // silently ignore and wait until the next attempt.
        }
    }

    /// Handle the background task by performing a price check.
    private static func handlePriceCheckRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            // Cancel any in-flight work
            task.setTaskCompleted(success: false)
        }

        Task {
            await PriceAlertService.shared.checkPrices()
            task.setTaskCompleted(success: true)
        }

        // Schedule the next refresh
        schedulePriceCheckRefresh()
    }
}
