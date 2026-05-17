import SwiftUI

struct VipView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = VipViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.vipGold)
                            Text("天线量化VIP")
                                .font(.title2.bold())
                                .foregroundColor(.appTextPrimary)
                        }

                        Text("解锁更多量化分析功能，提升投资决策效率")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                    // VIP status card
                    if appState.isVip {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(.vipGold)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("您已是VIP会员")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.vipGold)
                                Text("享受全部VIP专属功能")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.vipGold.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.vipGold.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)
                    }

                    // Tier cards
                    // Normal tier card
                    let normalPlans = viewModel.normalPlans
                    if !normalPlans.isEmpty {
                        VipPlanCard(
                            tierName: "普通会员",
                            tierSubtitle: "适合个人投资者，性价比之选",
                            borderColor: .vipSilver,
                            accentColor: .vipSilver,
                            plans: normalPlans,
                            viewModel: viewModel
                        )
                        .padding(.horizontal, 16)
                    }

                    // Senior tier card
                    if let senior = viewModel.seniorPlan {
                        VipPlanCard(
                            tierName: "高级会员",
                            tierSubtitle: "适合专业投资者，策略更丰富",
                            borderColor: .vipGold,
                            accentColor: .vipGold,
                            plans: [senior],
                            viewModel: viewModel
                        )
                        .padding(.horizontal, 16)
                    }

                    // Custom tier card
                    if let custom = viewModel.customPlan {
                        VipPlanCard(
                            tierName: "定制会员",
                            tierSubtitle: "适合机构用户，专属定制服务",
                            borderColor: .vipDiamond,
                            accentColor: .vipDiamond,
                            plans: [custom],
                            viewModel: viewModel
                        )
                        .padding(.horizontal, 16)
                    }

                    // Add-on section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("增值服务")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)

                        VStack(spacing: 0) {
                            AddOnRow(icon: "chart.line.uptrend.xyaxis", title: "量化策略回测报告", price: "¥19.9/次", description: "详细的策略回测分析报告")
                            Divider().foregroundColor(.appDivider).padding(.leading, 48)
                            AddOnRow(icon: "doc.text.magnifyingglass", title: "个股深度分析", price: "¥9.9/次", description: "基本面+技术面综合深度报告")
                            Divider().foregroundColor(.appDivider).padding(.leading, 48)
                            AddOnRow(icon: "person.text.rectangle", title: "一对一投资咨询", price: "¥199/时", description: "专业投资顾问一对一服务")
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                        )
                    }
                    .padding(.horizontal, 16)

                    // Customer service section
                    VStack(spacing: 10) {
                        Text("客服支持")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)

                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.subheadline)
                                .foregroundColor(.appStockDown)
                            Text("微信客服：")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                            Text("gutong_vip")
                                .font(.subheadline.bold())
                                .foregroundColor(.appPrimary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                        )
                        .padding(.horizontal, 16)

                        Text("工作时间：周一至周五 9:00-18:00")
                            .font(.caption)
                            .foregroundColor(.appTextHint)
                    }
                    .padding(.bottom, 10)

                    // Disclaimer
                    Text("VIP会员服务由天线量化提供，最终解释权归本公司所有。支付功能即将上线，当前可通过微信客服开通。")
                        .font(.caption2)
                        .foregroundColor(.appTextHint)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 30)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("VIP会员")
            .navigationBarTitleDisplayMode(.inline)
            .alert("支付功能开发中", isPresented: $viewModel.showPurchaseAlert) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(viewModel.purchaseAlertMessage)
            }
            .task {
                viewModel.loadPlans()
            }
        }
    }
}

struct AddOnRow: View {
    let icon: String
    let title: String
    let price: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appPrimary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appPrimaryLight)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.appTextPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Text(price)
                .font(.subheadline.bold())
                .foregroundColor(.appPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    VipView()
        .environment(AppState())
}
