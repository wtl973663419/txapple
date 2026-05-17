import SwiftUI

struct PlanRow: View {
    let plan: PlanItem
    var onToggleDone: (() -> Void)?
    var onToggleAlert: (() -> Void)?
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            // Header: name + type chip + priority
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(plan.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appTextPrimary)
                            .strikethrough(plan.isDone)

                        typeChip
                    }

                    if !plan.reason.isEmpty {
                        Text(plan.reason)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Priority indicator
                HStack(spacing: 2) {
                    ForEach(0..<max(plan.priority, 1), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.appWarning)
                    }
                }
            }

            // Price chips
            if plan.entryPrice > 0 || plan.stopLossPrice > 0 || plan.takeProfitPrice > 0 || plan.exitPrice > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        if plan.entryPrice > 0 {
                            priceChip(label: "入场", value: plan.entryPrice.priceString, color: .appPrimary)
                        }
                        if plan.stopLossPrice > 0 {
                            priceChip(label: "止损", value: plan.stopLossPrice.priceString, color: .appStockDown)
                        }
                        if plan.takeProfitPrice > 0 {
                            priceChip(label: "止盈", value: plan.takeProfitPrice.priceString, color: .appStockUp)
                        }
                        if plan.exitPrice > 0 {
                            priceChip(label: "出场", value: plan.exitPrice.priceString, color: .appWarning)
                        }
                    }
                }
            }

            // Action row
            HStack {
                // Done toggle
                Button {
                    onToggleDone?()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: plan.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(plan.isDone ? .appStockDown : .appTextHint)
                        Text(plan.isDone ? "已完成" : "未完成")
                            .font(.system(size: 12))
                            .foregroundColor(plan.isDone ? .appStockDown : .appTextHint)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // Alert toggle
                Button {
                    onToggleAlert?()
                } label: {
                    Image(systemName: plan.alertEnabled ? "bell.fill" : "bell.slash")
                        .font(.system(size: 14))
                        .foregroundColor(plan.alertEnabled ? .appWarning : .appTextHint)
                }
                .buttonStyle(.plain)

                // Edit
                Button {
                    onEdit?()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextHint)
                }
                .buttonStyle(.plain)

                // Delete
                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextHint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(plan.isDone ? Color.appBackgroundSecondary : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private var typeChip: some View {
        Text(plan.type.displayName)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(typeColor)
            )
    }

    private var typeColor: Color {
        switch plan.type {
        case .watch: return Color(hex: "#1976D2")
        case .buy: return Color(hex: "#C0392B")
        case .sell: return Color(hex: "#27AE60")
        }
    }

    private func priceChip(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(color)
                )
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PlanRow(plan: PlanViewModel.mockBuyPlans[0])
        PlanRow(plan: PlanViewModel.mockWatchPlans[0])
        PlanRow(plan: PlanViewModel.mockSellPlans[0])
    }
    .padding()
    .background(Color.appBackground)
}
