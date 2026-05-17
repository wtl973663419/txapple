import Foundation

// MARK: - QiMenDunJia (奇门遁甲) Calculator

/// Stock divination using QiMenDunJia principles.
/// Ported from Android ChatDetailActivity.kt
final class QiMenDunJiaCalculator {

    // MARK: - 8 Gates (八门)

    struct Gate {
        let name: String
        let element: String
        let isAuspicious: Bool
        let description: String
        let direction: String
    }

    static let eightGates: [Gate] = [
        Gate(name: "休门", element: "水", isAuspicious: true,
             description: "休养生息，宜守不宜攻。适合休息调整，不利激进操作。", direction: "北"),
        Gate(name: "生门", element: "土", isAuspicious: true,
             description: "生机勃勃，大吉之门。宜买入建仓，财运亨通。", direction: "东北"),
        Gate(name: "伤门", element: "木", isAuspicious: false,
             description: "损伤破败，凶门。宜止损离场，忌追高买入。", direction: "东"),
        Gate(name: "杜门", element: "木", isAuspicious: false,
             description: "闭塞不通，宜观望等待。行情不明朗，暂勿操作。", direction: "东南"),
        Gate(name: "景门", element: "火", isAuspicious: false,
             description: "虚华表象，宜获利了结。利好出尽，见好就收。", direction: "南"),
        Gate(name: "死门", element: "土", isAuspicious: false,
             description: "死气沉沉，大凶之门。忌买入，宜果断止损出局。", direction: "西南"),
        Gate(name: "惊门", element: "金", isAuspicious: false,
             description: "惊恐不定，行情震荡剧烈。宜控制仓位，防范黑天鹅。", direction: "西"),
        Gate(name: "开门", element: "金", isAuspicious: true,
             description: "开泰通达，大吉之门。宜积极布局，逢低吸纳。", direction: "西北")
    ]

    // MARK: - 9 Stars (九星)

    struct Star {
        let name: String
        let element: String
        let nature: String
        let description: String
    }

    static let nineStars: [Star] = [
        Star(name: "天蓬", element: "水", nature: "凶", description: "贪狼星，主大凶。代表风险暗藏，行情可能突然转向。需严格止损。"),
        Star(name: "天芮", element: "土", nature: "凶", description: "巨门星，主疾病。代表市场存在隐患，不宜重仓操作。"),
        Star(name: "天冲", element: "木", nature: "次吉", description: "禄存星，主冲动。代表短线爆发力强，但需快进快出，不宜恋战。"),
        Star(name: "天辅", element: "木", nature: "大吉", description: "文曲星，主辅助。代表有贵人相助，消息面利好。适合跟随趋势。"),
        Star(name: "天禽", element: "土", nature: "大吉", description: "廉贞星，主中正。代表行情平稳，适合中长期布局。价值投资正当时。"),
        Star(name: "天心", element: "金", nature: "大吉", description: "武曲星，主决策。代表精准判断时机已到，执行交易计划的好时机。"),
        Star(name: "天柱", element: "金", nature: "凶", description: "破军星，主破坏。代表行情可能破位下行，注意风险，控制仓位。"),
        Star(name: "天任", element: "土", nature: "大吉", description: "左辅星，主担当。代表市场有支撑，可逢低布局绩优股。"),
        Star(name: "天英", element: "火", nature: "次凶", description: "右弼星，主虚花。代表概念炒作活跃但持续性差，注意辨别真假利好。")
    ]

    // MARK: - 8 Spirits (八神)

    struct Spirit {
        let name: String
        let description: String
        let advice: String
    }

    static let eightSpirits: [Spirit] = [
        Spirit(name: "值符", description: "天乙贵人，诸神之首。市场有领头羊出现，跟随龙头操作。",
               advice: "关注龙头股，顺势而为。"),
        Spirit(name: "騰蛇", description: "虚诈之神，行情有诈。警惕假突破和诱多诱空陷阱。",
               advice: "多看少动，谨防诱多。"),
        Spirit(name: "太阴", description: "阴佑之神，暗中相助。有机构暗中吸筹或出货的迹象。",
               advice: "观察大单资金流向。"),
        Spirit(name: "六合", description: "和合之神，多空胶着。行情将进入横盘整理阶段。",
               advice: "适合网格交易或观望。"),
        Spirit(name: "白虎", description: "凶煞之神，威猛刚烈。行情波动剧烈，涨跌凶猛。",
               advice: "激进者短线博弈，稳健者回避。"),
        Spirit(name: "玄武", description: "盗贼之神，暗藏危机。需防利空消息突袭。",
               advice: "减仓避险，保持流动性。"),
        Spirit(name: "九地", description: "坚牢之神，底部蓄力。行情正在筑底，黎明前的黑暗。",
               advice: "可小仓位试探性建仓。"),
        Spirit(name: "九天", description: "威悍之神，强势上攻。行情可能加速上涨，主升浪在即。",
               advice: "持股待涨，捂股丰登。")
    ]

