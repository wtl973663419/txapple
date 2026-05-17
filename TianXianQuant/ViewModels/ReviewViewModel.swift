import SwiftUI
import Observation

@Observable
final class ReviewViewModel {
    var marketOverview: [MarketOverview] = []
    var marketSentiment: MarketSentiment?
    var limitUpStocks: [LimitUpStock] = []
    var sectorStrength: [SectorStrength] = []
    var yesterdayLimitUpPerf: YesterdayLimitUpPerformance?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Load All

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadMarketOverview() }
            group.addTask { await self.loadLimitUpStocks() }
            group.addTask { await self.loadSectorStrength() }
        }

        isLoading = false
    }

    func loadMarketOverview() async {
        do {
            let data: [MarketOverview] = try await APIClient.shared.request(.marketOverview)
            await MainActor.run { self.marketOverview = data }
        } catch {
            await MainActor.run { self.marketOverview = Self.mockMarketOverview }
        }

        // Load sentiment separately (may come embedded or as separate endpoint)
        await MainActor.run {
            self.marketSentiment = Self.mockMarketSentiment
            self.yesterdayLimitUpPerf = Self.mockYesterdayLimitUpPerf
        }
    }

    func loadLimitUpStocks() async {
        do {
            let data: [LimitUpStock] = try await APIClient.shared.request(.limitUpStocks)
            await MainActor.run { self.limitUpStocks = data }
        } catch {
            await MainActor.run { self.limitUpStocks = Self.mockLimitUpStocks }
        }
    }

    func loadSectorStrength() async {
        do {
            let data: [SectorStrength] = try await APIClient.shared.request(.sectorStrength)
            await MainActor.run { self.sectorStrength = data }
        } catch {
            await MainActor.run { self.sectorStrength = Self.mockSectorStrength }
        }
    }

    // MARK: - Filter Helpers

    var filteredLimitUpStocks: [LimitUpStock] {
        limitUpStocks.sorted { $0.continuousDays > $1.continuousDays }
    }

    func limitUpStocks(for board: String) -> [LimitUpStock] {
        limitUpStocks.filter { $0.boardCategory == board }
    }

    var sortedSectorStrength: [SectorStrength] {
        sectorStrength.sorted { $0.score > $1.score }
    }

    // MARK: - Mock Data

    static let mockMarketOverview: [MarketOverview] = [
        MarketOverview(indexCode: "000001", indexName: "上证指数", price: 3085.25, changePercent: 0.42, changePoint: 12.88, volume: 280_000_000_000, amount: 380_000_000_000),
        MarketOverview(indexCode: "399001", indexName: "深证成指", price: 9850.50, changePercent: 0.68, changePoint: 66.35, volume: 420_000_000_000, amount: 520_000_000_000),
        MarketOverview(indexCode: "399006", indexName: "创业板指", price: 1985.30, changePercent: 1.25, changePoint: 24.55, volume: 150_000_000_000, amount: 220_000_000_000),
        MarketOverview(indexCode: "000688", indexName: "科创50", price: 850.60, changePercent: -0.32, changePoint: -2.75, volume: 35_000_000_000, amount: 55_000_000_000),
        MarketOverview(indexCode: "000016", indexName: "上证50", price: 2520.80, changePercent: 0.15, changePoint: 3.80, volume: 55_000_000_000, amount: 78_000_000_000),
    ]

    static let mockMarketSentiment = MarketSentiment(
        upCount: 2850, flatCount: 520, downCount: 1630,
        limitUpCount: 58, limitDownCount: 12,
        totalAmount: 850_000_000_000,
        northNetInflow: 5_200_000_000,
        sentimentLevel: "偏乐观", sentimentScore: 68
    )

    static let mockYesterdayLimitUpPerf = YesterdayLimitUpPerformance(
        totalCount: 45, redCount: 28, greenCount: 15, redRate: 62.2, avgChange: 2.35, continueLimitUpCount: 12,
        bestStock: nil, worstStock: nil
    )

    static let mockLimitUpStocks: [LimitUpStock] = [
        LimitUpStock(code: "300274", name: "阳光电源", price: 98.50, changePercent: 10.02, limitUpTime: "09:30:15", limitUpReason: "光伏龙头涨停", sealAmount: 520_000_000, isOpened: false, openCount: 0, continuousDays: 1, turnover: 5.20, volume: 35_000_000, marketCap: 146_000_000_000, industry: "光伏", reasonTags: ["龙头涨停", "机构买入"]),
        LimitUpStock(code: "002230", name: "科大讯飞", price: 52.30, changePercent: 10.00, limitUpTime: "09:45:30", limitUpReason: "AI概念强势", sealAmount: 380_000_000, isOpened: false, openCount: 0, continuousDays: 2, turnover: 3.80, volume: 42_000_000, marketCap: 121_000_000_000, industry: "人工智能", reasonTags: ["AI", "连板"]),
        LimitUpStock(code: "600519", name: "贵州茅台", price: 1680.50, changePercent: 1.25, limitUpTime: "10:15:00", limitUpReason: "消费复苏预期", sealAmount: 1_200_000_000, isOpened: true, openCount: 1, continuousDays: 3, turnover: 0.35, volume: 3_200_000, marketCap: 2_100_000_000_000, industry: "白酒", reasonTags: ["消费", "蓝筹"]),
        LimitUpStock(code: "688981", name: "中芯国际", price: 58.80, changePercent: 10.01, limitUpTime: "09:35:00", limitUpReason: "芯片限制利好国产替代", sealAmount: 650_000_000, isOpened: false, openCount: 0, continuousDays: 1, turnover: 4.50, volume: 55_000_000, marketCap: 468_000_000_000, industry: "半导体", reasonTags: ["国产替代", "芯片"]),
        LimitUpStock(code: "002415", name: "海康威视", price: 32.80, changePercent: 9.99, limitUpTime: "13:20:45", limitUpReason: "海外业务预期改善", sealAmount: 280_000_000, isOpened: true, openCount: 2, continuousDays: 1, turnover: 0.78, volume: 22_000_000, marketCap: 307_000_000_000, industry: "安防", reasonTags: ["超跌反弹", "机构重仓"]),
        LimitUpStock(code: "000858", name: "五粮液", price: 145.80, changePercent: 9.98, limitUpTime: "14:05:00", limitUpReason: "白酒板块走强", sealAmount: 150_000_000, isOpened: false, openCount: 0, continuousDays: 2, turnover: 1.20, volume: 15_000_000, marketCap: 566_000_000_000, industry: "白酒", reasonTags: ["消费", "连板"]),
        LimitUpStock(code: "002594", name: "比亚迪", price: 268.50, changePercent: 10.00, limitUpTime: "09:50:00", limitUpReason: "新能源车销量超预期", sealAmount: 450_000_000, isOpened: false, openCount: 0, continuousDays: 1, turnover: 0.95, volume: 12_000_000, marketCap: 780_000_000_000, industry: "新能源汽车", reasonTags: ["新能源", "龙头"]),
    ]

    static let mockSectorStrength: [SectorStrength] = [
        SectorStrength(sector: "人工智能", count: 8, maxDays: 3, avgDays: 1.8, score: 92.5, stocks: [
            SectorStrengthStock(code: "002230", name: "科大讯飞", days: 2, pct: 18.5),
            SectorStrengthStock(code: "688111", name: "金山办公", days: 1, pct: 6.5),
        ]),
        SectorStrength(sector: "新能源汽车", count: 6, maxDays: 2, avgDays: 1.3, score: 85.0, stocks: [
            SectorStrengthStock(code: "002594", name: "比亚迪", days: 1, pct: 10.0),
            SectorStrengthStock(code: "300750", name: "宁德时代", days: 2, pct: 8.2),
        ]),
        SectorStrength(sector: "半导体", count: 5, maxDays: 3, avgDays: 1.6, score: 78.5, stocks: [
            SectorStrengthStock(code: "688981", name: "中芯国际", days: 3, pct: 22.0),
        ]),
        SectorStrength(sector: "光伏", count: 4, maxDays: 1, avgDays: 1.0, score: 72.0, stocks: [
            SectorStrengthStock(code: "300274", name: "阳光电源", days: 1, pct: 10.0),
            SectorStrengthStock(code: "601012", name: "隆基绿能", days: 1, pct: 5.5),
        ]),
        SectorStrength(sector: "白酒", count: 3, maxDays: 3, avgDays: 2.0, score: 68.0, stocks: [
            SectorStrengthStock(code: "600519", name: "贵州茅台", days: 3, pct: 5.2),
            SectorStrengthStock(code: "000858", name: "五粮液", days: 2, pct: 12.0),
        ]),
    ]
}
