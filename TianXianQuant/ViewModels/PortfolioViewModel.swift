import SwiftUI
import Observation

@Observable
final class PortfolioViewModel {
    var stocks: [PortfolioStock] = []
    var totalCapital: Double = 0
    var isRefreshing = false

    private let storageKey = "portfolio_stocks"
    private let capitalKey = "portfolio_total_capital"

    // MARK: - Persistence

    func load() {
        if let saved: [PortfolioStock] = UserDefaultsManager.shared.loadCodable([PortfolioStock].self, forKey: storageKey) {
            stocks = saved
        } else {
            stocks = Self.mockStocks
        }
        totalCapital = UserDefaultsManager.shared.loadCodable(Double.self, forKey: capitalKey) ?? 0
        recalculateRatios()
    }

    func save() {
        UserDefaultsManager.shared.saveCodable(stocks, forKey: storageKey)
        UserDefaultsManager.shared.saveCodable(totalCapital, forKey: capitalKey)
    }

    // MARK: - CRUD

    func add(stock: PortfolioStock) {
        if let index = stocks.firstIndex(where: { $0.code == stock.code }) {
            stocks[index] = stock
        } else {
            stocks.append(stock)
        }
        recalculateRatios()
        save()
    }

    func delete(id: String) {
        stocks.removeAll { $0.id == id }
        recalculateRatios()
        save()
    }

    func update(stock: PortfolioStock) {
        if let index = stocks.firstIndex(where: { $0.id == stock.id }) {
            stocks[index] = stock
            recalculateRatios()
            save()
        }
    }

    func refreshPrices() async {
        isRefreshing = true

        // Simulate price refresh with +/-5% random variation
        for i in stocks.indices {
            let variation = Double.random(in: -0.05...0.05)
            let newPrice = stocks[i].currentPrice * (1.0 + variation)
            stocks[i].currentPrice = max(newPrice, 0.01)
        }

        // Try real API if we have codes
        let codes = stocks.map { $0.code }.joined(separator: ",")
        if !codes.isEmpty {
            do {
                let data: Data = try await APIClient.shared.requestRaw(.realtimeQuotes(codes: codes))
                if let quotes = try? JSONDecoder().decode(ResponseWrapper<[RealtimeQuote]>.self, from: data),
                   let quoteList = quotes.data {
                    for quote in quoteList {
                        if let code = quote.code, let price = quote.price,
                           let index = stocks.firstIndex(where: { $0.code == code }) {
                            stocks[index].currentPrice = price
                        }
                    }
                }
            } catch {
                // Keep simulated prices
            }
        }

        recalculateRatios()
        save()
        isRefreshing = false
    }

    // MARK: - Calculations

    func calculateTotalCapital() {
        totalCapital = stocks.reduce(0) { $0 + $1.capital }
    }

    var totalProfit: Double {
        stocks.reduce(0) { $0 + $1.profit }
    }

    var totalProfitPercent: Double {
        let totalCost = stocks.reduce(0.0) { $0 + $1.cost * $1.count }
        let totalValue = stocks.reduce(0.0) { $0 + $1.currentPrice * $1.count }
        return totalCost > 0 ? (totalValue - totalCost) / totalCost * 100 : 0
    }

    var totalMarketValue: Double {
        stocks.reduce(0) { $0 + $1.currentPrice * $1.count }
    }

    private func recalculateRatios() {
        let totalValue = max(stocks.reduce(0.0) { $0 + $1.currentPrice * $1.count }, 0.01)
        for i in stocks.indices {
            stocks[i].positionRatio = (stocks[i].currentPrice * stocks[i].count) / totalValue * 100
        }
        calculateTotalCapital()
    }

    // MARK: - Mock Data

    static let mockStocks: [PortfolioStock] = [
        PortfolioStock(id: UUID().uuidString, code: "600519", name: "贵州茅台", count: 100, cost: 1650.00, currentPrice: 1680.50, feeRate: 0.0003, capital: 165_000, positionRatio: 25.0),
        PortfolioStock(id: UUID().uuidString, code: "300750", name: "宁德时代", count: 500, cost: 208.00, currentPrice: 210.30, feeRate: 0.0003, capital: 104_000, positionRatio: 18.5),
        PortfolioStock(id: UUID().uuidString, code: "000858", name: "五粮液", count: 300, cost: 140.00, currentPrice: 145.80, feeRate: 0.0003, capital: 42_000, positionRatio: 12.0),
    ]
}
