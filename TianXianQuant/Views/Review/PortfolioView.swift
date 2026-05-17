import SwiftUI

struct PortfolioView: View {
    @Bindable var viewModel: PortfolioViewModel
    @State private var showAddSheet = false
    @State private var editingStock: PortfolioStock?

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            summaryHeader

            // Stock rows
            if viewModel.stocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "briefcase")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                    Text("暂无持仓")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    Button("添加持仓") {
                        showAddSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.stocks) { stock in
                    PortfolioStockRow(
                        stock: stock,
                        onDelete: { viewModel.delete(id: stock.id) },
                        onTap: { editingStock = stock }
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .sheet(isPresented: $showAddSheet) {
            AddPortfolioSheet { stock in
                viewModel.add(stock: stock)
            }
        }
        .sheet(item: $editingStock) { stock in
            AddPortfolioSheet { updated in
                viewModel.add(stock: updated)
            }
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        VStack(spacing: 12) {
            // Total capital & P&L
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总资产")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextHint)
                    Text(String(format: "%.2f", viewModel.totalMarketValue))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("总盈亏")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextHint)
                    HStack(spacing: 4) {
                        Text(String(format: "%+.2f", viewModel.totalProfit))
                            .font(.system(size: 16, weight: .semibold))
                            .stockColor(viewModel.totalProfit >= 0)
                        Text(viewModel.totalProfitPercent.percentString)
                            .font(.system(size: 14, weight: .medium))
                            .stockColor(viewModel.totalProfitPercent >= 0)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    showAddSheet = true
                } label: {
                    Label("添加", systemImage: "plus")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button {
                    Task { await viewModel.refreshPrices() }
                } label: {
                    Label(viewModel.isRefreshing ? "刷新中..." : "刷新价格", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.appBackgroundSecondary)
                        .foregroundColor(.appPrimary)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isRefreshing)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    let vm = PortfolioViewModel()
    let _ = vm.load()
    return List {
        PortfolioView(viewModel: vm)
    }
    .listStyle(.plain)
}
