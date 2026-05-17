import SwiftUI
import Observation

@Observable
final class PlanViewModel {
    var watchPlans: [PlanItem] = []
    var buyPlans: [PlanItem] = []
    var sellPlans: [PlanItem] = []

    private let storageKey = "plan_items"

    // MARK: - Persistence

    func load() {
        if let saved: [PlanItem] = UserDefaultsManager.shared.loadCodable([PlanItem].self, forKey: storageKey) {
            watchPlans = saved.filter { $0.type == .watch }
            buyPlans = saved.filter { $0.type == .buy }
            sellPlans = saved.filter { $0.type == .sell }
        } else {
            watchPlans = Self.mockWatchPlans
            buyPlans = Self.mockBuyPlans
            sellPlans = Self.mockSellPlans
        }
    }

    func save() {
        let allPlans = watchPlans + buyPlans + sellPlans
        UserDefaultsManager.shared.saveCodable(allPlans, forKey: storageKey)
    }

    // MARK: - CRUD

    func add(plan: PlanItem) {
        var newPlan = plan
        if newPlan.id.isEmpty {
            newPlan = PlanItem(
                id: UUID().uuidString,
                code: plan.code,
                name: plan.name,
                type: plan.type,
                entryPrice: plan.entryPrice,
                stopLossPrice: plan.stopLossPrice,
                takeProfitPrice: plan.takeProfitPrice,
                exitPrice: plan.exitPrice,
                reason: plan.reason,
                priority: plan.priority,
                isDone: plan.isDone,
                alertEnabled: plan.alertEnabled
            )
        }
        switch newPlan.type {
        case .watch: watchPlans.append(newPlan)
        case .buy: buyPlans.append(newPlan)
        case .sell: sellPlans.append(newPlan)
        }
        save()
    }

    func update(plan: PlanItem) {
        delete(id: plan.id)
        switch plan.type {
        case .watch: watchPlans.append(plan)
        case .buy: buyPlans.append(plan)
        case .sell: sellPlans.append(plan)
        }
        save()
    }

    func delete(id: String) {
        watchPlans.removeAll { $0.id == id }
        buyPlans.removeAll { $0.id == id }
        sellPlans.removeAll { $0.id == id }
        save()
    }

    func toggleDone(id: String) {
        if let index = watchPlans.firstIndex(where: { $0.id == id }) {
            watchPlans[index].isDone.toggle()
        } else if let index = buyPlans.firstIndex(where: { $0.id == id }) {
            buyPlans[index].isDone.toggle()
        } else if let index = sellPlans.firstIndex(where: { $0.id == id }) {
            sellPlans[index].isDone.toggle()
        }
        save()
    }

    func toggleAlert(planId: String) {
        if let index = watchPlans.firstIndex(where: { $0.id == planId }) {
            watchPlans[index].alertEnabled.toggle()
        } else if let index = buyPlans.firstIndex(where: { $0.id == planId }) {
            buyPlans[index].alertEnabled.toggle()
        } else if let index = sellPlans.firstIndex(where: { $0.id == planId }) {
            sellPlans[index].alertEnabled.toggle()
        }
        save()
    }

    func plans(for type: PlanType) -> [PlanItem] {
        switch type {
        case .watch: return watchPlans
        case .buy: return buyPlans
        case .sell: return sellPlans
        }
    }

    var allPlans: [PlanItem] {
        watchPlans + buyPlans + sellPlans
    }

    // MARK: - Mock Data

    static let mockWatchPlans: [PlanItem] = [
        PlanItem(id: "w1", code: "600519", name: "贵州茅台", type: .watch, entryPrice: 1620, stopLossPrice: 1580, takeProfitPrice: 1750, exitPrice: 0, reason: "白酒龙头，等待回调到60日均线", priority: 3, isDone: false, alertEnabled: true),
        PlanItem(id: "w2", code: "300750", name: "宁德时代", type: .watch, entryPrice: 200, stopLossPrice: 190, takeProfitPrice: 230, exitPrice: 0, reason: "新能源龙头，底部盘整中", priority: 2, isDone: false, alertEnabled: true),
    ]

    static let mockBuyPlans: [PlanItem] = [
        PlanItem(id: "b1", code: "688981", name: "中芯国际", type: .buy, entryPrice: 55.0, stopLossPrice: 50.0, takeProfitPrice: 68.0, exitPrice: 0, reason: "国产替代逻辑，放量突破", priority: 3, isDone: false, alertEnabled: true),
        PlanItem(id: "b2", code: "002415", name: "海康威视", type: .buy, entryPrice: 32.0, stopLossPrice: 30.0, takeProfitPrice: 38.0, exitPrice: 0, reason: "AI+安防双驱动，估值合理", priority: 2, isDone: false, alertEnabled: false),
    ]

    static let mockSellPlans: [PlanItem] = [
        PlanItem(id: "s1", code: "300274", name: "阳光电源", type: .sell, entryPrice: 85.0, stopLossPrice: 0, takeProfitPrice: 0, exitPrice: 98.0, reason: "涨停后分批止盈", priority: 2, isDone: false, alertEnabled: true),
    ]
}
