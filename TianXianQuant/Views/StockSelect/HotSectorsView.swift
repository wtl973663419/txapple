import SwiftUI

struct HotSectorsView: View {
    let sectors: [SectorInfo]
    var onRefresh: (() async -> Void)?

    @State private var expandedSector: String?

    var body: some View {
        Group {
            if sectors.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                    Text("暂无板块数据")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(sectors) { sector in
                    VStack(spacing: 0) {
                        // Sector header
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedSector == sector.id {
                                    expandedSector = nil
                                } else {
                                    expandedSector = sector.id
                                }
                            }
                        } label: {
                            sectorHeader(sector)
                        }
                        .buttonStyle(.plain)

                        // Leading stocks (expandable)
                        if expandedSector == sector.id {
                            leadingStocksList(sector.leadingStocks)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                    .padding(.horizontal, 0)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    // MARK: - Sector Header

    private func sectorHeader(_ sector: SectorInfo) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(sector.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                HStack(spacing: 8) {
                    Text("领涨: \(sector.leadingStock)")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                    if sector.capitalFlow != 0 {
                        Text(String(format: "资金: %+.2f亿", sector.capitalFlow))
                            .font(.system(size: 11))
                            .foregroundColor(sector.capitalFlow > 0 ? .appStockUp : .appStockDown)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(sector.changePercent.percentString)
                    .font(.system(size: 16, weight: .semibold))
                    .stockColor(sector.changePercent >= 0)

                Image(systemName: expandedSector == sector.id ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.appTextHint)
            }
        }
        .padding(12)
    }

    // MARK: - Leading Stocks

    private func leadingStocksList(_ stocks: [StockInfo]) -> some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 12)

            ForEach(stocks) { stock in
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.3))
                        .frame(width: 6, height: 6)
                    Text(stock.name)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Text(stock.price.priceString)
                        .font(.system(size: 13, weight: .medium))
                        .stockColor(stock.isUp)
                    Text(stock.changePercent.percentString)
                        .font(.system(size: 12))
                        .stockColor(stock.isUp)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    List {
        HotSectorsView(sectors: StockSelectViewModel.mockHotSectors)
    }
}
