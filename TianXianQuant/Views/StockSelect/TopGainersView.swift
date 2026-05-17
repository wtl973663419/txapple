import SwiftUI

struct TopGainersView: View {
    let stocks: [StockInfo]
    var onRefresh: (() async -> Void)?

    @State private var selectedStock: StockInfo?

    var body: some View {
        Group {
            if stocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 40))
                        .foregroundColor(.appStockUp)
                    Text("暂无涨幅数据")
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
                        StockRow(stock: stock)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $selectedStock) { stock in
            StockDetailSheet(stock: stock)
        }
    }
}

#Preview {
    List {
        TopGainersView(stocks: StockSelectViewModel.mockTopGainers)
    }
}
