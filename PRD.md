# 天线量化 (TianXianQuant) - 产品需求文档 (PRD)

## 产品概述

天线量化是一款面向A股散户投资者的iOS股票分析应用。产品整合行情数据、量化策略、社区交流、AI算命（股半仙Bot）等模块，为中小投资者提供一站式决策辅助工具。后端服务基于cpolar内网穿透技术，使用轻量级API架构。

### 产品定位
- **中文名称**：天线量化
- **英文名称**：TianXianQuant
- **目标平台**：iOS 17.0+
- **技术栈**：SwiftUI + MVVM (@Observable) + URLSession
- **后端技术**：Python/Node.js + SQLite，通过cpolar暴露为HTTPS API

---

## 目标用户

| 用户画像 | 特征 | 核心需求 |
|---------|------|---------|
| 散户新手 | 入市时间短，缺乏选股经验 | 热门板块追踪、涨停分析、简单量化信号 |
| 进阶投资者 | 有一定的技术分析基础 | 量化策略回测、自选股管理、价格预警 |
| 社交型投资者 | 喜欢交流讨论 | 社区发帖、评论互动、股半仙AI聊天 |
| 娱乐型用户 | 对AI算命/八卦感兴趣 | 八字分析、五行择股、趣味性交互 |

---

## 功能清单 (MoSCoW)

### Must Have (必须有 - v1.0)

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 用户认证 | 用户名+密码登录/注册，Token持久化，自动重登录 | P0 |
| 市场概览 | 主要指数（上证、深成指、创业板）实时行情 | P0 |
| 股票搜索 | 按代码/名称搜索，显示实时行情 | P0 |
| 热门板块 | 行业板块涨跌幅排行，龙头股展示 | P0 |
| 涨停分析 | 当日涨停股票列表，连板统计 | P0 |
| 龙虎榜 | 龙虎榜席位买卖数据 | P0 |
| 自选股管理 | 添加/删除自选，价格提醒 | P0 |

### Should Have (应该有 - v1.1)

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 社区模块 | 发帖、评论、点赞、分类浏览 | P1 |
| 量化策略 | 预置策略展示（均线突破、MACD金叉等），胜率/回撤指标 | P1 |
| 股半仙Bot | AI算命聊天：八字分析、五行择股、趣味问答 | P1 |
| 个股详情 | 实时行情、深度分析（护城河、行业地位等） | P1 |
| 交易计划 | 买入/卖出/自选计划管理，价格止损止盈 | P1 |

### Could Have (可以有 - v1.2)

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 价格预警 | 后台定时轮询，触发目标价格推送通知 | P2 |
| 回测模拟 | 量化策略历史回测，收益曲线展示 | P2 |
| VIP会员 | 付费会员体系（VIP徽章、专属策略、优先响应） | P2 |
| 社交功能 | 好友添加、私聊、朋友圈 | P2 |
| 资产组合 | 模拟持仓管理，盈亏计算 | P2 |

### Won't Have (暂不做 - v1.x)

| 功能 | 说明 | 原因 |
|------|------|------|
| 实盘交易 | 对接券商交易接口 | 监管合规风险，v1.x暂不考虑 |
| 支付集成 | 微信/支付宝支付 | 苹果内购审核周期长，v1.2手动开通VIP |
| APNs远程推送 | 远程推送通知 | 需要自建推送服务，暂用本地通知替代 |

---

## 用户流程

### 1. 新手引导流程
```
启动App -> 启动屏（验证Token） -> 登录/注册页 -> 输入用户名密码
  -> 首次登录自动注册 -> 进入主界面（选股Tab） -> 浏览行情 -> 搜索股票
```

### 2. 日常使用流程
```
打开App -> 查看市场概览 -> 浏览热门板块 -> 搜索目标股票
  -> 添加自选/制定交易计划 -> 查看量化策略 -> 社区发帖交流
```

### 3. 社交互动流程
```
社区Tab -> 浏览帖子（按最新/热门排序） -> 点击帖子查看详情
  -> 评论/点赞 -> 关注作者 -> 发起私聊 -> 股半仙Bot聊天
```

### 4. VIP升级流程
```
我的Tab -> 查看VIP状态 -> 点击VIP升级 -> 选择套餐 -> 联系客服开通
  -> VIP徽章显示 -> 解锁专属策略 -> 解锁更多AI对话次数
```

---

## 技术需求

### 系统要求
- **最低iOS版本**：iOS 17.0
- **开发语言**：Swift 5.10+
- **UI框架**：SwiftUI
- **架构模式**：MVVM + @Observable
- **网络层**：URLSession (自定义APIClient)
- **数据持久化**：Keychain (敏感数据) + UserDefaults (偏好设置) + 文件系统 (聊天记录)
- **最低Xcode版本**：Xcode 16

