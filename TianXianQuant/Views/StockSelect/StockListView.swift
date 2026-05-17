import SwiftUI

struct StockListView: View {
    let stocks: [StockInfo]
    var onRefresh: (() async -> Void)?

    @State private var selectedStock: StockInfo?
    @State private var showDetail = false

    var body: some View {
        Group {
            if stocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                    Text("输入代码或名称搜索股票")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(stocks) { stock in
                    Button {
                        selectedStock = stock
                        showDetail = true
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
        StockListView(stocks: StockSelectViewModel.mockStocks)
    }
}