    // MARK: - Stock Divination

    /// Perform stock divination based on stock code.
    /// - Parameters:
    ///   - stockCode: 6-digit stock code
    ///   - stockName: Stock name
    /// - Returns: Full divination result text
    func divineStock(stockCode: String, stockName: String) -> String {
        let digits = stockCode.compactMap { Int(String($0)) }
        guard digits.count >= 4 else {
            return "阿弥陀佛，施主所问之股票代码不全，老衲无法起卦。请提供完整六位数字代码。"
        }

        // Use sum of digits to determine gate
        let digitSum = digits.reduce(0, +)
        let gateIndex = digitSum % BaZiCalculator.earthlyBranches.count
        let gate = QiMenDunJiaCalculator.eightGates[gateIndex % 8]

        // Use product of last 3 digits for star
        let lastThree = Array(digits.suffix(3))
        let product = lastThree.reduce(1, *)
        let starIndex = product % 9
        let star = QiMenDunJiaCalculator.nineStars[starIndex]

        // Use first 2 digits for spirit
        let firstTwo = Array(digits.prefix(2))
        let firstTwoValue = (firstTwo.first ?? 0) * 10 + (firstTwo.last ?? 0)
        let spiritIndex = firstTwoValue % BaZiCalculator.earthlyBranches.count
        let spirit = QiMenDunJiaCalculator.eightSpirits[spiritIndex % 8]

        // Use today's date for time factor
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        let lunarMonth = (dayOfYear % 12) + 1

        // Judge overall auspiciousness
        let auspiciousScore = calculateAuspiciousScore(gate: gate, star: star, spirit: spirit, digits: digits)

        return generateFullReport(
            stockCode: stockCode,
            stockName: stockName,
            gate: gate,
            star: star,
            spirit: spirit,
            score: auspiciousScore,
            lunarMonth: lunarMonth,
            digitSum: digitSum
        )
    }

    // MARK: - Score Calculation

    private func calculateAuspiciousScore(gate: Gate, star: Star, spirit: Spirit, digits: [Int]) -> Int {
        var score = 50 // Base

        // Gate influence (±20)
        if gate.isAuspicious {
            switch gate.name {
            case "生门": score += 20
            case "开门": score += 18
            case "休门": score += 12
            default: score += 10
            }
        } else {
            switch gate.name {
            case "死门": score -= 20
            case "伤门": score -= 15
            case "惊门": score -= 12
            default: score -= 8
            }
        }

        // Star influence (±20)
        switch star.nature {
        case "大吉": score += 15
        case "次吉": score += 8
        case "次凶": score -= 8
        case "凶": score -= 15
        default: break
        }

        // Spirit influence (±10)
        switch spirit.name {
        case "值符": score += 10
        case "九天": score += 10
        case "太阴": score += 5
        case "九地": score += 5
        case "六合": score += 0
        case "白虎": score -= 5
        case "騰蛇": score -= 8
        case "玄武": score -= 10
        default: break
        }

        // Digit smoothness bonus (±10)
        let consecutiveAscending = zip(digits, digits.dropFirst()).allSatisfy { $0 <= $1 }
        let consecutiveDescending = zip(digits, digits.dropFirst()).allSatisfy { $0 >= $1 }
        if consecutiveAscending {
            score += 10
        } else if consecutiveDescending {
            score -= 5
        }

        // Repdigit check (e.g., 000001, 666666)
        if Set(digits).count == 1 {
            score += 8
        }

        return max(0, min(100, score))
    }

    // MARK: - Full Report Generation

