import Foundation

// MARK: - Limit-up Stock Models

struct LimitUpStock: Codable, Identifiable {
    let code: String
    let name: String
    let price: Double
    let changePercent: Double
    let limitUpTime: String
    let limitUpReason: String
    let sealAmount: Double
    let isOpened: Bool
    let openCount: Int
    let continuousDays: Int
    var turnover: Double = 0
    var volume: Int64 = 0
    var marketCap: Double = 0
    var industry: String = ""
    var reasonTags: [String] = []

    var id: String { code }

    var boardCategory: String {
        if continuousDays >= 3 { return "3板+" }
        if continuousDays == 2 { return "2板" }
        return "首板"
    }

    var limitUpTimeColor: Int {
        // Top 5 get red, 20+ get grey
        return 0
    }
}

struct SectorStrength: Codable, Identifiable {
    let sector: String
    let count: Int
    let maxDays: Int
    let avgDays: Double
    let score: Double
    var stocks: [SectorStrengthStock] = []

    var id: String { sector }
}

struct SectorStrengthStock: Codable, Identifiable {
    let code: String
    let name: String
    let days: Int
    let pct: Double

    var id: String { code }
}

struct YesterdayLimitUpPerformance: Codable {
    let totalCount: Int
    let redCount: Int
    let greenCount: Int
    let redRate: Double
    let avgChange: Double
    let continueLimitUpCount: Int
    var bestStock: LimitUpStock?
    var worstStock: LimitUpStock?
}

struct MarketSentiment: Codable {
    let upCount: Int
    let flatCount: Int
    let downCount: Int
    let limitUpCount: Int
    let limitDownCount: Int
    let totalAmount: Double
    let northNetInflow: Double
    let sentimentLevel: String
    let sentimentScore: Int
    var yesterdayLimitUpPerf: YesterdayLimitUpPerformance?
}
