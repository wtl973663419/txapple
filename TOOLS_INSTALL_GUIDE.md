# 天线量化 (TianXianQuant) - 开发工具与安装指南

本指南帮助开发者快速搭建天线量化iOS应用的开发环境，并顺利在模拟器和真机上构建、运行项目。

---

## 目录

1. [必装软件](#1-必装软件)
2. [Apple开发者账号](#2-apple开发者账号)
3. [构建与运行](#3-构建与运行)
4. [命令行构建命令](#4-命令行构建命令)
5. [安装到iPhone](#5-安装到iphone)
6. [数据文件准备](#6-数据文件准备)
7. [环境变量配置](#7-环境变量配置)
8. [常见问题排查](#8-常见问题排查)
9. [如何创建Xcode工程文件](#9-如何创建xcode工程文件)

---

## 1. 必装软件

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| macOS | macOS 15 Sequoia 或更高 | 最新版macOS确保Xcode 16兼容性 |
| Xcode | Xcode 16.0+ | 需支持Swift 5.10+和iOS 17.0 SDK |
| iOS Simulator | iOS 17.0+ | Xcode自带，可在Xcode > Settings > Platforms中下载 |
| Git | 2.40+ | 版本控制（macOS自带，终端输入`git --version`检查） |

### 安装步骤

1. **安装Xcode**
   - 打开Mac App Store，搜索"Xcode"，点击"获取"安装
   - 或从 [Apple Developer Downloads](https://developer.apple.com/download/) 下载特定版本
   - 安装完成后，首次启动Xcode会提示安装额外组件，点击"Install"并输入密码

2. **安装Command Line Tools**（可选，命令行构建必需）
   ```bash
   xcode-select --install
   ```

3. **验证安装**
   ```bash
   xcodebuild -version
   # 输出示例: Xcode 16.0 Build version 16A242d

   swift --version
   # 输出示例: swift-driver version: 1.90.0 ...
   ```

---

## 2. Apple开发者账号

### 免费账号（仅模拟器）
- 使用普通Apple ID即可（在Xcode > Settings > Accounts中添加）
- **限制**：
  - 只能在模拟器上运行
  - 无法使用TestFlight分发
  - 无法使用APNs推送、iCloud等部分功能
- **适用场景**：本地开发调试、UI预览

### 付费账号 ($99/年)
- 在 [developer.apple.com](https://developer.apple.com/) 注册Apple Developer Program
- **权益**：
  - 真机调试（iPhone/iPad）
  - TestFlight内测分发（最多10,000名测试者）
  - App Store上架
  - 完整的Capabilities支持（APNs、iCloud等）

### 在Xcode中配置账号
1. 打开Xcode > Settings (Cmd+,) > Accounts
2. 点击左下角"+"，选择"Apple ID"，输入账号密码
3. 在Team下拉菜单中选择你的团队（Personal Team为免费账号）

---

## 3. 构建与运行

### 在模拟器中运行

1. **打开项目**
   - 在Finder中双击 `TianXianQuant.xcodeproj` 或在Xcode中 File > Open
   - 确保项目导航器中所有Swift文件都已添加到正确的Target

2. **选择模拟器**
   - 点击Xcode顶部工具栏左侧的Scheme选择器
   - 选择"TianXianQuant"
   - 点击右侧的设备选择器，选择模拟器（如 iPhone 16 Pro）

3. **运行**
   - 按 `Cmd+R` 或点击工具栏的播放按钮
   - 首次编译可能需要几分钟，后续增量编译会很快
   - 模拟器启动后App会自动安装并启动

4. **停止运行**
   - 按 `Cmd+.` 或点击工具栏的停止按钮

### 使用不同iOS版本模拟器
- Xcode > Settings > Platforms > 点击"+"下载其他版本的iOS Simulator
- 常用：iOS 17.0（最低支持版本）、iOS 18.x（最新版本）

---

## 4. 命令行构建命令

以下命令在项目根目录（包含 `.xcodeproj` 的目录）执行：

### 清理构建缓存
```bash
xcodebuild clean \
  -project TianXianQuant.xcodeproj \
  -scheme TianXianQuant
```

### 构建（仅编译，不运行）
```bash
xcodebuild build \
  -project TianXianQuant.xcodeproj \
  -scheme TianXianQuant \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug
```

### 运行单元测试
```bash
xcodebuild test \
  -project TianXianQuant.xcodeproj \
  -scheme TianXianQuant \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug
```

### 归档（用于分发）
```bash
xcodebuild archive \
  -project TianXianQuant.xcodeproj \
  -scheme TianXianQuant \
  -archivePath ./build/TianXianQuant.xcarchive \
  -configuration Release
```

### 导出IPA（从归档文件）
```bash
xcodebuild -exportArchive \
  -archivePath ./build/TianXianQuant.xcarchive \
  -exportPath ./build/ \
  -exportOptionsPlist ExportOptions.plist
```

> **注意**：`ExportOptions.plist` 需包含签名配置。最简单的方式是先在Xcode中Archive一次并导出，Xcode会生成对应的plist文件。

---

## 5. 安装到iPhone

### 方式A：通过Xcode直接安装（开发调试）

#### 免费账号（7天签名）
1. 用USB数据线连接iPhone到Mac
2. 在iPhone上信任此电脑（首次连接会弹窗）
3. 在Xcode顶部设备选择器中选择你的iPhone
4. 首次运行时，Xcode会提示签名配置：
   - 在项目导航器中选择项目根节点
   - 选择Target "TianXianQuant" > Signing & Capabilities
   - 勾选"Automatically manage signing"
   - Team选择你的Personal Team
   - Bundle Identifier改为唯一值（如 `com.yourname.TianXianQuant`）
5. 按 `Cmd+R` 构建并安装

**免费账号限制**：
- 应用签名有效期仅7天，过期后需重新安装
- 每个Bundle ID最多安装3个应用
- 每年最多注册10个Bundle ID

#### 付费账号
- 流程相同，但无7天限制
- 可在Signing & Capabilities中选择Distribution Provisioning Profile

### 方式B：通过TestFlight分发（内测）

1. **在App Store Connect创建App**
   - 登录 [App Store Connect](https://appstoreconnect.apple.com/)
   - 点击"我的App" > "+" > "新建App"
   - 填写App名称、Bundle ID、主要语言等

2. **上传构建版本**
   - 在Xcode中 Product > Archive
   - Organizer窗口打开后，选择刚生成的Archive
   - 点击"Distribute App" > "App Store Connect" > "Upload"
   - 等待上传完成

3. **配置TestFlight**
   - 在App Store Connect中进入App > TestFlight
   - 上传的构建版本需要等待审核（通常1-2天）
   - 审核通过后，在"内部测试"或"外部测试"中添加测试者

4. **测试者安装**
   - 测试者在iPhone上从App Store安装"TestFlight"应用
   - 接受邮件邀请或通过公开链接加入
   - 在TestFlight中下载安装天线量化

### 方式C：Ad-hoc分发（直接安装IPA）

1. **获取设备的UDID**
   - 将iPhone连接Mac，打开Finder，点击设备名称
   - 点击序列号区域直到显示UDID，右键拷贝

2. **注册设备到开发者账号**
   - 登录 [Apple Developer](https://developer.apple.com/account/resources/devices/)
   - 点击"+"添加设备，粘贴UDID

3. **创建Ad-hoc Provisioning Profile**
   - Certificates, Identifiers & Profiles > Profiles > "+"
   - 选择"Ad Hoc"类型
   - 选择对应的App ID和已注册的设备

4. **导出IPA**
   - Xcode Archive > Distribute App > Ad Hoc > 选择Profile
   - 导出IPA文件

5. **安装IPA到设备**
   - **Apple Configurator**（Mac App Store免费下载）：连接iPhone，拖入IPA
   - **第三方工具**：爱思助手、iMazing等

---

## 6. 数据文件准备

天线量化使用了两个预置JSON数据文件，它们需要被添加到Xcode工程中。

### 文件说明

| 文件 | 路径 | 用途 |
|------|------|------|
| `char_wuxing.json` | `TianXianQuant/Resources/` | 汉字五行属性映射表（股半仙Bot使用） |
| `stock_list.json` | `TianXianQuant/Resources/` | A股股票基本信息列表（搜索匹配使用） |

### 添加到Xcode工程

1. 在Xcode项目导航器中右键点击"TianXianQuant"组
2. 选择"Add Files to TianXianQuant..."
3. 导航到 `Resources/` 文件夹
4. 选择 `char_wuxing.json` 和 `stock_list.json`
5. 确保勾选"Copy items if needed"
6. "Add to targets"中勾选"TianXianQuant"
7. 点击"Add"

### 验证文件已打包

构建应用后，可通过以下代码验证文件是否在Bundle中：
```swift
if let path = Bundle.main.path(forResource: "stock_list", ofType: "json") {
    print("stock_list.json found at \(path)")
} else {
    print("stock_list.json NOT found - check Target Membership")
}
```

---

## 7. 环境变量配置

项目通过 `.xcconfig` 文件管理不同的构建配置（Debug/Release）。这些文件**不应提交到Git**，因为它们包含API密钥等敏感信息。

### 创建Debug.xcconfig

在 `Configuration/` 目录下创建 `Debug.xcconfig`：

```
// Debug.xcconfig
API_BASE_URL = https:/bec3168.r29.cpolar.top/api
API_KEY = txquant2025secret
BUNDLE_ID_PREFIX = com.yourname
```

### 创建Release.xcconfig

在 `Configuration/` 目录下创建 `Release.xcconfig`：

```
// Release.xcconfig
API_BASE_URL = https:/bec3168.r29.cpolar.top/api
API_KEY = txquant2025secret
BUNDLE_ID_PREFIX = com.yourname
```

### 配置Xcode使用.xcconfig

1. 在项目导航器中选择项目根节点
2. 选择Target "TianXianQuant" > Info > Configurations
3. Debug和Release分别选择对应的.xcconfig文件

### 在代码中读取

```swift
let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
```

### .gitignore配置

确保以下文件被Git忽略：
```
*.xcconfig
!Configuration/Example.xcconfig
*.xcuserdata
Pods/
build/
*.xcarchive
*.ipa
```

---

## 8. 常见问题排查

### 编译错误

| 错误信息 | 可能原因 | 解决方案 |
|---------|---------|---------|
| `No such module 'XCTest'` | 测试Target中Swift文件未添加 | 检查测试文件的Target Membership |
| `Cannot find 'AppState' in scope` | 文件未添加到Target | 在文件检查器中勾选Target |
| `Type 'AppState' does not conform to protocol 'ObservableObject'` | 使用了旧的@ObservableObject | 改为 `@Observable` (iOS 17+) |
| `Cannot assign to property: 'self' is immutable` | View中缺少@State/@Bindable | 给可变属性添加@State或使用@Bindable |

### 签名问题

| 错误信息 | 解决方案 |
|---------|---------|
| `Signing for "TianXianQuant" requires a development team` | 在Signing & Capabilities中选择Team |
| `Failed to register bundle identifier` | 修改Bundle Identifier为唯一值 |
| `No profiles for 'com.xxx.TianXianQuant' were found` | 勾选"Automatically manage signing"或手动下载Profile |
| `The app cannot be installed because its integrity could not be verified` | 免费账号签名的App每7天需重新安装 |

### 模拟器问题

| 问题 | 解决方案 |
|------|---------|
| 模拟器黑屏/卡住 | Device > Erase All Content and Settings 重置模拟器 |
| 模拟器无法启动 | Xcode > Settings > Platforms 删除并重新下载Simulator |
| 网络请求失败 | 模拟器使用Mac网络，确保Mac可以访问后端URL |
| 键盘无法弹出 | 模拟器菜单 I/O > Keyboard > Toggle Software Keyboard (Cmd+K) |

### 真机调试问题

| 问题 | 解决方案 |
|------|---------|
| iPhone未出现在设备列表 | 拔插USB线，确保iPhone已解锁并信任此电脑 |
| `Could not locate device support files` | 更新Xcode到最新版本 |
| `The developer disk image could not be mounted` | 重启iPhone和Mac |
| App安装后闪退 | 查看Xcode控制台日志，检查是否缺少数据文件或权限 |

### 网络调试

```bash
# 测试后端可达性（在Mac终端）
curl -X GET "https://bec3168.r29.cpolar.top/api/health"

# 测试搜索API
curl -X GET "https://bec3168.r29.cpolar.top/api/search?keyword=茅台" \
  -H "X-API-Key: txquant2025secret"

# 测试认证API
curl -X POST "https://bec3168.r29.cpolar.top/api/auth" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: txquant2025secret" \
  -d '{"username": "test", "password": "123456"}'
```

---

## 9. 如何创建Xcode工程文件

如果是从零开始创建项目（例如没有现成的 `.xcodeproj`），按以下步骤操作：

### 步骤1：创建新项目

1. 打开Xcode，选择 File > New > Project
2. 选择模板：iOS > App
3. 点击"Next"

### 步骤2：配置项目选项

| 选项 | 值 |
|------|-----|
| Product Name | TianXianQuant |
| Team | (选择你的Apple ID Team) |
| Organization Identifier | com.yourname (替换为你的标识符) |
| Interface | SwiftUI |
| Language | Swift |
| Minimum Deployment | iOS 17.0 |
| Storage | None (不使用Core Data) |
| Include Tests | 勾选 (包含Unit Tests) |

点击"Next"，选择项目保存位置。

### 步骤3：配置Info.plist

在 `Info.plist` 中添加：

```xml
<key>UIApplicationSupportsMultipleScenes</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```

- `UIBackgroundModes` 包含 `fetch` 是后台价格检查和Task调度必需项。

### 步骤4：添加所有Swift文件到工程

1. **创建文件夹结构**
   - 在Xcode项目导航器中右键"TianXianQuant"组
   - 选择"New Group"创建以下分组：
     - App
     - Core / Components / Configuration / Extensions / Networking / Storage
     - Models
     - Resources
     - Services
     - ViewModels
     - Views / Community / Profile / Quant / Review / StockSelect / Teatime / Update / VIP

2. **添加文件**
   - 右键点击对应分组，选择"Add Files to TianXianQuant..."
   - 选择对应的 `.swift` 文件
   - **重要**：确保勾选"Copy items if needed"和Target "TianXianQuant"
   - 点击"Add"

### 步骤5：配置Build Settings

| 设置项 | 值 |
|--------|-----|
| Swift Language Version | Swift 5 |
| Deployment Target | iOS 17.0 |
| Enable Bitcode | No (Xcode 14+已弃用) |
| Always Embed Swift Standard Libraries | Yes |

### 步骤6：验证Target Membership

1. 在项目导航器中依次点击每个 `.swift` 文件
2. 在右侧文件检查器中确认Target Membership：
   - `TianXianQuant/` 下的所有文件 -> "TianXianQuant" 勾选
   - `TianXianQuantTests/` 下的测试文件 -> "TianXianQuantTests" 勾选

### 步骤7：首次构建

按 `Cmd+B` 执行Build，检查是否有编译错误。常见问题：

- **文件未找到**：检查文件是否在正确的Target中
- **循环依赖**：确保Core模块不依赖Views/ViewModels
- **缺少import**：确保使用了`import SwiftUI`、`import Observation`等

---

## 附录：快速检查清单

在首次运行前，请逐项确认：

- [ ] macOS 15+ 已安装
- [ ] Xcode 16.0+ 已安装
- [ ] iOS 17.0+ Simulator 已下载
- [ ] Apple ID 已在Xcode Accounts中配置
- [ ] `stock_list.json` 和 `char_wuxing.json` 已添加到工程并勾选Target
- [ ] `Debug.xcconfig` 和 `Release.xcconfig` 已配置（如需要）
- [ ] Bundle Identifier 设置为唯一值
- [ ] Signing Team 已选择
- [ ] .gitignore 包含 .xcconfig 文件
- [ ] 后端 cpolar 隧道处于运行状态
- [ ] 网络可达 https://bec3168.r29.cpolar.top/api/health

---

如有任何问题，请联系项目维护者或提交Issue。
