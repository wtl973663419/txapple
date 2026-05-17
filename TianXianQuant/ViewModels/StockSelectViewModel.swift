import SwiftUI
import Observation

@Observable
final class StockSelectViewModel {
    var stocks: [StockInfo] = []
    var topGainers: [StockInfo] = []
    var topLosers: [StockInfo] = []
    var hotSectors: [SectorInfo] = []
    var dragonTigerStocks: [DragonTigerStock] = []
    var isLoading = false
    var errorMessage: String?

    var selectedCategory = "选股"
    var searchText = ""

    private var searchTask: Task<Void, Never>?
    private let stockNameMap: [String: String] = [
        "000001": "平安银行", "000002": "万科A", "000858": "五粮液",
        "002415": "海康威视", "300750": "宁德时代", "600519": "贵州茅台",
        "600036": "招商银行", "601318": "中国平安", "000725": "京东方A",
        "002594": "比亚迪", "300059": "东方财富", "688981": "中芯国际",
        "600030": "中信证券", "000651": "格力电器", "002475": "立讯精密",
        "300124": "汇川技术", "600887": "伊利股份", "601012": "隆基绿能",
        "002230": "科大讯飞", "300274": "阳光电源", "688111": "金山办公",
        "600809": "山西汾酒", "000568": "泸州老窖", "002142": "宁波银行",
        "300015": "爱尔眼科", "601888": "中国中免"
    ]

