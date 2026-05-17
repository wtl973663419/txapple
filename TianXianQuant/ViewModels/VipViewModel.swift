import SwiftUI
import Observation

@Observable
final class VipViewModel {
    var plans: [VipPlan] = []
    var selectedPlan: VipPlan?
    var showPurchaseAlert: Bool = false

    // Three tier groups
    enum VipTier: String {
        case normal = "普通会员"
        case senior = "高级会员"
        case custom = "定制会员"
    }

    func loadPlans() {
        plans = [
            // Normal tier - 3 billing periods
            VipPlan(
                id: "normal_monthly",
                name: "普通会员·月度",
                price: 39,
                duration: "月",
                features: [
                    "基础技术指标(MACD/KDJ/RSI)",
                    "每日复盘数据",
                    "自选股列表(上限20只)",
                    "社区发帖与评论",
                    "基础龙虎榜数据",
                    "个股基本面概览"
                ]
            ),
            VipPlan(
                id: "normal_quarterly",
                name: "普通会员·季度",
                price: 99,
                duration: "季",
                features: [
                    "基础技术指标(MACD/KDJ/RSI)",
                    "每日复盘数据",
                    "自选股列表(上限20只)",
                    "社区发帖与评论",
                    "基础龙虎榜数据",
                    "个股基本面概览"
                ]
            ),
            VipPlan(
                id: "normal_yearly",
                name: "普通会员·年度",
                price: 299,
                duration: "年",
                features: [
                    "基础技术指标(MACD/KDJ/RSI)",
                    "每日复盘数据",
                    "自选股列表(上限20只)",
                    "社区发帖与评论",
                    "基础龙虎榜数据",
                    "个股基本面概览"
                ]
            ),
            // Senior tier
            VipPlan(
                id: "senior_yearly",
                name: "高级会员·年度",
                price: 599,
                duration: "年",
                features: [
                    "全部高级技术指标(含布林带/一目均衡)",
                    "实时龙虎榜追踪",
                    "量化策略回测引擎",
                    "自选股数量无上限",
                    "深度个股分析报告",
                    "机构调研纪要",
                    "VIP专属交流群",
                    "优先客服响应"
                ]
            ),
            // Custom tier - price range 1299-1999
            VipPlan(
                id: "custom_yearly",
                name: "定制会员·年度",
                price: 1299,
                duration: "年起",
                features: [
                    "所有高级会员功能",
                    "定制量化策略开发",
                    "专属投资顾问服务",
                    "API数据接口调用",
                    "无限次策略回测",
                    "一对一投资培训",
                    "定制化风险监控",
                    "优先获取新股信息",
                    "线下投资沙龙邀约"
                ]
            )
        ]
    }

    func selectPlan(id: String) {
        selectedPlan = plans.first { $0.id == id }
    }

    /// Returns plans grouped by tier for display
    var normalPlans: [VipPlan] {
        plans.filter { $0.id.starts(with: "normal_") }
    }

    var seniorPlan: VipPlan? {
        plans.first { $0.id == "senior_yearly" }
    }

    var customPlan: VipPlan? {
        plans.first { $0.id == "custom_yearly" }
    }

    /// Handle purchase action — shows alert for now
    func purchase() {
        showPurchaseAlert = true
    }

    var purchaseAlertMessage: String {
        "支付功能开发中，敬请期待！\n\n如需开通VIP，请联系客服微信：gutong_vip"
    }
}
