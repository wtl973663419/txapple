import SwiftUI

struct LimitUpStocksView: View {
    let stocks: [LimitUpStock]
    @State private var selectedBoard = "全部"

    private let boardFilters = ["全部", "首板", "2板", "3板+"]

    var body: some View {
        VStack(spacing: 0) {
            // Board filter chips
            boardFilterRow

            // Stock list
            if filteredStocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                    Text("暂无涨停数据")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredStocks) { stock in
                    LimitUpStockRow(stock: stock)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var filteredStocks: [LimitUpStock] {
        if selectedBoard == "全部" { return stocks }
        return stocks.filter { $0.boardCategory == selectedBoard }
    }

    private var boardFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(boardFilters, id: \.self) { board in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedBoard = board
                        }
                    } label: {
                        Text(board == "全部" ? "全部(\(stocks.count))" : board)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedBoard == board ? Color.appPrimary : Color.white)
                            )
                            .foregroundColor(selectedBoard == board ? .white : .appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }
}

#Preview {
    List {
        LimitUpStocksView(stocks: ReviewViewModel.mockLimitUpStocks)
    }
    .listStyle(.plain)
}
