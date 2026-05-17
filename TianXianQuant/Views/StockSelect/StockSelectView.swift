import SwiftUI

struct StockSelectView: View {
    @State private var viewModel = StockSelectViewModel()
    @State private var showSearch = false

    private let categories = ["选股", "涨幅榜", "跌幅榜", "热门板块", "龙虎榜"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                categoryPicker

                // Search Bar (only for stock search tab)
                if viewModel.selectedCategory == "选股" {
                    searchBar
                }

                // Content
                contentList
            }
            .background(Color.appBackground)
            .navigationTitle("选股")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadAllData()
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.filterByCategory(category)
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedCategory == category ? Color.appPrimary : Color.white)
                            )
                            .foregroundColor(viewModel.selectedCategory == category ? .white : .appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.appTextHint)

            TextField("输入代码或名称搜索", text: $viewModel.searchText)
                .font(.system(size: 14))
                .onChange(of: viewModel.searchText) { _, newValue in
                    viewModel.searchStocks(keyword: newValue)
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.stocks = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextHint)
                }
            }
        }
        .padding(10)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentList: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView("加载中...")
                .frame(maxWidth: .infinity)
            Spacer()
        } else {
            List {
                switch viewModel.selectedCategory {
                case "选股":
                    StockListView(stocks: viewModel.stocks)

                case "涨幅榜":
                    TopGainersView(stocks: viewModel.topGainers)

                case "跌幅榜":
                    TopLosersView(stocks: viewModel.topLosers)

                case "热门板块":
                    HotSectorsView(sectors: viewModel.hotSectors)

                case "龙虎榜":
                    DragonTigerView(stocks: viewModel.dragonTigerStocks)

                default:
                    StockListView(stocks: viewModel.stocks)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.loadAllData()
            }
        }
    }
}

#Preview {
    StockSelectView()
}