    private func generateFullReport(stockCode: String, stockName: String,
                                     gate: Gate, star: Star, spirit: Spirit,
                                     score: Int, lunarMonth: Int, digitSum: Int) -> String {
        var text = ""

        // Header
        text += "═══════════════════════\n"
        text += "   奇门遁甲·股票占卜\n"
        text += "═══════════════════════\n"
        text += "股票：\(stockName)（\(stockCode)）\n"
        text += "═══════════════════════\n\n"

        // Overall verdict
        text += "【综合评分】\(score)/100\n"

        let verdict: String
        if score >= 80 {
            verdict = "大吉"
        } else if score >= 65 {
            verdict = "吉"
        } else if score >= 50 {
            verdict = "中平"
        } else if score >= 35 {
            verdict = "凶"
        } else {
            verdict = "大凶"
        }

        let verdictEmoji: String
        switch verdict {
        case "大吉": verdictEmoji = "✨"
        case "吉": verdictEmoji = "👍"
        case "中平": verdictEmoji = "➖"
        case "凶": verdictEmoji = "⚠️"
        case "大凶": verdictEmoji = "🚫"
        default: verdictEmoji = "❓"
        }
        text += "总体卦象：\(verdictEmoji) \(verdict)\n\n"

        // Gate analysis
        text += "═══════════════════════\n"
        text += "【八门分析】\n"
        text += "═══════════════════════\n"
        text += "落宫：\(gate.name)（属\(gate.element)，方位\(gate.direction)）\n"
        text += "吉凶：\(gate.isAuspicious ? "吉门 ✅" : "凶门 ⚠️")\n"
        text += "解读：\(gate.description)\n\n"

        // Star analysis
        text += "═══════════════════════\n"
        text += "【九星分析】\n"
        text += "═══════════════════════\n"
        text += "值星：\(star.name)（属\(star.element)，\(star.nature)）\n"
        text += "解读：\(star.description)\n\n"

        // Spirit analysis
        text += "═══════════════════════\n"
        text += "【八神分析】\n"
        text += "═══════════════════════\n"
        text += "值神：\(spirit.name)\n"
        text += "解读：\(spirit.description)\n"
        text += "建议：\(spirit.advice)\n\n"

        // Temporal advice
        text += "═══════════════════════\n"
        text += "【时令吉凶】\n"
        text += "═══════════════════════\n"
        text += generateTemporalAdvice(monthNum: lunarMonth, gate: gate, star: star)

        // Direction advice
        text += "\n═══════════════════════\n"
        text += "【方位建议】\n"
        text += "═══════════════════════\n"
        text += generateDirectionAdvice(gateElement: gate.element)

        // Trading strategy
        text += "\n═══════════════════════\n"
        text += "【操作策略】\n"
        text += "═══════════════════════\n"
        text += generateTradingAdvice(score: score, gate: gate, star: star, spirit: spirit)

        // Disclaimer
        text += "\n═══════════════════════\n"
        text += "以上占卜结果由「股半仙」根据奇门遁甲原理推算，仅供娱乐参考。\n"
        text += "股市有风险，投资需谨慎。请结合基本面和技术面综合判断。\n"
        text += "阿弥陀佛，愿施主投资顺利，财源广进。"

        return text
    }

    // MARK: - Temporal Advice

    private func generateTemporalAdvice(monthNum: Int, gate: Gate, star: Star) -> String {
        let monthBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        let curBranch = monthBranches[(monthNum - 1) % 12]

        var text = "当前时令：\(curBranch)月\n\n"

        // Gate and month relation
        let gateElement = gate.element
        let monthElement = BaZiCalculator.earthlyBranchesElement[curBranch] ?? "?"

        if isGenerating(generator: monthElement, receiver: gateElement) {
            text += "本月月令生助门宫，卦象应时，力量倍增。\(gate.isAuspicious ? "吉事更吉，可积极操作。" : "凶象稍缓，但仍需谨慎。")\n"
        } else if isGenerating(generator: gateElement, receiver: monthElement) {
            text += "门宫生月令，泄气之象。\(gate.isAuspicious ? "吉力减弱，操作宜稳。" : "凶象被泄，反有转机。")\n"
        } else if monthElement == gateElement {
            text += "月令与门宫比和，运势持平。按常规策略操作即可。\n"
        } else {
            text += "月令与门宫相克，不逢其时。建议减少操作频率和仓位。\n"
        }

        // Star energy vs season
        let starElement = star.element
        let seasonStrength = getSeasonalStrength(element: starElement, monthBranch: curBranch)

        text += "\n\(star.name)在当前时令：\(seasonStrength)\n"

        return text
    }

