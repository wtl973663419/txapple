import SwiftUI

struct AddPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (PlanItem) -> Void

    var editingPlan: PlanItem?

    @State private var code = ""
    @State private var name = ""
    @State private var selectedType: PlanType = .watch
    @State private var entryPriceText = ""
    @State private var stopLossPriceText = ""
    @State private var takeProfitPriceText = ""
    @State private var exitPriceText = ""
    @State private var reason = ""
    @State private var priority = 1
    @State private var alertEnabled = true

    private let stockNameMap: [String: String] = [
        "000001": "平安银行", "000002": "万科A", "000858": "五粮液",
        "002415": "海康威视", "300750": "宁德时代", "600519": "贵州茅台",
        "600036": "招商银行", "601318": "中国平安", "000725": "京东方A",
        "002594": "比亚迪", "300059": "东方财富", "688981": "中芯国际",
        "600030": "中信证券", "000651": "格力电器", "002475": "立讯精密",
        "300124": "汇川技术", "600887": "伊利股份", "601012": "隆基绿能",
        "002230": "科大讯飞", "300274": "阳光电源", "688111": "金山办公",
        "600809": "山西汾酒", "000568": "泸州老窖", "002142": "宁波银行",
        "300015": "爱尔眼科", "601888": "中国中免", "600030": "中信证券",
    ]

    init(onSave: @escaping (PlanItem) -> Void, editingPlan: PlanItem? = nil) {
        self.onSave = onSave
        self.editingPlan = editingPlan

        if let plan = editingPlan {
            _code = State(initialValue: plan.code)
            _name = State(initialValue: plan.name)
            _selectedType = State(initialValue: plan.type)
            _entryPriceText = State(initialValue: plan.entryPrice > 0 ? plan.entryPrice.priceString : "")
            _stopLossPriceText = State(initialValue: plan.stopLossPrice > 0 ? plan.stopLossPrice.priceString : "")
            _takeProfitPriceText = State(initialValue: plan.takeProfitPrice > 0 ? plan.takeProfitPrice.priceString : "")
            _exitPriceText = State(initialValue: plan.exitPrice > 0 ? plan.exitPrice.priceString : "")
            _reason = State(initialValue: plan.reason)
            _priority = State(initialValue: plan.priority)
            _alertEnabled = State(initialValue: plan.alertEnabled)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("股票信息") {
                    TextField("股票代码", text: $code)
                        .keyboardType(.asciiCapable)
                        .onChange(of: code) { _, newValue in
                            autoFillName()
                        }

                    TextField("股票名称", text: $name)
                }

                Section("计划类型") {
                    Picker("类型", selection: $selectedType) {
                        ForEach(PlanType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("价格设定") {
                    if selectedType == .buy {
                        TextField("入场价格", text: $entryPriceText)
                            .keyboardType(.decimalPad)
                        TextField("止损价格", text: $stopLossPriceText)
                            .keyboardType(.decimalPad)
                        TextField("止盈价格", text: $takeProfitPriceText)
                            .keyboardType(.decimalPad)
                    } else if selectedType == .sell {
                        TextField("出场价格", text: $exitPriceText)
                            .keyboardType(.decimalPad)
                    } else {
                        TextField("目标入场价", text: $entryPriceText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        Text("低").tag(1)
                        Text("中").tag(2)
                        Text("高").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section("通知") {
                    Toggle("价格预警", isOn: $alertEnabled)
                }

                Section("备注") {
                    TextEditor(text: $reason)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if reason.isEmpty {
                                Text("输入计划备注...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextHint)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                Section {
                    Button(action: savePlan) {
                        HStack {
                            Spacer()
                            Text(editingPlan != nil ? "更新" : "保存")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle(editingPlan != nil ? "编辑计划" : "添加计划")
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
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func autoFillName() {
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        if let mappedName = stockNameMap[trimmedCode] {
            name = mappedName
        }
    }

    private func savePlan() {
        let plan = PlanItem(
            id: editingPlan?.id ?? UUID().uuidString,
            code: code.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces),
            type: selectedType,
            entryPrice: Double(entryPriceText) ?? 0,
            stopLossPrice: Double(stopLossPriceText) ?? 0,
            takeProfitPrice: Double(takeProfitPriceText) ?? 0,
            exitPrice: Double(exitPriceText) ?? 0,
            reason: reason.trimmingCharacters(in: .whitespaces),
            priority: priority,
            isDone: editingPlan?.isDone ?? false,
            alertEnabled: alertEnabled
        )

        onSave(plan)
        dismiss()
    }
}

#Preview {
    AddPlanSheet { _ in }
}
