# TianXianQuant iOS Migration — 开发计划 (TX-01 产出)

## 项目概述
- 总任务数：39 个 (5个Phase)
- 总文件数：86 个 Swift 文件 + 2 个数据文件 + 2 个测试文件
- 总大小：~1.1 MB 源代码
- 平台：iOS 17.0+ / SwiftUI / MVVM

## 任务列表

| 序号 | 任务ID | 标题 | 涉及模块 | 状态 |
|------|--------|------|----------|------|
| **Phase 1: 基础框架** |
| 1 | P1-01 | 项目结构 + 数据转换 | 全局 | ✅ |
| 2 | P1-02 | @main App 入口 + 认证状态路由 | App/ | ✅ |
| 3 | P1-03 | APIConfig 集中配置 (修复 bug #1,#2,#6) | Core/Configuration/ | ✅ |
| 4 | P1-04 | URLSession 网络层 + APIRouter 枚举 | Core/Networking/ | ✅ |
| 5 | P1-05 | KeychainManager + UserDefaultsManager (修复 bug #3) | Core/Storage/ | ✅ |
| 6 | P1-06 | Codable 数据模型 (12 个) | Models/ | ✅ |
| 7 | P1-07 | AuthViewModel + SplashView (修复 bug #4) | ViewModels/, Views/ | ✅ |
| 8 | P1-08 | MainTabView + Color+Theme + 5 Tab 骨架 | Views/ | ✅ |
| **Phase 2: 核心选股 + 复盘** |
| 9 | P2-01 | StockSelectViewModel | ViewModels/ | ✅ |
| 10 | P2-02 | StockSelectView + StockRow + 搜索 | Views/StockSelect/ | ✅ |
| 11 | P2-03 | StockDetailSheet (深度分析) | Views/StockSelect/ | ✅ |
| 12 | P2-04 | 涨幅榜/跌幅榜/板块/龙虎榜视图 | Views/StockSelect/ | ✅ |
| 13 | P2-05 | ReviewViewModel | ViewModels/ | ✅ |
| 14 | P2-06 | MarketOverviewView (大盘指数) | Views/Review/ | ✅ |
| 15 | P2-07 | LimitUpStocksView (连板票筛选) | Views/Review/ | ✅ |
| 16 | P2-08 | SectorStrengthView (板块强度) | Views/Review/ | ✅ |
| 17 | P2-09 | PortfolioViewModel + 持仓管理 | ViewModels/, Views/Review/ | ✅ |
| 18 | P2-10 | PlanViewModel + 交易计划 CRUD | ViewModels/, Views/Review/ | ✅ |
| **Phase 3: 社交 + VIP** |
| 19 | P3-01 | CommunityViewModel | ViewModels/ | ✅ |
| 20 | P3-02 | CommunityView + PostRow + PostDetail | Views/Community/ | ✅ |
| 21 | P3-03 | CreatePostSheet + CommentRow | Views/Community/ | ✅ |
| 22 | P3-04 | TeatimeViewModel + ChatStorage | ViewModels/, Core/Storage/ | ✅ |
| 23 | P3-05 | FriendListView + FriendRow + 请求 | Views/Teatime/ | ✅ |
| 24 | P3-06 | ConversationListView + ChatView + ChatBubble | Views/Teatime/ | ✅ |
| 25 | P3-07 | ProfileView + AvatarPicker + ChangePwd | Views/Profile/ | ✅ |
| 26 | P3-08 | VipView + VipPlanCard | Views/VIP/ | ✅ |
| **Phase 4: 量化 + 股半仙 AI** |
| 27 | P4-01 | QuantViewModel | ViewModels/ | ✅ |
| 28 | P4-02 | QuantView + StrategyRow + StrategyDetail | Views/Quant/ | ✅ |
| 29 | P4-03 | BacktestResultView + CreateStrategySheet | Views/Quant/ | ✅ |
| 30 | P4-04 | CharWuxingLoader + StockNameMap | Core/Data/ | ✅ |
| 31 | P4-05 | BaZiCalculator (八字算命) | Views/Teatime/GuBanXianBot/ | ✅ |
| 32 | P4-06 | QiMenDunJiaCalculator (奇门遁甲) | Views/Teatime/GuBanXianBot/ | ✅ |
| 33 | P4-07 | GuBanXianChatView + KeywordRouter + NameWuxingAnalyzer | Views/Teatime/GuBanXianBot/ | ✅ |
| **Phase 5: 打磨 + 文档** |
| 34 | P5-01 | PriceAlertService + BackgroundTaskManager | Services/ | ✅ |
| 35 | P5-02 | UpdateChecker | Services/ | ✅ |
| 36 | P5-03 | AsyncImageView + VIPBadge + LoadingOverlay | Core/Components/ | ✅ |
| 37 | P5-04 | String+Validation | Core/Extensions/ | ✅ |
| 38 | P5-05 | XCTest 单元测试 | TianXianQuantTests/ | ✅ |
| 39 | P5-06 | PRD.md + TOOLS_INSTALL_GUIDE.md | 根目录 | ✅ |

## 迭代统计
- 1次通过：39 个任务（全部一次性完成）
- 修正轮数：0
- 强制通过：0
