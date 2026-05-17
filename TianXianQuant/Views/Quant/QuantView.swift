import SwiftUI

// MARK: - Quant Strategy List View

struct QuantView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = QuantViewModel()
    @State private var showCreateSheet = false
    @State private var refreshTrigger = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Strategy list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Pull-to-refresh indicator area
                            Color.clear.frame(height: 4)

                            ForEach(viewModel.strategies) { strategy in
                                StrategyRow(
                                    strategy: strategy,
                                    isVip: appState.isVip,
                                    onTap: {
                                        viewModel.selectStrategy(id: strategy.id)
                                    },
                                    onBacktest: {
                                        handleBacktest(strategy: strategy)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        // Simulate refresh
                        try? await Task.sleep(nanoseconds: 800_000_000)
                        viewModel.loadStrategies()
                        refreshTrigger += 1
                    }
                }

                // FAB - Create custom strategy
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showCreateSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.appPrimary)
                                        .shadow(color: .appPrimary.opacity(0.3), radius: 8, y: 4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateStrategySheet { name, desc in
                    viewModel.createCustomStrategy(name: name, description: desc)
                }
            }
            // NavigationLink for strategy detail
            .navigationDestination(item: $viewModel.selectedStrategy) { strategy in
                StrategyDetailView(strategy: strategy, viewModel: viewModel, isVip: appState.isVip)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("量化策略")
                        .font(.title.bold())
                        .foregroundColor(.appTextPrimary)
                    Text("共\(viewModel.strategies.count)个策略")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                if !appState.isVip {
                    Text("VIP")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.vipGold)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider()
                .background(Color.appDivider)
        }
    }

    // MARK: - Actions

    private func handleBacktest(strategy: Strategy) {
        if strategy.isVip && !appState.isVip {
            // VIP-gated: don't run, just select (detail view will show VIP prompt)
            viewModel.selectStrategy(id: strategy.id)
        } else {
            viewModel.selectStrategy(id: strategy.id)
            viewModel.runBacktest(strategyId: strategy.id)
        }
    }
}

// MARK: - NavigationDestination helper

extension Strategy: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Strategy, rhs: Strategy) -> Bool {
        lhs.id == rhs.id
    }
}
