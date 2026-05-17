import SwiftUI

// MARK: - Strategy Detail View

struct StrategyDetailView: View {
    let strategy: Strategy
    let viewModel: QuantViewModel
    let isVip: Bool

    @State private var showBacktestResult = false
    @State private var isRunning = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Strategy header card
                    headerCard

                    // Metrics grid
                    metricsGrid

                    // Tags
                    tagsSection

                    // Description
                    descriptionSection

                    // Backtest section
                    backtestSection

                    // Backtest result
                    if let result = viewModel.backtestResult, showBacktestResult {
                        BacktestResultView(result: result)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle(strategy.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.backtestResult != nil {
                showBacktestResult = true
            }
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            isRunning = newValue
            if !newValue {
                withAnimation {
                    showBacktestResult = viewModel.backtestResult != nil
                }
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(strategy.name)
                    .font(.title2.bold())
                    .foregroundColor(.appTextPrimary)

                HStack(spacing: 8) {
                    if strategy.isVip {
                        Text("VIP专属")
                            .font(.caption.bold())
                            .foregroundColor(.vipGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.vipGold.opacity(0.15))
                            )
                    }
                    Text("年化 \(String(format: "%.1f", strategy.annualReturn))%")
                        .font(.subheadline)
                        .foregroundColor(.appStockDown)
                }
            }
            Spacer()
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        VStack(spacing: 12) {
            Text("策略指标")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                metricCell(title: "胜率", value: String(format: "%.0f%%", strategy.winRate), icon: "target")
                metricCell(title: "最大回撤", value: String(format: "%.1f%%", strategy.maxDrawdown), icon: "arrow.down")
                metricCell(title: "夏普比率", value: String(format: "%.2f", strategy.sharpeRatio), icon: "chart.bar")
                metricCell(title: "年化收益", value: String(format: "%.1f%%", strategy.annualReturn), icon: "chart.line.uptrend.xyaxis")
                metricCell(title: "总交易", value: "\(strategy.totalTrades)笔", icon: "arrow.left.arrow.right")
                metricCell(title: "盈亏比", value: String(format: "%.2f", strategy.profitFactor), icon: "scalemass")
            }
        }
    }

    private func metricCell(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appPrimary)
            Text(value)
                .font(.body.bold())
                .foregroundColor(.appTextPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        HStack(spacing: 8) {
            Text("策略标签")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            ForEach(strategy.tags, id: \.self) { tag in
                Text(tag)
                    .chipStyle(color: .appChipBlue)
                    .foregroundColor(.appPrimary)
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("策略说明")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text(strategy.description)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Backtest Section

    private var backtestSection: some View {
        VStack(spacing: 12) {
            if strategy.isVip && !isVip {
                // VIP-gated
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.vipGold)
                    Text("开通VIP会员即可使用策略回测功能")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .cardStyle()
            } else {
                Button {
                    viewModel.runBacktest(strategyId: strategy.id)
                } label: {
                    HStack(spacing: 8) {
                        if isRunning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(isRunning ? "正在回测..." : "开始回测")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isRunning ? Color.gray : Color.appPrimary)
                    )
                }
                .disabled(isRunning)
            }
        }
    }
}
