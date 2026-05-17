import SwiftUI

struct VipPlanCard: View {
    let tierName: String
    let tierSubtitle: String
    let borderColor: Color
    let accentColor: Color
    let plans: [VipPlan]
    var viewModel: VipViewModel

    @State private var selectedPlanId: String = ""

    private var selectedPlan: VipPlan? {
        plans.first { $0.id == selectedPlanId } ?? plans.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tierHeader
            planListSection
            Divider().foregroundColor(.appDivider).padding(.horizontal, 18)
            featuresSection
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: borderColor.opacity(0.1), radius: 6, y: 3)
        )
        .onAppear {
            if selectedPlanId.isEmpty, let first = plans.first {
                selectedPlanId = first.id
                viewModel.selectPlan(id: first.id)
            }
        }
    }

    // MARK: - Subviews

    private var tierHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tierName)
                    .font(.title3.bold())
                    .foregroundColor(accentColor)
                Text(tierSubtitle)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()

            if tierName == "高级会员" {
                Text("推荐")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.vipGold))
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var planListSection: some View {
        VStack(spacing: 8) {
            ForEach(plans) { plan in
                Button {
                    selectedPlanId = plan.id
                    viewModel.selectPlan(id: plan.id)
                } label: {
                    planRow(plan)
                }
                .buttonStyle(.plain)

                if plan.id != plans.last?.id {
                    Divider()
                        .foregroundColor(.appDivider)
                        .padding(.leading, 18)
                }
            }
        }
        .padding(.bottom, 14)
    }

    private func planRow(_ plan: VipPlan) -> some View {
        let isSelected = selectedPlan.map { $0.id == plan.id } ?? false
        return HStack {
            ZStack {
                Circle()
                    .stroke(isSelected ? accentColor : Color.appDivider, lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Circle().fill(accentColor).frame(width: 10, height: 10)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(plan.duration + "付")
                    .font(.subheadline)
                    .foregroundColor(.appTextPrimary)
                Text("¥\(String(format: "%.0f", plan.price))/\(plan.duration)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Text("¥\(String(format: "%.0f", plan.price))")
                .font(.title3.bold())
                .foregroundColor(accentColor)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? accentColor.opacity(0.06) : Color.clear)
        )
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("包含功能")
                .font(.subheadline.bold())
                .foregroundColor(.appTextPrimary)
                .padding(.top, 14)
                .padding(.horizontal, 18)

            if let features = selectedPlan?.features {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(accentColor)
                            .padding(.top, 1)
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.appTextPrimary)
                    }
                    .padding(.horizontal, 18)
                }
            }

            Button {
                viewModel.purchase()
            } label: {
                Text("立即开通")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 10).fill(accentColor))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VipPlanCard(
            tierName: "普通会员",
            tierSubtitle: "适合个人投资者",
            borderColor: .vipSilver,
            accentColor: .vipSilver,
            plans: [
                VipPlan(id: "n1", name: "月度", price: 39, duration: "月", features: ["基础指标", "复盘数据"]),
                VipPlan(id: "n2", name: "季度", price: 99, duration: "季", features: ["基础指标", "复盘数据"]),
                VipPlan(id: "n3", name: "年度", price: 299, duration: "年", features: ["基础指标", "复盘数据"])
            ],
            viewModel: VipViewModel()
        )
    }
    .padding()
    .background(Color.appBackground)
}
