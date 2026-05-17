import Foundation

// MARK: - Name WuXing Analyzer

/// Analyzes Chinese names for five-element (五行) composition.
/// Ported from Android ChatDetailActivity.kt
final class NameWuxingAnalyzer {

    // MARK: - Analysis Result

    struct NameAnalysis {
        let totalChars: Int
        let elementCounts: [String: Int]
        let charDetails: [(char: String, element: String, strokes: Int)]
        let missingElements: [String]
        let excessElements: [String]
        let dominantElement: String?
    }

    // MARK: - Main Analysis

    /// Analyze a Chinese name for its five-element composition.
    /// - Parameters:
    ///   - name: The Chinese name to analyze
    ///   - isVip: Whether the user has VIP access
    /// - Returns: Analysis text in Chinese
    func analyzeName(name: String, isVip: Bool) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return "阿弥陀佛，请施主提供姓名，老衲才能为您分析。"
        }

        // Filter Chinese characters only
        let chineseChars: [(char: String, element: String, strokes: Int)] = trimmed.compactMap { ch in
            let charStr = String(ch)
            if let element = CharWuxingLoader.shared.getWuxing(char: charStr) {
                let strokes = CharWuxingLoader.shared.getStrokes(char: charStr)
                return (charStr, element, strokes)
            }
            // Non-Chinese character — skip
            return nil
        }

        guard !chineseChars.isEmpty else {
            return "阿弥陀佛，施主提供的姓名中未识别到汉字，老衲无法分析。"
        }

        // Count elements
        var elementCounts: [String: Int] = ["金": 0, "木": 0, "水": 0, "火": 0, "土": 0]
        for detail in chineseChars {
            elementCounts[detail.element, default: 0] += 1
        }

        // Find missing elements
        let missingElements = elementCounts.filter { $0.value == 0 }.map { $0.key }

        // Find excess elements (>= 2/3 of total)
        let threshold = max(2, chineseChars.count / 2)
        let excessElements = elementCounts.filter { $0.value >= threshold }.map { $0.key }

        // Dominant element
        let dominantElement = elementCounts.max(by: { $0.value < $1.value })?.key

        let analysis = NameAnalysis(
            totalChars: chineseChars.count,
            elementCounts: elementCounts,
            charDetails: chineseChars,
            missingElements: missingElements,
            excessElements: excessElements,
            dominantElement: dominantElement
        )

        if !isVip {
            return generateNonVipReport(analysis: analysis, name: trimmed)
        } else {
            return generateVipReport(analysis: analysis, name: trimmed)
        }
    }

    // MARK: - Non-VIP Report (Truncated)

    private func generateNonVipReport(analysis: NameAnalysis, name: String) -> String {
        var text = ""
        text += "═══════════════════════\n"
        text += "   姓名五行分析\n"
        text += "═══════════════════════\n"
        text += "姓名：\(name)\n"
        text += "═══════════════════════\n\n"

        text += "【五行分布】\n"
        for (elem, count) in analysis.elementCounts.sorted(by: { $0.key < $1.key }) {
            let emoji = CharWuxingLoader.shared.elementEmoji(element: elem)
            let bar = String(repeating: "█", count: min(count, 10))
            text += "\(emoji) \(elem)：\(bar) (\(count)字)\n"
        }

        if !analysis.missingElements.isEmpty {
            text += "\n【缺失五行】\n"
            text += "姓名中缺少：\(analysis.missingElements.map { CharWuxingLoader.shared.elementEmoji(element: $0) + $0 }.joined(separator: "、"))\n"
        }

        text += "\n═══════════════════════\n"
        text += "🔒 以上为基础分析结果\n\n"
        text += "完整分析包括：\n"
        text += "• 逐字五行详解\n"
        text += "• 五行平衡深度解读\n"
        text += "• 事业/财运/健康建议\n"
        text += "• 改名起名推荐方案\n\n"
        text += "开通VIP解锁完整分析 →\n"
        text += "阿弥陀佛，善哉善哉。"

        return text
    }

    // MARK: - VIP Report (Full)

    private func generateVipReport(analysis: NameAnalysis, name: String) -> String {
        var text = ""
        text += "═══════════════════════\n"
        text += "   姓名五行深度分析\n"
        text += "═══════════════════════\n"
        text += "姓名：\(name)\n"
        text += "字数：\(analysis.totalChars)字\n"
        text += "═══════════════════════\n\n"

        // Character-by-character analysis
        text += "【逐字详解】\n"
        text += "═══════════════════════\n"
        for detail in analysis.charDetails {
            let emoji = CharWuxingLoader.shared.elementEmoji(element: detail.element)
            text += "「\(detail.char)」→ \(emoji)\(detail.element)，\(detail.strokes)画\n"
            text += "    \(getCharAdvice(element: detail.element, strokes: detail.strokes))\n\n"
        }

        // Five element distribution
        text += "═══════════════════════\n"
        text += "【五行分布详析】\n"
        text += "═══════════════════════\n"

        for (elem, count) in analysis.elementCounts.sorted(by: { $0.key < $1.key }) {
            let emoji = CharWuxingLoader.shared.elementEmoji(element: elem)
            let bar = String(repeating: "█", count: count)
            let emptyBar = String(repeating: "░", count: max(0, analysis.totalChars - count))
            let percentage = analysis.totalChars > 0 ? Int(Double(count) / Double(analysis.totalChars) * 100) : 0
            text += "\(emoji) \(elem)：\(bar)\(emptyBar) (\(count)字, \(percentage)%)\n"
        }

        // Balance analysis
        text += "\n═══════════════════════\n"
        text += "【五行平衡解读】\n"
        text += "═══════════════════════\n"

        if analysis.missingElements.isEmpty && analysis.excessElements.isEmpty {
            text += "此名五行俱全，分布均衡，实为难得的好名字。五行流通有情，命主一生运势较为平稳顺遂。\n"
        } else {
            if !analysis.missingElements.isEmpty {
                text += "缺失五行：\(analysis.missingElements.map { CharWuxingLoader.shared.elementEmoji(element: $0) + $0 }.joined(separator: "、"))\n"
                for miss in analysis.missingElements {
                    text += "\(getMissingElementAdvice(element: miss))\n"
                }
            }

            if !analysis.excessElements.isEmpty {
                text += "\n过旺五行：\(analysis.excessElements.map { CharWuxingLoader.shared.elementEmoji(element: $0) + $0 }.joined(separator: "、"))\n"
                for excess in analysis.excessElements {
                    text += "\(getExcessElementAdvice(element: excess))\n"
                }
            }
        }

        // Career and life advice
        text += "\n═══════════════════════\n"
        text += "【事业财运建议】\n"
        text += "═══════════════════════\n"

        if let dominant = analysis.dominantElement {
            text += getCareerAdvice(element: dominant)
        }

        // Health advice
        text += "\n═══════════════════════\n"
        text += "【健康提示】\n"
        text += "═══════════════════════\n"

        if !analysis.missingElements.isEmpty {
            for miss in analysis.missingElements {
                text += getHealthAdvice(element: miss)
            }
        }

        // Naming suggestions
        text += "\n═══════════════════════\n"
        text += "【起名改名建议】\n"
        text += "═══════════════════════\n"
        text += generateNamingSuggestions(missing: analysis.missingElements, currentChars: analysis.charDetails)

        // Disclaimer
        text += "\n═══════════════════════\n"
        text += "以上分析由「股半仙」根据传统五行学说推算，仅供娱乐参考。\n"
        text += "姓名固然重要，但后天努力和品德修为才是人生成败的关键。\n"
        text += "阿弥陀佛，愿施主福慧双修，吉祥如意。"

        return text
    }

    // MARK: - Element Advice Helpers

    private func getCharAdvice(element: String, strokes: Int) -> String {
        switch element {
        case "木": return "此字含木性，主仁德、生长。代表创造力与进取心。为人大度宽厚。"
        case "火": return "此字含火性，主礼仪、热情。代表感染力与行动力。待人真诚热情。"
        case "土": return "此字含土性，主诚信、稳重。代表包容力与责任心。为人可靠踏实。"
        case "金": return "此字含金性，主义气、决断。代表执行力与正义感。做事雷厉风行。"
        case "水": return "此字含水性，主智慧、变通。代表适应力与洞察力。思维灵活敏捷。"
        default: return ""
        }
    }

    private func getMissingElementAdvice(element: String) -> String {
        switch element {
        case "木": return "缺木之人，宜在名字中加入木属性字（如：林、森、松、柏、桐、楠），或多穿绿色、青色衣物。"
        case "火": return "缺火之人，宜在名字中加入火属性字（如：炎、煜、烨、灿、辉、灵），或多穿红色、紫色衣物。"
        case "土": return "缺土之人，宜在名字中加入土属性字（如：坤、垚、培、城、基、坚），或多穿黄色、棕色衣物。"
        case "金": return "缺金之人，宜在名字中加入金属性字（如：锋、铭、锐、钧、锦、钰），或多穿白色、金色衣物。"
        case "水": return "缺水之人，宜在名字中加入水属性字（如：涵、沐、潇、瀚、洋、浩），或多穿蓝色、黑色衣物。"
        default: return ""
        }
    }

    private func getExcessElementAdvice(element: String) -> String {
        switch element {
        case "木": return "木气过旺，需以金克制或以火泄秀。建议在名字中适当加入金、火属性字平衡。"
        case "火": return "火气过旺，需以水克制或以土泄秀。建议在名字中适当加入水、土属性字平衡。"
        case "土": return "土气过旺，需以木克制或以金泄秀。建议在名字中适当加入木、金属性字平衡。"
        case "金": return "金气过旺，需以火克制或以水泄秀。建议在名字中适当加入火、水属性字平衡。"
        case "水": return "水气过旺，需以土克制或以木泄秀。建议在名字中适当加入土、木属性字平衡。"
        default: return ""
        }
    }

    private func getCareerAdvice(element: String) -> String {
        switch element {
        case "木":
            return "命局偏木，宜从事农林园艺、教育文化、医疗保健、环保生态等行业。\n"
                + "财运方面：正财稳定，宜做长期投资规划。不宜投机取巧。\n"
                + "合作贵人：水属性人或从事水相关行业的合作伙伴最为有利。\n"
        case "火":
            return "命局偏火，宜从事能源电力、餐饮娱乐、传媒演艺、科技互联网等行业。\n"
                + "财运方面：偏财运旺，但来得快去得也快，需注意储蓄。\n"
                + "合作贵人：木属性人或从事木相关行业的合作伙伴最为有利。\n"
        case "土":
            return "命局偏土，宜从事房地产建筑、农业矿业、金融保险、中介服务等行业。\n"
                + "财运方面：善于积累，财富增长稳健。适合配置固定资产。\n"
                + "合作贵人：火属性人或从事火相关行业的合作伙伴最为有利。\n"
        case "金":
            return "命局偏金，宜从事金融投资、法律公正、机械制造、军警安保等行业。\n"
                + "财运方面：赚钱能力强，但也要注意控制风险。\n"
                + "合作贵人：土属性人或从事土相关行业的合作伙伴最为有利。\n"
        case "水":
            return "命局偏水，宜从事贸易物流、交通旅游、咨询培训、水产养殖等行业。\n"
                + "财运方面：财如活水，善于发现商机。适合流动性强的行业。\n"
                + "合作贵人：金属性人或从事金相关行业的合作伙伴最为有利。\n"
        default:
            return "五行均衡，事业选择广泛，可在多个领域均有良好发展。\n"
        }
    }

    private func getHealthAdvice(element: String) -> String {
        switch element {
        case "木": return "五行缺木，需关注肝胆健康、筋骨养护。建议多食绿色蔬菜，适当运动伸展。"
        case "火": return "五行缺火，需关注心血管健康、眼部保养。建议多做有氧运动，保持心情舒畅。"
        case "土": return "五行缺土，需关注脾胃消化、免疫力。建议规律饮食，少食生冷，注意保暖。"
        case "金": return "五行缺金，需关注呼吸系统、皮肤健康。建议多呼吸新鲜空气，避免空气污染。"
        case "水": return "五行缺水，需关注肾脏泌尿、骨骼健康。建议多饮水，适当补钙，注意保暖。"
        default: return ""
        }
    }

    // MARK: - Naming Suggestions

    private func generateNamingSuggestions(missing: [String], currentChars: [(char: String, element: String, strokes: Int)]) -> String {
        var text = ""

        if missing.isEmpty {
            text += "此名五行俱全，无需特别补足。若要改名，建议根据八字和大运综合考量。\n"
            return text
        }

        for element in missing {
            text += "补\(element)推荐用字：\n"
            let candidates = suggestCharsForElement(element: element, count: 5)
            for ch in candidates {
                let strokes = CharWuxingLoader.shared.getStrokes(char: ch)
                text += "  「\(ch)」（\(CharWuxingLoader.shared.elementEmoji(element: element))\(element)，\(strokes)画）\n"
            }
            text += "\n"
        }

        text += "【起名原则提醒】\n"
        text += "1. 音韵和谐：名字读起来朗朗上口，避免拗口。\n"
        text += "2. 字形优美：笔画繁简搭配得当，书写美观大方。\n"
        text += "3. 寓意吉祥：字义积极向上，寄托美好祝愿。\n"
        text += "4. 五行匹配：补足所缺，平衡命局，需结合八字全面分析。\n"

        return text
    }

    /// Suggest characters belonging to a specific element.
    private func suggestCharsForElement(element: String, count: Int) -> [String] {
        let allChars = CharWuxingLoader.shared.getAllChars()
        var matching: [String] = []

        for ch in allChars {
            if CharWuxingLoader.shared.getWuxing(char: ch) == element {
                let strokes = CharWuxingLoader.shared.getStrokes(char: ch)
                // Prefer characters with 5-25 strokes (commonly used)
                if strokes >= 5 && strokes <= 25 {
                    matching.append(ch)
                }
            }
            if matching.count >= count * 10 { break }
        }

        // Shuffle and pick a subset
        matching.shuffle()
        return Array(matching.prefix(count))
    }
}
