import Foundation

// MARK: - Plan & Portfolio Models

struct PlanItem: Codable, Identifiable {
    let id: String
    let code: String
    let name: String
    let type: PlanType
    var entryPrice: Double = 0
    var stopLossPrice: Double = 0
    var takeProfitPrice: Double = 0
    var exitPrice: Double = 0
    var reason: String = ""
    var priority: Int = 0
    var isDone: Bool = false
    var alertEnabled: Bool = false
}

enum PlanType: String, Codable, CaseIterable {
    case watch = "WATCH"
    case buy = "BUY"
    case sell = "SELL"

    var displayName: String {
        switch self {
        case .watch: return "自选"
        case .buy: return "买入"
        case .sell: return "卖出"
        }
    }

    var colorName: String {
        switch self {
        case .watch: return "blue"
        case .buy: return "red"
        case .sell: return "green"
        }
    }
}

struct TargetPrice: Codable, Identifiable {
    let id: String
    let price: Double
    let label: String
    let direction: PriceDirection

    enum PriceDirection: String, Codable {
        case up = "UP"
        case down = "DOWN"
    }
}

struct PortfolioStock: Codable, Identifiable {
    let id: String
    let code: String
    let name: String
    var count: Double = 0
    var cost: Double = 0
    var currentPrice: Double = 0
    var feeRate: Double = 0.0003
    var capital: Double = 0

    var profit: Double { (currentPrice - cost) * count }
    var profitPercent: Double { cost > 0 ? (currentPrice - cost) / cost * 100 : 0 }
    var positionRatio: Double = 0
}
