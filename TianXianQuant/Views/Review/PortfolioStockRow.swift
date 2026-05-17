import SwiftUI

struct PortfolioStockRow: View {
    let stock: PortfolioStock
    var onDelete: (() -> Void)?
    var onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            // Header: name, code, delete
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stock.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                    Text(stock.code)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextHint)
                }

                Spacer()

                if let onDelete = onDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextHint)
                    }
                }
            }

            // Price row
            HStack {
                costLabel(title: "成本", value: stock.cost.priceString)
                Spacer()
                costLabel(title: "现价", value: stock.currentPrice.priceString)
                Spacer()
                costLabel(title: "数量", value: String(format: "%.0f", stock.count))
            }

            // Profit row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("盈亏")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                    Text(String(format: "%+.2f", stock.profit))
                        .font(.system(size: 14, weight: .semibold))
                        .stockColor(stock.profit >= 0)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("收益率")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                    Text(stock.profitPercent.percentString)
                        .font(.system(size: 14, weight: .semibold))
                        .stockColor(stock.profitPercent >= 0)
                }
            }

            // Bottom: capital, feeRate, position ratio
            HStack {
                Text("本金: \(String(format: "%.0f", stock.capital))")
                    .font(.system(size: 11))
                    .foregroundColor(.appTextHint)

                Spacer()

                Text(String(format: "费率: %.2f%%", stock.feeRate * 100))
                    .font(.system(size: 11))
                    .foregroundColor(.appTextHint)

                Spacer()

                Text(String(format: "仓位: %.1f%%", stock.positionRatio))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appPrimary)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private func costLabel(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.appTextHint)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PortfolioStockRow(stock: PortfolioViewModel.mockStocks[0])
        PortfolioStockRow(stock: PortfolioViewModel.mockStocks[1])
    }
    .padding()
    .background(Color.appBackground)
}