### 依赖管理
- **无第三方依赖**：纯Swift原生实现，无需CocoaPods/SPM/Carthage
- **系统框架**：SwiftUI, Foundation, Security, UserNotifications, BackgroundTasks

### 后端API
- **基础架构**：Python/Node.js REST API + cpolar内网穿透
- **认证方式**：Bearer Token，服务端生成，客户端Keychain存储
- **数据格式**：JSON
- **API版本**：v1 (无显式版本号)

---

## 安全要求

| 安全措施 | 实现方式 |
|---------|---------|
| 密码存储 | 仅存储在Keychain (kSecClassGenericPassword)，禁止存储于UserDefaults |
| Token管理 | Bearer Token存储在Keychain，每次认证请求附带 |
| API密钥 | 通过.xcconfig文件注入，排除在Git版本控制外 |
| 网络传输 | 仅使用HTTPS (cpolar提供TLS证书) |
| 敏感端点保护 | 所有认证后的端点需携带有效Token，401自动踢出 |
| 代码混淆 | 不做（iOS App Store自动加密） |

---

## 发布计划

### v1.0 (MVP - 基础行情)
- 市场概览、股票搜索、热门板块
- 涨停分析、龙虎榜
- 用户认证、自选股管理
- 预计上线：内部测试

### v1.1 (社交与策略)
- 社区模块（发帖、评论、点赞）
- 量化策略展示
- 股半仙Bot AI聊天
- 个股详情与深度分析
- 交易计划管理
- 预计上线：v1.0后4周

### v1.2 (高级功能)
- 价格预警与本地通知
- VIP会员体系
- 好友与私聊
- 资产组合管理
- 预计上线：v1.1后6周

### v1.3 (优化与扩展)
- 策略回测模拟
- 性能优化（缓存、预加载）
- UI/UX精调
- 国际化（简体中文、繁体中文）
- 预计上线：v1.2后8周

---

## 已知风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| cpolar隧道稳定性 | 后端不可达导致App无法使用 | 本地缓存Mock数据，网络异常时自动降级 |
| 苹果审核风险 | 八字算命/股半仙Bot可能被判定为"迷信"内容 | 使用"AI趣味分析"表述，避免"算命""风水"等敏感词；准备备用审核页 |
| 数据源限制 | 行情数据依赖于后端数据源 | 显示数据来源标注，保留免责声明 |
| 单人开发效率 | 功能迭代速度慢 | MoSCoW优先级严格排期，核心功能优先 |
| Keychain跨设备 | 不同设备无法同步Token | 用户在新设备需重新登录（v1.x接受此限制） |

---

## 附录

### 文件结构
```
TianXianQuant/
├── App/
│   ├── AppState.swift
│   └── TianXianQuantApp.swift
├── Core/
│   ├── Components/
│   │   ├── AsyncImageView.swift
│   │   ├── LoadingOverlay.swift
│   │   └── VIPBadge.swift
│   ├── Configuration/
│   │   └── APIConfig.swift
│   ├── Extensions/
│   │   ├── Color+Theme.swift
│   │   └── String+Validation.swift
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   ├── APIRouter.swift
│   │   ├── NetworkError.swift
│   │   └── ResponseWrapper.swift
│   └── Storage/
│       ├── ChatStorage.swift
│       ├── KeychainManager.swift
│       └── UserDefaultsManager.swift
├── Models/
│   ├── ChatModels.swift
│   ├── LimitUpModels.swift
│   ├── PlanItem.swift
│   └── StockInfo.swift
├── Resources/
│   ├── char_wuxing.json
│   └── stock_list.json
├── Services/
│   ├── BackgroundTaskManager.swift
│   ├── PriceAlertService.swift
│   └── UpdateChecker.swift
├── ViewModels/
└── Views/
    ├── Community/
    ├── Profile/
    ├── Quant/
    ├── Review/
    ├── StockSelect/
    ├── Teatime/GuBanXianBot/
    ├── Update/
    ├── VIP/
    ├── MainTabView.swift
    └── SplashView.swift
```

### 术语表

| 术语 | 说明 |
|------|------|
| A股 | 中国内地股票市场（上海证券交易所 + 深圳证券交易所） |
| 涨停 | 当日涨幅达到10%（主板）/ 20%（科创/创业板）上限 |
| 龙虎榜 | 每日涨跌幅偏离值达到7%的股票，披露买卖席位信息 |
| 板块 | 行业板块或概念板块，如"新能源汽车""半导体" |
| 连板 | 连续多个交易日涨停 |
| VIP | 付费会员，享受专属功能和优先服务 |
| 股半仙 | AI聊天机器人，结合八字五行进行趣味性股票分析 |
| 止盈 | 达到预期收益目标后卖出 |
| 止损 | 达到预定价位后强制卖出以控制亏损 |
