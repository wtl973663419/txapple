import SwiftUI

struct SectorStrengthRow: View {
    let sector: SectorStrength
    let rank: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Rank circle
                rankCircle

                // Sector info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sector.sector)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextPrimary)

                    HStack(spacing: 12) {
                        Label("\(sector.count)只", systemImage: "number")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextSecondary)

                        Label(String(format: "%.1f天", sector.avgDays), systemImage: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextSecondary)

                        Text("最高\(sector.maxDays)连板")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextHint)
                    }
                }

                Spacer()

                // Score
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", sector.score))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(scoreColor)

                    Text("分")
                        .font(.system(size: 10))
                        .foregroundColor(.appTextHint)
                }
            }

            // Representative stocks
            if !sector.stocks.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(sector.stocks) { stock in
                            HStack(spacing: 4) {
                                Text(stock.name)
                                    .font(.system(size: 11))
                                    .foregroundColor(.appTextPrimary)
                                Text(stock.pct.percentString)
                                    .font(.system(size: 11, weight: .medium))
                                    .stockColor(stock.pct >= 0)
                                if stock.days > 1 {
                                    Text("\(stock.days)板")
                                        .font(.system(size: 10))
                                        .foregroundColor(.appStockUp)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(
                                            Capsule()
                                                .fill(Color.appChipRed)
                                        )
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appBackgroundSecondary)
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    private var rankCircle: some View {
        ZStack {
            Circle()
                .fill(rankColor)
                .frame(width: 32, height: 32)

            Text("\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(rank <= 3 ? .white : .appTextPrimary)
        }
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "#E91E63")
        case 2: return Color(hex: "#FF6B35")
        case 3: return Color(hex: "#FFB800")
        default: return Color.appBackgroundSecondary
        }
    }

    private var scoreColor: Color {
        if sector.score >= 80 { return .appStockUp }
        if sector.score >= 60 { return .appWarning }
        return .appTextSecondary
    }
}

#Preview {
    VStack(spacing: 8) {
        SectorStrengthRow(sector: ReviewViewModel.mockSectorStrength[0], rank: 1)
        SectorStrengthRow(sector: ReviewViewModel.mockSectorStrength[2], rank: 3)
    }
    .padding()
    .background(Color.appBackground)
}
