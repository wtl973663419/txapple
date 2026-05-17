import SwiftUI

struct AddPortfolioSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (PortfolioStock) -> Void

    @State private var code = ""
    @State private var name = ""
    @State private var countText = ""
    @State private var costText = ""
    @State private var currentPriceText = ""
    @State private var feeRateText = "0.03"
    @State private var capitalText = ""

    private let stockNameMap: [String: String] = [
        "000001": "平安银行", "000002": "万科A", "000858": "五粮液",
        "002415": "海康威视", "300750": "宁德时代", "600519": "贵州茅台",
        "600036": "招商银行", "601318": "中国平安", "000725": "京东方A",
        "002594": "比亚迪", "300059": "东方财富", "688981": "中芯国际",
        "600030": "中信证券", "000651": "格力电器", "002475": "立讯精密",
        "300124": "汇川技术", "600887": "伊利股份", "601012": "隆基绿能",
        "002230": "科大讯飞", "300274": "阳光电源", "688111": "金山办公",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("股票代码", text: $code)
                        .keyboardType(.asciiCapable)
                        .onChange(of: code) { _, newValue in
                            autoFillName()
                        }

                    TextField("股票名称", text: $name)

                    TextField("持有数量", text: $countText)
                        .keyboardType(.decimalPad)
                }

                Section("价格信息") {
                    TextField("成本价", text: $costText)
                        .keyboardType(.decimalPad)

                    TextField("当前价", text: $currentPriceText)
                        .keyboardType(.decimalPad)

                    TextField("手续费率(%)", text: $feeRateText)
                        .keyboardType(.decimalPad)
                }

                Section("资金信息") {
                    TextField("投入本金", text: $capitalText)
                        .keyboardType(.decimalPad)

                    Button("自动计算本金") {
                        calculateCapital()
                    }
                    .foregroundColor(.appPrimary)
                }

                Section {
                    Button(action: savePortfolio) {
                        HStack {
                            Spacer()
                            Text("保存")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("添加持仓")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private var isValid: Bool {
        !code.trimmingCharacters(in: .whitespaces).isEmpty &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(countText) ?? 0) > 0 &&
        (Double(costText) ?? 0) > 0 &&
        (Double(currentPriceText) ?? 0) > 0
    }

    private func autoFillName() {
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        if let mappedName = stockNameMap[trimmedCode] {
            name = mappedName
        }
    }

    private func calculateCapital() {
        guard let count = Double(countText),
              let cost = Double(costText) else { return }
        let feeRate = (Double(feeRateText) ?? 0.03) / 100.0
        let capital = count * cost * (1.0 + feeRate)
        capitalText = String(format: "%.2f", capital)
    }

    private func savePortfolio() {
        guard let count = Double(countText),
              let cost = Double(costText),
              let currentPrice = Double(currentPriceText) else { return }

        let feeRate = (Double(feeRateText) ?? 0.03) / 100.0
        let capital = Double(capitalText) ?? (count * cost * (1.0 + feeRate))

        let stock = PortfolioStock(
            id: UUID().uuidString,
            code: code.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces),
            count: count,
            cost: cost,
            currentPrice: currentPrice,
            feeRate: feeRate,
            capital: capital,
            positionRatio: 0
        )

        onSave(stock)
        dismiss()
    }
}

#Preview {
    AddPortfolioSheet { _ in }
}
