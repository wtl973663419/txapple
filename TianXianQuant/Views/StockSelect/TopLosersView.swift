import SwiftUI

struct TopLosersView: View {
    let stocks: [StockInfo]
    var onRefresh: (() async -> Void)?

    @State private var selectedStock: StockInfo?

    var body: some View {
        Group {
            if stocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 40))
                        .foregroundColor(.appStockDown)
                    Text("暂无跌幅数据")
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
        TopLosersView(stocks: StockSelectViewModel.mockTopLosers)
    }
}