    // MARK: - Data Loading

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTopGainers() }
            group.addTask { await self.loadTopLosers() }
            group.addTask { await self.loadHotSectors() }
            group.addTask { await self.loadDragonTiger() }
        }

        isLoading = false
    }

    private func loadTopGainers() async {
        do {
            let data: [StockInfo] = try await APIClient.shared.request(.topGainers)
            await MainActor.run { self.topGainers = data }
        } catch {
            await MainActor.run { self.topGainers = Self.mockTopGainers }
        }
    }

    private func loadTopLosers() async {
        do {
            let data: [StockInfo] = try await APIClient.shared.request(.topLosers)
            await MainActor.run { self.topLosers = data }
        } catch {
            await MainActor.run { self.topLosers = Self.mockTopLosers }
        }
    }

    private func loadHotSectors() async {
        do {
            let data: [SectorInfo] = try await APIClient.shared.request(.hotSectors)
            await MainActor.run { self.hotSectors = data }
        } catch {
            await MainActor.run { self.hotSectors = Self.mockHotSectors }
        }
    }

    private func loadDragonTiger() async {
        do {
            let data: [DragonTigerStock] = try await APIClient.shared.request(.dragonTiger)
            await MainActor.run { self.dragonTigerStocks = data }
        } catch {
            await MainActor.run { self.dragonTigerStocks = Self.mockDragonTiger }
        }
    }

    // MARK: - Search with Debounce

    func searchStocks(keyword: String) {
        searchTask?.cancel()

        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            stocks = []
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }

                let results: [StockInfo] = try await APIClient.shared.request(.search(keyword: keyword))
                guard !Task.isCancelled else { return }
                await MainActor.run { self.stocks = results }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.stocks = Self.mockStocks.filter {
                        $0.name.localizedCaseInsensitiveContains(keyword) ||
                        $0.code.contains(keyword)
                    }
                }
            }
        }
    }

    // MARK: - Filter

    func filterByCategory(_ category: String) {
        selectedCategory = category
    }

    var currentStocks: [StockInfo] {
        switch selectedCategory {
        case "涨幅榜": return topGainers
        case "跌幅榜": return topLosers
        case "选股": return stocks
        default: return stocks
        }
    }

    // MARK: - Stock Name Lookup

    func stockName(for code: String) -> String {
        stockNameMap[code] ?? ""
    }

    // MARK: - Mock Data

    static let mockStocks: [StockInfo] = [
        StockInfo(code: "600519", name: "贵州茅台", price: 1680.50, changePercent: 1.25, volume: 3_200_000, marketCap: 2_100_000_000_000, pe: 32.5, pb: 9.8, turnover: 0.35, high: 1695.00, low: 1668.00, open: 1672.00, yesterdayClose: 1659.80),
        StockInfo(code: "000858", name: "五粮液", price: 145.80, changePercent: 2.10, volume: 15_000_000, marketCap: 566_000_000_000, pe: 22.1, pb: 5.4, turnover: 1.20, high: 146.50, low: 143.20, open: 143.80, yesterdayClose: 142.80),
        StockInfo(code: "300750", name: "宁德时代", price: 210.30, changePercent: -0.85, volume: 28_000_000, marketCap: 925_000_000_000, pe: 21.5, pb: 4.2, turnover: 2.10, high: 213.00, low: 208.50, open: 212.50, yesterdayClose: 212.10),
        StockInfo(code: "002594", name: "比亚迪", price: 268.50, changePercent: 1.80, volume: 12_000_000, marketCap: 780_000_000_000, pe: 35.2, pb: 6.8, turnover: 0.95, high: 270.00, low: 264.00, open: 265.00, yesterdayClose: 263.75),
        StockInfo(code: "000001", name: "平安银行", price: 10.85, changePercent: 0.42, volume: 85_000_000, marketCap: 210_000_000_000, pe: 5.8, pb: 0.72, turnover: 0.65, high: 10.95, low: 10.78, open: 10.82, yesterdayClose: 10.80),
        StockInfo(code: "600036", name: "招商银行", price: 35.60, changePercent: 0.88, volume: 45_000_000, marketCap: 898_000_000_000, pe: 6.5, pb: 0.95, turnover: 0.42, high: 35.80, low: 35.30, open: 35.40, yesterdayClose: 35.29),
        StockInfo(code: "601318", name: "中国平安", price: 42.50, changePercent: -0.35, volume: 52_000_000, marketCap: 774_000_000_000, pe: 9.2, pb: 1.05, turnover: 0.48, high: 42.80, low: 42.20, open: 42.70, yesterdayClose: 42.65),
        StockInfo(code: "002415", name: "海康威视", price: 32.80, changePercent: 1.55, volume: 22_000_000, marketCap: 307_000_000_000, pe: 23.1, pb: 4.5, turnover: 0.78, high: 33.00, low: 32.40, open: 32.50, yesterdayClose: 32.30),
        StockInfo(code: "300059", name: "东方财富", price: 15.80, changePercent: -1.25, volume: 120_000_000, marketCap: 251_000_000_000, pe: 32.8, pb: 5.2, turnover: 3.50, high: 16.10, low: 15.60, open: 16.05, yesterdayClose: 16.00),
        StockInfo(code: "601012", name: "隆基绿能", price: 20.50, changePercent: 2.45, volume: 65_000_000, marketCap: 155_000_000_000, pe: 15.2, pb: 3.1, turnover: 1.85, high: 20.65, low: 20.10, open: 20.15, yesterdayClose: 20.01),
    ]

    static let mockTopGainers: [StockInfo] = [
        StockInfo(code: "300274", name: "阳光电源", price: 98.50, changePercent: 10.02, volume: 35_000_000, marketCap: 146_000_000_000, pe: 35.5, pb: 8.2, turnover: 5.20, high: 98.50, low: 89.50, open: 89.80, yesterdayClose: 89.53),
        StockInfo(code: "688981", name: "中芯国际", price: 58.80, changePercent: 8.55, volume: 55_000_000, marketCap: 468_000_000_000, pe: 55.0, pb: 3.8, turnover: 4.50, high: 59.20, low: 54.50, open: 54.80, yesterdayClose: 54.17),
        StockInfo(code: "002230", name: "科大讯飞", price: 52.30, changePercent: 7.80, volume: 42_000_000, marketCap: 121_000_000_000, pe: 85.0, pb: 7.5, turnover: 3.80, high: 52.80, low: 48.50, open: 48.80, yesterdayClose: 48.52),
        StockInfo(code: "688111", name: "金山办公", price: 380.00, changePercent: 6.50, volume: 8_500_000, marketCap: 175_000_000_000, pe: 75.0, pb: 12.5, turnover: 2.80, high: 382.00, low: 358.00, open: 360.00, yesterdayClose: 356.81),
        StockInfo(code: "000568", name: "泸州老窖", price: 188.50, changePercent: 5.85, volume: 8_000_000, marketCap: 277_000_000_000, pe: 25.5, pb: 6.8, turnover: 1.55, high: 189.00, low: 178.00, open: 179.00, yesterdayClose: 178.08),
    ]

    static let mockTopLosers: [StockInfo] = [
        StockInfo(code: "300124", name: "汇川技术", price: 58.20, changePercent: -7.50, volume: 18_000_000, marketCap: 155_000_000_000, pe: 42.0, pb: 9.5, turnover: 2.10, high: 62.50, low: 57.80, open: 62.00, yesterdayClose: 62.92),
        StockInfo(code: "002475", name: "立讯精密", price: 28.50, changePercent: -6.20, volume: 38_000_000, marketCap: 203_000_000_000, pe: 22.0, pb: 4.8, turnover: 2.50, high: 30.20, low: 28.20, open: 30.10, yesterdayClose: 30.38),
        StockInfo(code: "600809", name: "山西汾酒", price: 220.00, changePercent: -5.50, volume: 5_500_000, marketCap: 268_000_000_000, pe: 30.0, pb: 10.2, turnover: 0.85, high: 232.00, low: 218.00, open: 231.50, yesterdayClose: 232.80),
        StockInfo(code: "000725", name: "京东方A", price: 3.85, changePercent: -4.80, volume: 280_000_000, marketCap: 148_000_000_000, pe: 38.0, pb: 1.2, turnover: 4.20, high: 4.02, low: 3.82, open: 4.00, yesterdayClose: 4.04),
        StockInfo(code: "300015", name: "爱尔眼科", price: 18.60, changePercent: -4.20, volume: 45_000_000, marketCap: 135_000_000_000, pe: 55.0, pb: 8.5, turnover: 2.80, high: 19.30, low: 18.40, open: 19.20, yesterdayClose: 19.41),
    ]

    static let mockHotSectors: [SectorInfo] = [
        SectorInfo(name: "人工智能", code: "AI001", changePercent: 3.50, leadingStock: "科大讯飞", leadingStockCode: "002230", capitalFlow: 15.8, leadingStocks: [
            StockInfo(code: "002230", name: "科大讯飞", price: 52.30, changePercent: 7.80, volume: 42_000_000),
            StockInfo(code: "688111", name: "金山办公", price: 380.00, changePercent: 6.50, volume: 8_500_000),
            StockInfo(code: "300750", name: "宁德时代", price: 210.30, changePercent: -0.85, volume: 28_000_000),
        ]),
        SectorInfo(name: "新能源汽车", code: "EV001", changePercent: 2.80, leadingStock: "比亚迪", leadingStockCode: "002594", capitalFlow: 22.5, leadingStocks: [
            StockInfo(code: "002594", name: "比亚迪", price: 268.50, changePercent: 1.80, volume: 12_000_000),
            StockInfo(code: "300750", name: "宁德时代", price: 210.30, changePercent: -0.85, volume: 28_000_000),
            StockInfo(code: "601012", name: "隆基绿能", price: 20.50, changePercent: 2.45, volume: 65_000_000),
        ]),
        SectorInfo(name: "半导体", code: "SEMI001", changePercent: 2.20, leadingStock: "中芯国际", leadingStockCode: "688981", capitalFlow: 18.2, leadingStocks: [
            StockInfo(code: "688981", name: "中芯国际", price: 58.80, changePercent: 8.55, volume: 55_000_000),
            StockInfo(code: "300124", name: "汇川技术", price: 58.20, changePercent: -7.50, volume: 18_000_000),
        ]),
    ]

    static let mockDragonTiger: [DragonTigerStock] = [
        DragonTigerStock(code: "300274", name: "阳光电源", price: 98.50, changePercent: 10.02, reason: "光伏龙头强势涨停，机构大幅买入", buySeats: 3, sellSeats: 1, netInflow: 250_000_000, buyAmount: 580_000_000, sellAmount: 330_000_000, turnover: 5.20, volume: 35_000_000, high: 98.50, low: 89.50, open: 89.80, yesterdayClose: 89.53, marketCap: 146_000_000_000, pe: 35.5, pb: 8.2),
        DragonTigerStock(code: "688981", name: "中芯国际", price: 58.80, changePercent: 8.55, reason: "芯片概念持续活跃，北向资金净买入", buySeats: 2, sellSeats: 2, netInflow: 120_000_000, buyAmount: 420_000_000, sellAmount: 300_000_000, turnover: 4.50, volume: 55_000_000, high: 59.20, low: 54.50, open: 54.80, yesterdayClose: 54.17, marketCap: 468_000_000_000, pe: 55.0, pb: 3.8),
        DragonTigerStock(code: "002230", name: "科大讯飞", price: 52.30, changePercent: 7.80, reason: "AI概念热炒，游资接力拉升", buySeats: 4, sellSeats: 0, netInflow: 180_000_000, buyAmount: 350_000_000, sellAmount: 170_000_000, turnover: 3.80, volume: 42_000_000, high: 52.80, low: 48.50, open: 48.80, yesterdayClose: 48.52, marketCap: 121_000_000_000, pe: 85.0, pb: 7.5),
    ]
}
