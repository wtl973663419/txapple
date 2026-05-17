import SwiftUI

struct DragonTigerDetailSheet: View {
    let stock: DragonTigerStock
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    // Buy/Sell seats
                    seatsSection

                    // Net inflow bar
                    netInflowSection

                    // OHLC
                    ohlcSection

                    // Valuation
                    valuationSection
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle(stock.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(stock.code)
                .font(.caption)
                .foregroundColor(.appTextHint)

            Text(stock.price.priceString)
                .font(.system(size: 36, weight: .bold))
                .stockColor(stock.changePercent >= 0)

            HStack(spacing: 8) {
                Text(stock.changePercent.percentString)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(stock.changePercent >= 0 ? Color.appChipRed.opacity(0.2) : Color.appChipGreen.opacity(0.2))
                    )
                    .foregroundColor(stock.changePercent >= 0 ? .appStockUp : .appStockDown)
            }

            Text(stock.reason)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Seats

    private var seatsSection: some View {
        VStack(spacing: 12) {
            Text("龙虎榜席位")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Buy side
                VStack(spacing: 6) {
                    Text("\(stock.buySeats)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appStockUp)
                    Text("买入席位")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextHint)

                    if stock.buyAmount > 0 {
                        Text(String(format: "%.2f亿", stock.buyAmount / 1_0000_0000))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appStockUp)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appChipRed.opacity(0.15))
                .cornerRadius(10)

                // Sell side
                VStack(spacing: 6) {
                    Text("\(stock.sellSeats)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appStockDown)
                    Text("卖出席位")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextHint)

                    if stock.sellAmount > 0 {
                        Text(String(format: "%.2f亿", stock.sellAmount / 1_0000_0000))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appStockDown)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appChipGreen.opacity(0.15))
                .cornerRadius(10)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Net Inflow

    private var netInflowSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("净流入")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text(String(format: "%+.2f亿", stock.netInflow / 1_0000_0000))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(stock.netInflow > 0 ? .appStockUp : .appStockDown)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appDivider)
                        .frame(height: 8)

                    let total = stock.buyAmount + max(stock.sellAmount, 0.01)
                    let buyRatio = stock.buyAmount / total
                    let sellRatio = stock.sellAmount / total
                    let barWidth = max(geo.size.width * buyRatio, 0)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(stock.netInflow > 0 ? Color.appStockUp : Color.appStockDown)
                        .frame(width: barWidth, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text(String(format: "买: %.2f亿", stock.buyAmount / 1_0000_0000))
                    .font(.system(size: 10))
                    .foregroundColor(.appTextHint)
                Spacer()
                Text(String(format: "卖: %.2f亿", stock.sellAmount / 1_0000_0000))
                    .font(.system(size: 10))
                    .foregroundColor(.appTextHint)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - OHLC

    private var ohlcSection: some View {
        VStack(spacing: 0) {
            Text("OHLC 数据")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ohlcCell(label: "开盘", value: stock.open.priceString)
                ohlcCell(label: "昨收", value: stock.yesterdayClose.priceString)
                ohlcCell(label: "最高", value: stock.high.priceString)
                ohlcCell(label: "最低", value: stock.low.priceString)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func ohlcCell(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.appTextHint)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.appTextPrimary)
        }
        .padding(10)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(8)
    }

    // MARK: - Valuation

    private var valuationSection: some View {
        VStack(spacing: 8) {
            Text("估值指标")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                metricCell(label: "市盈率(PE)", value: stock.pe > 0 ? String(format: "%.2f", stock.pe) : "--")
                metricCell(label: "市净率(PB)", value: stock.pb > 0 ? String(format: "%.2f", stock.pb) : "--")
                metricCell(label: "换手率", value: stock.turnover > 0 ? String(format: "%.2f%%", stock.turnover) : "--")
                metricCell(label: "总市值", value: stock.marketCap > 0 ? String(format: "%.0f亿", stock.marketCap / 1_0000_0000) : "--")
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func metricCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextHint)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(8)
    }
}

#Preview {
    DragonTigerDetailSheet(stock: StockSelectViewModel.mockDragonTiger.first!)
}
