import Foundation

// MARK: - GuBanXian Keyword Router

/// Routes user messages to the appropriate calculator based on keyword detection.
/// Ported from Android ChatDetailActivity.kt
final class GuBanXianKeywordRouter {

    // MARK: - Calculator instances

    private let baZiCalc = BaZiCalculator()
    private let qiMenCalc = QiMenDunJiaCalculator()
    private let nameAnalyzer = NameWuxingAnalyzer()

    // MARK: - Main Routing

    /// Route a user message to the appropriate calculator and return the response.
    /// - Parameters:
    ///   - text: User input text
    ///   - isVip: Whether the user has VIP access
    /// - Returns: Bot response text
    func route(text: String, isVip: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // 1. Greetings
        if isGreeting(trimmed) {
            return greetingResponse()
        }

        // 2. Identity questions
        if isIdentityQuestion(trimmed) {
            return identityResponse()
        }

        // 3. BaZi / Fortune-telling keywords
        if isBaZiQuery(trimmed) {
            return handleBaZi(text: trimmed)
        }

        // 4. Stock code / divination keywords
        if isStockQuery(trimmed) {
            return handleStockDivination(text: trimmed)
        }

        // 5. Name / WuXing keywords
        if isNameQuery(trimmed) {
            return handleNameAnalysis(text: trimmed, isVip: isVip)
        }

        // 6. Fallback: try to auto-detect stock name
        if let stockName = detectStockName(trimmed) {
            let code = StockNameMap.shared.getCode(name: stockName) ?? "?"
            return qiMenCalc.divineStock(stockCode: code, stockName: stockName)
        }

        // 7. Fallback: try to extract birth info for BaZi
        if let birthInfo = baZiCalc.extractBirthInfo(from: trimmed) {
            return baZiCalc.calculateChart(
                birthYear: birthInfo.year,
                month: birthInfo.month,
                day: birthInfo.day,
                hour: birthInfo.hour,
                gender: birthInfo.gender
            )
        }

        // 8. Ultimate fallback — general fortune telling
        return fallbackResponse(text: trimmed)
    }

    // MARK: - Keyword Detection

    /// Check if the message is a greeting.
    private func isGreeting(_ text: String) -> Bool {
        let greetings = ["你好", "嗨", "hello", "hi", "在吗", "早上好",
                         "下午好", "晚上好", "大师好", "半仙好", "您好", "哈喽"]
        return greetings.contains(where: { text.contains($0) })
    }

    /// Check if the message is asking about the bot's identity.
    private func isIdentityQuestion(_ text: String) -> Bool {
        let keywords = ["你是谁", "你叫什么", "你会什么", "你能做什么",
                        "你是什么", "介绍一下", "介绍下自己", "你是干嘛的",
                        "你有什么功能", "你能帮我什么", "你怎么称呼"]
        return keywords.contains(where: { text.contains($0) })
    }

    /// Check if the message is a BaZi / fortune-telling query.
    private func isBaZiQuery(_ text: String) -> Bool {
        let keywords = ["八字", "算命", "出生", "生辰", "年", "月", "日", "时辰",
                        "阳历", "阴历", "农历", "命理", "命盘", "排盘", "算命",
                        "运势", "运程", "命运", "财运", "事业运", "姻缘", "桃花",
                        "婚姻", "健康运", "性格", "五行命", "什么命", "算算"]
        // Must detect "年"+"月"+"日" combo or other specific keywords for BaZi routing
        let hasYearMonth = text.contains("年") && text.contains("月")
        let hasSpecificKeyword = keywords.contains { k in
            if k.count <= 1 { return false } // Skip single-char keywords like "年", "月", "日"
            return text.contains(k)
        }
        return hasYearMonth || hasSpecificKeyword
    }

