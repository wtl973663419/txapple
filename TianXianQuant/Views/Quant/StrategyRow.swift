import SwiftUI

// MARK: - Strategy Row Card

struct StrategyRow: View {
    let strategy: Strategy
    let isVip: Bool
    let onTap: () -> Void
    let onBacktest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title row
            HStack(spacing: 8) {
                Text(strategy.name)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                if strategy.isVip {
                    Text("VIP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.vipGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .strokeBorder(Color.vipGold, lineWidth: 1)
                        )
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            .contentShape(Rectangle())

            // Description
            Text(strategy.description)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)

            // Metrics chips
            HStack(spacing: 8) {
                metricChip(
                    label: "胜率",
                    value: String(format: "%.0f%%", strategy.winRate),
                    color: .green
                )
                metricChip(
                    label: "最大回撤",
                    value: String(format: "%.1f%%", strategy.maxDrawdown),
                    color: .red
                )
                metricChip(
                    label: "夏普",
                    value: String(format: "%.2f", strategy.sharpeRatio),
                    color: .blue
                )
            }

            // Tags
            if !strategy.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(strategy.tags, id: \.self) { tag in
                        Text(tag)
                            .chipStyle(color: .appChipBlue)
                            .foregroundColor(.appPrimary)
                    }
                }
            }

            // Backtest button
            HStack {
                Spacer()
                Button {
                    onBacktest()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                        Text(strategy.isVip && !isVip ? "回测 (需VIP)" : "回测")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(strategy.isVip && !isVip ? Color.gray : Color.appPrimary)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .cardStyle()
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Metric Chip

    private func metricChip(label: String, value: String, color: ChipColor) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.swiftUIColor)
                .frame(width: 6, height: 6)
            Text("\(label) \(value)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
    }
}

// MARK: - Chip Color Enum

private enum ChipColor {
    case green, red, blue

    var swiftUIColor: Color {
        switch self {
        case .green: return .appStockDown
        case .red: return .appStockUp
        case .blue: return .appPrimary
        }
    }
}
