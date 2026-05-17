import SwiftUI

struct LimitUpStockRow: View {
    let stock: LimitUpStock

    var body: some View {
        VStack(spacing: 10) {
            // Top row: name, code, price, days
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(stock.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appTextPrimary)
                        Text(stock.code)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextHint)
                    }

                    Text(stock.price.priceString)
                        .font(.system(size: 16, weight: .semibold))
                        .stockColor(true)
                }

                Spacer()

                // Continuous days chip
                Text(stock.boardCategory)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(daysColor(stock.continuousDays))
                    )
            }

            // Middle: time + industry
            HStack(spacing: 8) {
                Label(stock.limitUpTime, systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(.appTextSecondary)

                if !stock.industry.isEmpty {
                    Text(stock.industry)
                        .font(.system(size: 11))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.appChipBlue.opacity(0.5))
                        )
                }

                Spacer()

                Text(String(format: "封单: %.0f万", stock.sealAmount / 1_0000))
                    .font(.system(size: 11))
                    .foregroundColor(.appTextHint)
            }

            // Seal status
            if stock.isOpened {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.appWarning)
                    Text("炸板 \(stock.openCount)次")
                        .font(.system(size: 11))
                        .foregroundColor(.appWarning)
                }
            }

            // Reason chips
            if !stock.reasonTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(stock.reasonTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10))
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.appChipBlue)
                            )
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private func daysColor(_ days: Int) -> Color {
        if days >= 5 { return Color(hex: "#E91E63") }
        if days >= 3 { return .appWarning }
        if days >= 2 { return .appPrimary }
        return Color(hex: "#78909C")
    }
}

#Preview {
    VStack(spacing: 8) {
        LimitUpStockRow(stock: ReviewViewModel.mockLimitUpStocks[0])
        LimitUpStockRow(stock: ReviewViewModel.mockLimitUpStocks[2])
    }
    .padding()
    .background(Color.appBackground)
}