    /// Check if the message is a stock-related query.
    private func isStockQuery(_ text: String) -> Bool {
        let keywords = ["股票", "涨", "跌", "走势", "行情", "占卜", "预测",
                        "奇门", "买入", "卖出", "建仓", "清仓", "投资",
                        "牛股", "妖股", "龙头", "涨停", "跌停", "大盘"]

        // Detect 6-digit stock code
        let codePattern = try? NSRegularExpression(pattern: "\\b\\d{6}\\b", options: [])
        let hasStockCode = codePattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil

        let hasKeyword = keywords.contains(where: { text.contains($0) })

        return hasStockCode || hasKeyword
    }

    /// Check if the message is a name/WuXing query.
    private func isNameQuery(_ text: String) -> Bool {
        let keywords = ["名字", "姓名", "五行", "改名", "起名", "取名",
                        "缺什么", "缺啥", "名字分析", "测名", "测字"]

        // Detect potential Chinese name (2-4 Chinese characters)
        let chineseOnly = text.filter { ch in
            let scalar = ch.unicodeScalars.first?.value ?? 0
            return scalar >= 0x4E00 && scalar <= 0x9FFF
        }
        let isNameForm = chineseOnly.count >= 2 && chineseOnly.count <= 4 &&
                         chineseOnly.count == text.filter({ !$0.isWhitespace }).count

        let hasKeyword = keywords.contains(where: { text.contains($0) })

        return hasKeyword || (isNameForm && text.count <= 8)
    }

    // MARK: - Handlers

    /// Handle BaZi fortune-telling request.
    private func handleBaZi(text: String) -> String {
        if let birthInfo = baZiCalc.extractBirthInfo(from: text) {
            return baZiCalc.calculateChart(
                birthYear: birthInfo.year,
                month: birthInfo.month,
                day: birthInfo.day,
                hour: birthInfo.hour,
                gender: birthInfo.gender
            )
        }

        // Ask for birth info if not found
        return "阿弥陀佛，老衲观施主有算命之意。\n\n"
            + "请施主提供以下信息，老衲为您排盘推算：\n"
            + "1. 出生年份（如1990年）\n"
            + "2. 出生月份（如5月）\n"
            + "3. 出生日期（如20日）\n"
            + "4. 出生时辰（如8时或上午8点）\n"
            + "5. 性别（男/女）\n\n"
            + "例如：\"1990年5月20日8时，男\"\n"
            + "阿弥陀佛，善哉善哉。"
    }

    /// Handle stock divination request.
    private func handleStockDivination(text: String) -> String {
        // Try to extract 6-digit stock code
        let codePattern = try? NSRegularExpression(pattern: "\\b(\\d{6})\\b", options: [])
        if let match = codePattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            let code = String(text[range])
            let name = StockNameMap.shared.getNameOrDefault(code: code, default: "未知股票")
            return qiMenCalc.divineStock(stockCode: code, stockName: name)
        }

        // Try fuzzy match with stock name
        let matches = StockNameMap.shared.fuzzyMatchCode(input: text)
        if let bestMatch = matches.first {
            return qiMenCalc.divineStock(stockCode: bestMatch.code, stockName: bestMatch.name)
        }

