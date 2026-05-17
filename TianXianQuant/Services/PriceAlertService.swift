import Foundation
import UserNotifications
import Observation

/// Monitors realtime prices against user-defined target prices and fires
/// local push notifications when thresholds are crossed. Runs a timer-based
/// polling loop during A-share trading hours (Mon-Fri, 9:30-15:00 CST).
@Observable
final class PriceAlertService: @unchecked Sendable {
    static let shared = PriceAlertService()

    private var timer: Timer?
    private var isRunning = false
    private var notificationAuthorized = false

    // Trading hours in China Standard Time
    private let morningOpen = (hour: 9, minute: 30)
    private let morningClose = (hour: 11, minute: 30)
    private let afternoonOpen = (hour: 13, minute: 0)
    private let afternoonClose = (hour: 15, minute: 0)
    private let pollInterval: TimeInterval = 30

    private let storeKey = "plan_items"

    private init() {}

    // MARK: - Public API

    /// Start the price monitoring service. Requests notification permission on first call.
    func startService() {
        guard !isRunning else { return }
        requestNotificationPermission()
        isRunning = true
        scheduleNextPoll()
    }

    /// Stop polling.
    func stopService() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Polling

    private func scheduleNextPoll() {
        guard isRunning else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: false) { [weak self] _ in
            guard let self else { return }
            if self.isTradingHour() {
                Task { await self.checkPrices() }
            }
            self.scheduleNextPoll()
        }
    }

    /// Determine if the current moment falls within A-share trading hours.
    /// Trading hours: Monday-Friday, 9:30-11:30 and 13:00-15:00 CST (UTC+8).
    func isTradingHour() -> Bool {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

        let weekday = calendar.component(.weekday, from: now) // 1=Sun ... 7=Sat
        guard weekday >= 2 && weekday <= 6 else { return false } // Mon-Fri

        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        // Morning session: 9:30 – 11:30
        if hour == 9 && minute >= 30 { return true }
        if hour == 10 { return true }
        if hour == 11 && minute <= 30 { return true }

        // Afternoon session: 13:00 – 15:00
        if hour == 13 { return true }
        if hour == 14 { return true }
        if hour == 15 && minute == 0 { return true }

        return false
    }

    // MARK: - Price Checking

    /// Fetch current prices for all active plans with alerts and check targets.
    func checkPrices() async {
        let plans = loadPlans()
        guard !plans.isEmpty else { return }

        // Filter: active plans with alert enabled and at least one target price set
        let activePlans = plans.filter {
            !$0.isDone && $0.alertEnabled && ($0.takeProfitPrice > 0 || $0.stopLossPrice > 0)
        }

        guard !activePlans.isEmpty else { return }

        // Build comma-separated codes list
        let codes = activePlans.map(\.code).joined(separator: ",")

        do {
            let response: ResponseWrapper<[RealtimeQuote]> = try await APIClient.shared.request(
                .realtimeQuotes(codes: codes)
            )

            guard response.success, let quotes = response.data else { return }

            let priceMap = Dictionary(uniqueKeysWithValues: quotes.compactMap { quote in
                guard let code = quote.code, let price = quote.price else { return nil }
                return (code, price)
            })

            let triggered = UserDefaultsManager.shared.triggeredAlerts
            let today = dateString()

            for plan in activePlans {
                guard let currentPrice = priceMap[plan.code] else { continue }

                // Check take-profit target (UP direction)
                if plan.takeProfitPrice > 0, currentPrice >= plan.takeProfitPrice {
                    let triggerKey = "\(plan.id)_profit_\(today)"
                    if !triggered.contains(triggerKey) {
                        UserDefaultsManager.shared.markAlertTriggered(triggerKey)
                        await sendAlert(
                            planId: plan.id,
                            stockName: plan.name,
                            price: currentPrice,
                            targetPrice: plan.takeProfitPrice,
                            direction: "止盈"
                        )
                    }
                }

                // Check stop-loss target (DOWN direction)
                if plan.stopLossPrice > 0, currentPrice <= plan.stopLossPrice {
                    let triggerKey = "\(plan.id)_loss_\(today)"
                    if !triggered.contains(triggerKey) {
                        UserDefaultsManager.shared.markAlertTriggered(triggerKey)
                        await sendAlert(
                            planId: plan.id,
                            stockName: plan.name,
                            price: currentPrice,
                            targetPrice: plan.stopLossPrice,
                            direction: "止损"
                        )
                    }
                }
            }
        } catch {
            // Silently ignore polling errors — retry on next interval
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        guard !notificationAuthorized else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            self.notificationAuthorized = granted
        }
    }

    func sendAlert(planId: String, stockName: String, price: Double, targetPrice: Double, direction: String) async {
        let content = UNMutableNotificationContent()
        content.title = "\(stockName) \(direction)提醒"
        content.body = "当前价格 ¥\(price.priceString)，\(direction)目标 ¥\(targetPrice.priceString)"
        content.sound = .default

        let identifier = "price_alert_\(planId)_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Deliver immediately
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // Notification delivery failure is non-critical
        }
    }

    // MARK: - Plan Persistence

    private func loadPlans() -> [PlanItem] {
        UserDefaultsManager.shared.loadCodable([PlanItem].self, forKey: storeKey) ?? []
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter.string(from: Date())
    }
}
