import SwiftUI

// MARK: - Backtest Result View

struct BacktestResultView: View {
    let result: BacktestResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                Text("回测结果")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Spacer()
                Text("\(result.startDate) ~ \(result.endDate)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            // Summary bar
            summaryBar

            // Detailed metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                resultMetricCell(
                    title: "总收益率",
                    value: String(format: "%+.2f%%", result.totalReturn),
                    isPositive: result.totalReturn >= 0
                )
                resultMetricCell(
                    title: "最大回撤",
                    value: String(format: "%.2f%%", result.maxDrawdown),
                    isPositive: false
                )
                resultMetricCell(
                    title: "夏普比率",
                    value: String(format: "%.2f", result.sharpeRatio),
                    isPositive: result.sharpeRatio >= 1
                )
                resultMetricCell(
                    title: "胜率",
                    value: String(format: "%.1f%%", result.winRate),
                    isPositive: result.winRate >= 50
                )
                resultMetricCell(
                    title: "总交易",
                    value: "\(result.totalTrades)笔",
                    isPositive: true
                )
                resultMetricCell(
                    title: "盈利交易",
                    value: "\(result.profitTrades)笔",
                    isPositive: true
                )
                resultMetricCell(
                    title: "年化收益",
                    value: String(format: "%.2f%%", result.annualizedReturn),
                    isPositive: result.annualizedReturn >= 0
                )
            }

            // Win rate visual
            winRateVisual
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Summary Bar

    private var summaryBar: some View {
        HStack(spacing: 0) {
            let winWidth = result.winRate / 100.0
            let lossWidth = 1.0 - winWidth

            Rectangle()
                .fill(Color.appStockDown)
                .frame(width: UIScreen.main.bounds.width * 0.4 * winWidth, height: 8)

            Rectangle()
                .fill(Color.appStockUp)
                .frame(width: UIScreen.main.bounds.width * 0.4 * lossWidth, height: 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Metric Cell

    private func resultMetricCell(title: String, value: String, isPositive: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.body.bold())
                .foregroundColor(isPositive ? .appStockDown : .appStockUp)
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appBackground)
        )
    }

    // MARK: - Win Rate Visual

    private var winRateVisual: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Circle().fill(Color.appStockDown).frame(width: 8, height: 8)
                    Text("盈利 \(result.profitTrades)笔")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.appStockUp).frame(width: 8, height: 8)
                    Text("亏损 \(result.totalTrades - result.profitTrades)笔")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            Spacer()
            Text("胜率 \(String(format: "%.1f", result.winRate))%")
                .font(.subheadline.bold())
                .foregroundColor(result.winRate >= 50 ? .appStockDown : .appStockUp)
        }
    }
}
