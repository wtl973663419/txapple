import SwiftUI

struct SectorStrengthView: View {
    let sectors: [SectorStrength]

    var body: some View {
        if sectors.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.appTextHint)
                Text("暂无板块强度数据")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
            .listRowBackground(Color.clear)
        } else {
            ForEach(Array(sectors.enumerated()), id: \.element.id) { index, sector in
                SectorStrengthRow(sector: sector, rank: index + 1)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
    }
}

#Preview {
    List {
        SectorStrengthView(sectors: ReviewViewModel.mockSectorStrength)
    }
    .listStyle(.plain)
}