        // Ask for stock code
        return "阿弥陀佛，施主欲问股票之事，请提供：\n"
            + "1. 股票代码（6位数字，如000001）\n"
            + "2. 或股票名称\n\n"
            + "老衲将为您起奇门遁甲盘一探究竟。"
    }

    /// Handle name WuXing analysis request.
    private func handleNameAnalysis(text: String, isVip: Bool) -> String {
        // Extract potential name from text
        var nameToAnalyze = ""

        // Try removing keywords to extract name
        let keywords = ["名字", "姓名", "五行", "改名", "起名", "取名",
                        "缺什么", "缺啥", "名字分析", "测名", "测字",
                        "帮我分析", "分析一下", "看看", "想知道", "算一下"]
        nameToAnalyze = text
        for kw in keywords {
            nameToAnalyze = nameToAnalyze.replacingOccurrences(of: kw, with: "")
        }
        nameToAnalyze = nameToAnalyze.trimmingCharacters(in: .whitespaces)

        // Also try detecting surname + given name pattern
        if nameToAnalyze.isEmpty || nameToAnalyze.count > 4 {
            // Try to extract a name from the full text
            nameToAnalyze = extractChineseName(text)
        }

        if nameToAnalyze.isEmpty {
            return "阿弥陀佛，请施主提供姓名（2-4个汉字），老衲为您分析五行属性。\n"
                + "例如：\"帮我分析张三\""
        }

        // Remove surname prefix for display if needed, but keep full name for analysis
        return nameAnalyzer.analyzeName(name: nameToAnalyze, isVip: isVip)
    }

    // MARK: - Greeting Response

    private func greetingResponse() -> String {
        let greetings = [
            "阿弥陀佛，施主有礼了！老衲股半仙在此，敢问施主所为何事？",
            "善哉善哉，施主来了。老衲观您面相不凡，今日必有好事相询。",
            "施主吉祥！老衲精通八字命理、奇门占卜、姓名五行，您想了解哪方面？"
        ]
        return greetings.randomElement() ?? greetings[0]
    }

    // MARK: - Identity Response

    private func identityResponse() -> String {
        return "阿弥陀佛，老衲法号「股半仙」，乃天上一介游方术士。\n\n"
            + "老衲精通三样本事：\n"
            + "1. 【八字算命】— 提供出生年月日时，老衲为您排八字命盘，分析性格、财运、事业、姻缘、健康。\n"
            + "2. 【奇门占卜】— 提供股票代码，老衲以奇门遁甲之术占卜涨跌吉凶。\n"
            + "3. 【姓名五行】— 提供名字，老衲分析五行属性，给出起名改名建议。\n\n"
            + "施主想试哪一样？尽管道来！"
    }

    // MARK: - Fallback Response

    private func fallbackResponse(text: String) -> String {
        // General fortune-telling response
        let responses = [
            "阿弥陀佛，施主所言老衲已了然于胸。天机不可尽泄，然老衲观施主面相，近期运势尚可，宜静不宜动，宜守不宜攻。若有具体疑问，请直言相告。",
            "善哉善哉。老衲掐指一算，施主命中带财，然需耐心等待时机。急则生变，稳则致远。施主可告诉老衲具体所问何事？",
            "施主福缘深厚，老衲以半仙之眼观之，您近期有贵人运。然需主动出击方能把握机缘。不知施主是否想问八字、股票还是姓名？",
            "老衲观天象，紫微星动，施主命中有变数。然变数之中暗藏机遇，吉凶全在一念之间。请施主明示所问，老衲好为施主详细推算。"
        ]
        return responses.randomElement() ?? responses[0]
    }

    // MARK: - Helpers

    /// Try to detect a Chinese name from text by looking up surnames.
    private func extractChineseName(_ text: String) -> String {
        // Look for known Chinese surnames at any position
        for surname in BaZiCalculator.chineseSurnames {
            if let range = text.range(of: surname) {
                let after = String(text[range.lowerBound...])
                // Take surname + up to 3 following chars (total name length 2-4)
                let chineseChars = after.filter { ch in
                    let scalar = ch.unicodeScalars.first?.value ?? 0
                    return scalar >= 0x4E00 && scalar <= 0x9FFF
                }
                if chineseChars.count >= 2 && chineseChars.count <= 4 {
                    return String(chineseChars)
                }
            }
        }

        // Fallback: take first 2-4 consecutive Chinese characters
        let chineseOnly = text.filter { ch in
            let scalar = ch.unicodeScalars.first?.value ?? 0
            return scalar >= 0x4E00 && scalar <= 0x9FFF
        }
        if chineseOnly.count >= 2 && chineseOnly.count <= 4 {
            return String(chineseOnly)
        }

        return ""
    }

    /// Detect if any known stock name appears in the text.
    private func detectStockName(_ text: String) -> String? {
        let matches = StockNameMap.shared.fuzzyMatchCode(input: text)
        // Only auto-detect if we got a very confident match (exact name match)
        for match in matches {
            if text.contains(match.name) {
                return match.name
            }
        }
        return nil
    }
}
