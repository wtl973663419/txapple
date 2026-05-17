import SwiftUI

struct PlanListView: View {
    @Bindable var viewModel: PlanViewModel
    @State private var showAddSheet = false
    @State private var editingPlan: PlanItem?

    var body: some View {
        VStack(spacing: 0) {
            // Add button header
            addButtonHeader

            if viewModel.allPlans.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextHint)
                    Text("暂无交易计划")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    Text("点击上方按钮添加计划")
                        .font(.caption)
                        .foregroundColor(.appTextHint)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
                .listRowBackground(Color.clear)
            } else {
                // Watch section
                if !viewModel.watchPlans.isEmpty {
                    planSection(title: "自选", type: .watch, plans: viewModel.watchPlans)
                }

                // Buy section
                if !viewModel.buyPlans.isEmpty {
                    planSection(title: "买入", type: .buy, plans: viewModel.buyPlans)
                }

                // Sell section
                if !viewModel.sellPlans.isEmpty {
                    planSection(title: "卖出", type: .sell, plans: viewModel.sellPlans)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .sheet(isPresented: $showAddSheet) {
            AddPlanSheet { plan in
                viewModel.add(plan: plan)
            }
        }
        .sheet(item: $editingPlan) { plan in
            AddPlanSheet(
                onSave: { updated in
                    viewModel.update(plan: updated)
                },
                editingPlan: plan
            )
        }
    }

    // MARK: - Add Button Header

    private var addButtonHeader: some View {
        HStack {
            Text("交易计划")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            Spacer()

            Button {
                showAddSheet = true
            } label: {
                Label("添加", systemImage: "plus")
                    .font(.system(size: 13))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
    }

    // MARK: - Section

    private func planSection(title: String, type: PlanType, plans: [PlanItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack(spacing: 8) {
                Circle()
                    .fill(sectionColor(for: type))
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                Text("(\(plans.count))")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextHint)
            }
            .padding(.horizontal, 16)

            // Plan rows
            ForEach(plans) { plan in
                PlanRow(
                    plan: plan,
                    onToggleDone: { viewModel.toggleDone(id: plan.id) },
                    onToggleAlert: { viewModel.toggleAlert(planId: plan.id) },
                    onDelete: { viewModel.delete(id: plan.id) },
                    onEdit: { editingPlan = plan }
                )
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }

    private func sectionColor(for type: PlanType) -> Color {
        switch type {
        case .watch: return Color(hex: "#1976D2")
        case .buy: return Color(hex: "#C0392B")
        case .sell: return Color(hex: "#27AE60")
        }
    }
}

#Preview {
    let vm = PlanViewModel()
    let _ = vm.load()
    return List {
        PlanListView(viewModel: vm)
    }
    .listStyle(.plain)
}
