import Foundation

// MARK: - Core Stock Models

struct StockInfo: Codable, Identifiable, Equatable {
    let code: String
    let name: String
    let price: Double
    let changePercent: Double
    let volume: Int64
    var marketCap: Double = 0
    var pe: Double = 0
    var pb: Double = 0
    var turnover: Double = 0
    var high: Double = 0
    var low: Double = 0
    var open: Double = 0
    var yesterdayClose: Double = 0
    var deepAnalysis: DeepAnalysis?

    var id: String { code }

    var changePercentFormatted: String {
        String(format: "%+.2f%%", changePercent)
    }

    var isUp: Bool { changePercent >= 0 }
    var isDown: Bool { changePercent < 0 }
}

struct DeepAnalysis: Codable, Equatable {
    let moat: String
    let industryPosition: String
    let salesStatus: String
    let productionStatus: String
    let institutionView: String

    init(moat: String = "", industryPosition: String = "", salesStatus: String = "",
         productionStatus: String = "", institutionView: String = "") {
        self.moat = moat
        self.industryPosition = industryPosition
        self.salesStatus = salesStatus
        self.productionStatus = productionStatus
        self.institutionView = institutionView
    }
}

// MARK: - Sector & Market Models

struct SectorInfo: Codable, Identifiable {
    let name: String
    var code: String = ""
    let changePercent: Double
    let leadingStock: String
    var leadingStockCode: String = ""
    let capitalFlow: Double
    var leadingStocks: [StockInfo] = []

    var id: String { code.isEmpty ? name : code }
}

struct DragonTigerStock: Codable, Identifiable {
    let code: String
    let name: String
    let price: Double
    let changePercent: Double
    let reason: String
    let buySeats: Int
    let sellSeats: Int
    let netInflow: Double
    var buyAmount: Double = 0
    var sellAmount: Double = 0
    var turnover: Double = 0
    var volume: Int64 = 0
    var high: Double = 0
    var low: Double = 0
    var open: Double = 0
    var yesterdayClose: Double = 0
    var marketCap: Double = 0
    var pe: Double = 0
    var pb: Double = 0

    var id: String { code }
}

struct MarketOverview: Codable, Identifiable {
    let indexCode: String
    let indexName: String
    let price: Double
    let changePercent: Double
    let changePoint: Double
    let volume: Int64
    let amount: Double

    var id: String { indexCode }
    var isUp: Bool { changePercent >= 0 }
}

struct ReviewData: Codable {
    let date: String
    let upCount: Int
    let downCount: Int
    let limitUpCount: Int
    let limitDownCount: Int
    let totalAmount: Double
    var hotSectors: [SectorInfo] = []
    var limitUpStocks: [StockInfo] = []
    var limitDownStocks: [StockInfo] = []
    var strongStocks: [StockInfo] = []
}

// MARK: - Community Models

struct Post: Codable, Identifiable {
    let id: String
    let author: String
    var userId: String = ""
    let avatar: String
    let title: String
    let content: String
    let time: String
    var likes: Int
    var comments: Int
    let category: String
    var isVip: Bool = false
    var images: [String] = []
    var commentList: [Comment] = []
}

struct Comment: Codable, Identifiable {
    let id: String
    let postId: String
    let author: String
    var authorAvatar: String = ""
    let content: String
    let time: String
    var likes: Int = 0
    var isLiked: Bool = false
}

// MARK: - Strategy Models

struct Strategy: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let winRate: Double
    let maxDrawdown: Double
    let sharpeRatio: Double
    var annualReturn: Double = 0
    var totalTrades: Int = 0
    var profitFactor: Double = 0
    var isVip: Bool = false
    var tags: [String] = []
}
