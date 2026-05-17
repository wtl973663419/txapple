import SwiftUI

struct DragonTigerView: View {
    let stocks: [DragonTigerStock]
    var onRefresh: (() async -> Void)?

    @State private var selectedStock: DragonTigerStock?

    var body: some View {
        Group {
            if stocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "flame")
                        .font(.system(size: 40))
                        .foregroundColor(.appWarning)
                    Text("暂无龙虎榜数据")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(stocks) { stock in
                    Button {
                        selectedStock = stock
                    } label: {
                        dragonTigerRow(stock)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $selectedStock) { stock in
            DragonTigerDetailSheet(stock: stock)
        }
    }

    // MARK: - Row

    private func dragonTigerRow(_ stock: DragonTigerStock) -> some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Left info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(stock.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appTextPrimary)
                        Text(stock.code)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextHint)
                    }
                    Text(stock.changePercent.percentString)
                        .font(.system(size: 14, weight: .semibold))
                        .stockColor(stock.changePercent >= 0)
                }

                Spacer()

                // Right info
                VStack(alignment: .trailing, spacing: 4) {
                    Text(stock.price.priceString)
                        .font(.system(size: 16, weight: .semibold))
                        .stockColor(stock.changePercent >= 0)

                    Text(String(format: "净流入: %+.2f亿", stock.netInflow / 1_0000_0000))
                        .font(.system(size: 11))
                        .foregroundColor(stock.netInflow > 0 ? .appStockUp : .appStockDown)
                }
            }

            // Reason chip
            HStack {
                Text(stock.reason)
                    .font(.system(size: 11))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)

                Spacer()

                HStack(spacing: 4) {
                    Label("买\(stock.buySeats)", systemImage: "arrow.up")
                        .font(.system(size: 10))
                        .foregroundColor(.appStockUp)
                    Label("卖\(stock.sellSeats)", systemImage: "arrow.down")
                        .font(.system(size: 10))
                        .foregroundColor(.appStockDown)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}

#Preview {
    List {
        DragonTigerView(stocks: StockSelectViewModel.mockDragonTiger)
    }
}
