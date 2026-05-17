import SwiftUI

struct ReviewView: View {
    @State private var reviewVM = ReviewViewModel()
    @State private var portfolioVM = PortfolioViewModel()
    @State private var planVM = PlanViewModel()
    @State private var selectedTab = "市场概况"

    private let tabs = ["市场概况", "连板票", "板块强度", "持仓", "计划"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                tabPicker

                // Content
                tabContent
            }
            .background(Color.appBackground)
            .navigationTitle("复盘")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await reviewVM.loadAllData()
            portfolioVM.load()
            planVM.load()
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTab == tab ? Color.appPrimary : Color.white)
                            )
                            .foregroundColor(selectedTab == tab ? .white : .appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        if reviewVM.isLoading && selectedTab != "持仓" && selectedTab != "计划" {
            Spacer()
            ProgressView("加载中...")
                .frame(maxWidth: .infinity)
            Spacer()
        } else {
            List {
                switch selectedTab {
                case "市场概况":
                    MarketOverviewView(
                        marketOverview: reviewVM.marketOverview,
                        sentiment: reviewVM.marketSentiment,
                        yesterdayPerf: reviewVM.yesterdayLimitUpPerf
                    )
                case "连板票":
                    LimitUpStocksView(stocks: reviewVM.limitUpStocks)
                case "板块强度":
                    SectorStrengthView(sectors: reviewVM.sortedSectorStrength)
                case "持仓":
                    PortfolioView(viewModel: portfolioVM)
                case "计划":
                    PlanListView(viewModel: planVM)
                default:
                    EmptyView()
                }
            }
            .listStyle(.plain)
            .refreshable {
                if selectedTab == "持仓" {
                    await portfolioVM.refreshPrices()
                } else if selectedTab == "计划" {
                    planVM.load()
                } else {
                    await reviewVM.loadAllData()
                }
            }
        }
    }
}

#Preview {
    ReviewView()
}
