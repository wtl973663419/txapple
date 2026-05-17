import SwiftUI

struct MarketOverviewView: View {
    let marketOverview: [MarketOverview]
    let sentiment: MarketSentiment?
    let yesterdayPerf: YesterdayLimitUpPerformance?

    private let mainIndices = ["000001", "399001", "399006", "000688"]

    var body: some View {
        VStack(spacing: 16) {
            // Index Cards
            indexCardsSection

            // Market Sentiment
            if let sentiment = sentiment {
                sentimentSection(sentiment)
            }

            // Yesterday Limit-up Performance
            if let perf = yesterdayPerf {
                yesterdayLimitUpSection(perf)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    // MARK: - Index Cards

    private var indexCardsSection: some View {
        VStack(spacing: 8) {
            Text("主要指数")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(marketOverview.filter { mainIndices.contains($0.indexCode) }) { index in
                    indexCard(index)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func indexCard(_ index: MarketOverview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(index.indexName)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)

            Text(index.price.priceString)
                .font(.system(size: 18, weight: .bold))
                .stockColor(index.isUp)

            HStack(spacing: 6) {
                Text(String(format: "%+.2f", index.changePoint))
                    .font(.system(size: 12))
                    .stockColor(index.isUp)

                Text(index.changePercent.percentString)
                    .font(.system(size: 12, weight: .medium))
                    .stockColor(index.isUp)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    // MARK: - Sentiment

    private func sentimentSection(_ sentiment: MarketSentiment) -> some View {
        VStack(spacing: 12) {
            Text("市场情绪")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Sentiment score bar
            sentimentBar(sentiment)

            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                sentimentStat(label: "上涨", value: "\(sentiment.upCount)", color: .appStockUp)
                sentimentStat(label: "平盘", value: "\(sentiment.flatCount)", color: .appTextSecondary)
                sentimentStat(label: "下跌", value: "\(sentiment.downCount)", color: .appStockDown)
                sentimentStat(label: "涨停", value: "\(sentiment.limitUpCount)", color: .appStockUp)
                sentimentStat(label: "跌停", value: "\(sentiment.limitDownCount)", color: .appStockDown)
                sentimentStat(label: "成交额", value: String(format: "%.0f亿", sentiment.totalAmount / 1_0000_0000), color: .appTextPrimary)
            }

            // North-bound flow
            HStack {
                Text("北向资金")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text(String(format: "%+.2f亿", sentiment.northNetInflow / 1_0000_0000))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(sentiment.northNetInflow >= 0 ? .appStockUp : .appStockDown)
            }
            .padding(10)
            .background(Color.appBackgroundSecondary)
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        .padding(.horizontal, 16)
    }

    private func sentimentBar(_ sentiment: MarketSentiment) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text("情绪指数")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)

                Spacer()

                Text("\(sentiment.sentimentScore)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(sentimentColor(sentiment.sentimentScore))

                Text(sentiment.sentimentLevel)
                    .font(.system(size: 12))
                    .foregroundColor(sentimentColor(sentiment.sentimentScore))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(sentimentColor(sentiment.sentimentScore).opacity(0.15))
                    )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appDivider)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(sentimentColor(sentiment.sentimentScore))
                        .frame(width: geo.size.width * CGFloat(sentiment.sentimentScore) / 100.0, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func sentimentColor(_ score: Int) -> Color {
        if score >= 70 { return .appStockUp }
        if score >= 40 { return .appWarning }
        return .appStockDown
    }

    private func sentimentStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(8)
    }

    // MARK: - Yesterday Limit-up Performance

    private func yesterdayLimitUpSection(_ perf: YesterdayLimitUpPerformance) -> some View {
        VStack(spacing: 12) {
            Text("昨日涨停表现")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                // Red rate
                VStack(spacing: 4) {
                    Text("\(perf.totalCount)只")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                    Text("涨停总数")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 30)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", perf.redRate))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appStockUp)
                    Text("红盘率")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 30)

                VStack(spacing: 4) {
                    Text(perf.avgChange.percentString)
                        .font(.system(size: 13, weight: .medium))
                        .stockColor(perf.avgChange >= 0)
                    Text("平均涨幅")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 30)

                VStack(spacing: 4) {
                    Text("\(perf.continueLimitUpCount)只")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appStockUp)
                    Text("继续涨停")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextHint)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        .padding(.horizontal, 16)
    }
}

#Preview {
    List {
        MarketOverviewView(
            marketOverview: ReviewViewModel.mockMarketOverview,
            sentiment: ReviewViewModel.mockMarketSentiment,
            yesterdayPerf: ReviewViewModel.mockYesterdayLimitUpPerf
        )
    }
}