    private func getSeasonalStrength(element: String, monthBranch: String) -> String {
        let springBranches = ["寅", "卯"]
        let summerBranches = ["巳", "午"]
        let autumnBranches = ["申", "酉"]
        let winterBranches = ["亥", "子"]
        let earthBranches = ["辰", "戌", "丑", "未"]

        let isSpring = springBranches.contains(monthBranch)
        let isSummer = summerBranches.contains(monthBranch)
        let isAutumn = autumnBranches.contains(monthBranch)
        let isWinter = winterBranches.contains(monthBranch)
        let isEarthSeason = earthBranches.contains(monthBranch)

        switch element {
        case "木":
            return isSpring ? "旺相（最佳时期）" : isSummer ? "休囚" : isAutumn ? "死绝（最弱时期）" : isWinter ? "相" : "平"
        case "火":
            return isSummer ? "旺相（最佳时期）" : isAutumn ? "休囚" : isWinter ? "死绝（最弱时期）" : isSpring ? "相" : "平"
        case "金":
            return isAutumn ? "旺相（最佳时期）" : isWinter ? "休囚" : isSpring ? "死绝（最弱时期）" : isSummer ? "相" : "平"
        case "水":
            return isWinter ? "旺相（最佳时期）" : isSpring ? "休囚" : isSummer ? "死绝（最弱时期）" : isAutumn ? "相" : "平"
        case "土":
            return isEarthSeason ? "旺相（最佳时期）" : isAutumn ? "休囚" : isSpring ? "死绝（最弱时期）" : isSummer ? "相" : "平"
        default:
            return "平"
        }
    }

    // MARK: - Direction Advice

    private func generateDirectionAdvice(gateElement: String) -> String {
        var text = ""
        let elementDirection: [String: (String, String)] = [
            "木": ("东方、东南方", "西方、西北方"),
            "火": ("南方", "北方"),
            "土": ("西南方、东北方", "东方、东南方"),
            "金": ("西方、西北方", "南方"),
            "水": ("北方", "西南方、东北方")
        ]

        if let (favorable, avoid) = elementDirection[gateElement] {
            text += "有利方位：\(favorable)\n"
            text += "不利方位：\(avoid)\n"
        }

        text += "\n择时选方位并非决定盈亏的唯一因素，建议结合自身实际情况灵活应对。"
        return text
    }

    // MARK: - Trading Advice

    private func generateTradingAdvice(score: Int, gate: Gate, star: Star, spirit: Spirit) -> String {
        var text = ""

        // Core strategy based on score
        switch score {
        case 80...100:
            text += "【强烈看多】\n"
            text += "卦象大吉，多重利好叠加。操作建议：\n"
            text += "1. 仓位管理：可将仓位提升至7-8成\n"
            text += "2. 操作策略：逢低积极吸纳，持股为主\n"
            text += "3. 止损设置：放宽止损位至-8%\n"
            text += "4. 持仓周期：可中长线持有，耐心等待行情发酵\n"
        case 65..<80:
            text += "【看多】\n"
            text += "卦象偏吉，有一定赢面。操作建议：\n"
            text += "1. 仓位管理：保持5-6成仓位\n"
            text += "2. 操作策略：逢回调建仓，不追高\n"
            text += "3. 止损设置：-5%严格止损\n"
            text += "4. 持仓周期：短线波段操作为主\n"
        case 50..<65:
            text += "【中性】\n"
            text += "卦象中平，胜率对半。操作建议：\n"
            text += "1. 仓位管理：保持3-4成仓位\n"
            text += "2. 操作策略：高抛低吸，网格交易\n"
            text += "3. 止损设置：-3%快进快出\n"
            text += "4. 持仓周期：超短线，有利润就跑\n"
        case 35..<50:
            text += "【看空】\n"
            text += "卦象偏凶，不宜重仓。操作建议：\n"
            text += "1. 仓位管理：降至1-2成仓位\n"
            text += "2. 操作策略：减仓避险，观望为主\n"
            text += "3. 止损设置：立即止损离场\n"
            text += "4. 持仓周期：不建议新建仓位\n"
        default:
            text += "【强烈看空】\n"
            text += "卦象大凶，建议规避风险。操作建议：\n"
            text += "1. 仓位管理：清仓或极低仓位\n"
            text += "2. 操作策略：空仓观望，不操作\n"
            text += "3. 止损设置：立即清仓\n"
            text += "4. 持仓周期：持币等待更好时机\n"
        }

        // Specific advice based on spirit
        text += "\n【神煞提示】\n"
        text += "\(spirit.advice)\n"

        // Gate-specific tip
        text += "\n【\(gate.name)提示】\n"
        text += "\(gate.description)\n"

        return text
    }

    // MARK: - Helpers

    private func isGenerating(generator: String, receiver: String) -> Bool {
        let cycle = ["木": "火", "火": "土", "土": "金", "金": "水", "水": "木"]
        return cycle[generator] == receiver
    }
}
