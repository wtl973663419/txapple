import Foundation
import Observation

// MARK: - Backtest Result Model

struct BacktestResult: Identifiable {
    let id: String
    let strategyId: String
    let strategyName: String
    let startDate: String
    let endDate: String
    let totalReturn: Double
    let maxDrawdown: Double
    let sharpeRatio: Double
    let winRate: Double
    let totalTrades: Int
    let profitTrades: Int
    let annualizedReturn: Double
}

// MARK: - Quant ViewModel

@Observable
final class QuantViewModel {

    // MARK: - Properties

    var strategies: [Strategy] = []
    var selectedStrategy: Strategy?
    var backtestResult: BacktestResult?
    var isLoading = false

    // MARK: - Init

    init() {
        loadStrategies()
    }

    // MARK: - Data Loading

    func loadStrategies() {
        strategies = [
            Strategy(
                id: "trend_following",
                name: "趋势跟踪",
                description: "基于均线金叉死叉的中长线趋势跟踪策略，捕捉大级别行情。适合震荡上行市场，顺势而为，不逆势操作。",
                winRate: 62,
                maxDrawdown: 12,
                sharpeRatio: 1.8,
                annualReturn: 28,
                totalTrades: 156,
                profitFactor: 2.1,
                isVip: false,
                tags: ["趋势", "均线", "中长线"]
            ),
            Strategy(
                id: "mean_reversion",
                name: "均值回归",
                description: "利用股价波动回归均值的特性，在超卖时买入、超买时卖出。适合震荡行情，配合布林带使用效果更佳。",
                winRate: 58,
                maxDrawdown: 15,
                sharpeRatio: 1.5,
                annualReturn: 22,
                totalTrades: 203,
                profitFactor: 1.8,
                isVip: true,
                tags: ["均值回归", "布林带", "震荡"]
            ),
            Strategy(
                id: "momentum",
                name: "动量策略",
                description: "追涨强势股，结合成交量放大信号，捕捉短线爆发力。要求严格止损，适合短线交易者。",
                winRate: 55,
                maxDrawdown: 18,
                sharpeRatio: 1.3,
                annualReturn: 25,
                totalTrades: 312,
                profitFactor: 1.6,
                isVip: true,
                tags: ["动量", "短线", "追涨"]
            ),
            Strategy(
                id: "grid_trading",
                name: "网格交易",
                description: "在预设价格区间内自动低吸高抛，通过网格密度控制仓位。适合横盘震荡行情，收益稳定。",
                winRate: 68,
                maxDrawdown: 8,
                sharpeRatio: 2.1,
                annualReturn: 18,
                totalTrades: 427,
                profitFactor: 2.5,
                isVip: false,
                tags: ["网格", "横盘", "低风险"]
            ),
            Strategy(
                id: "multi_factor",
                name: "多因子选股",
                description: "综合估值、成长、质量、动量等多因子打分选股，通过因子轮动适应不同市场风格。",
                winRate: 65,
                maxDrawdown: 10,
                sharpeRatio: 1.9,
                annualReturn: 32,
                totalTrades: 189,
                profitFactor: 2.3,
                isVip: true,
                tags: ["多因子", "选股", "轮动"]
            ),
            Strategy(
                id: "dragon_head",
                name: "龙头战法",
                description: "聚焦市场龙头股，在连板初期介入，享受溢价。高风险高收益，需严格仓位管理和心态控制。",
                winRate: 52,
                maxDrawdown: 25,
                sharpeRatio: 1.1,
                annualReturn: 35,
                totalTrades: 98,
                profitFactor: 1.4,
                isVip: true,
                tags: ["龙头", "打板", "高风险"]
            )
        ]
    }

    // MARK: - Actions

    func selectStrategy(id: String) {
        selectedStrategy = strategies.first { $0.id == id }
        backtestResult = nil
    }

    /// Run a simulated backtest with slight random variation for realism.
    func runBacktest(strategyId: String) {
        guard let strategy = strategies.first(where: { $0.id == strategyId }) else { return }

        isLoading = true
        backtestResult = nil

        // Simulate network/processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }

            // Add slight random variation (±8%)
            let variation: (Double) -> Double = { base in
                let factor = Double.random(in: 0.92...1.08)
                return base * factor
            }

            let profitTrades = Int(Double(strategy.totalTrades) * strategy.winRate / 100.0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate) ?? endDate

            let result = BacktestResult(
                id: UUID().uuidString,
                strategyId: strategy.id,
                strategyName: strategy.name,
                startDate: dateFormatter.string(from: startDate),
                endDate: dateFormatter.string(from: endDate),
                totalReturn: variation(strategy.annualReturn),
                maxDrawdown: variation(strategy.maxDrawdown),
                sharpeRatio: variation(strategy.sharpeRatio),
                winRate: variation(strategy.winRate),
                totalTrades: strategy.totalTrades,
                profitTrades: profitTrades,
                annualizedReturn: variation(strategy.annualReturn)
            )

            self.backtestResult = result
            self.isLoading = false
        }
    }

    /// Create a custom strategy (VIP-only feature).
    func createCustomStrategy(name: String, description: String) -> Strategy {
        let id = "custom_\(UUID().uuidString.prefix(8))"
        let strategy = Strategy(
            id: id,
            name: name,
            description: description,
            winRate: 0,
            maxDrawdown: 0,
            sharpeRatio: 0,
            annualReturn: 0,
            totalTrades: 0,
            profitFactor: 0,
            isVip: true,
            tags: ["自定义"]
        )
        strategies.append(strategy)
        return strategy
    }
}
