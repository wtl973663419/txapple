import SwiftUI

struct StockRow: View {
    let stock: StockInfo

    var body: some View {
        HStack(spacing: 12) {
            // Left: Name + Code
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                Text(stock.code)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextHint)
            }

            Spacer()

            // Right: Price + Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.price.priceString)
                    .font(.system(size: 16, weight: .semibold))
                    .stockColor(stock.isUp)

                Text(stock.changePercent.percentString)
                    .font(.system(size: 13, weight: .medium))
                    .stockColor(stock.isUp)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        StockRow(stock: StockInfo(code: "600519", name: "贵州茅台", price: 1680.50, changePercent: 1.25, volume: 3_200_000))
        StockRow(stock: StockInfo(code: "300750", name: "宁德时代", price: 210.30, changePercent: -0.85, volume: 28_000_000))
    }
}
