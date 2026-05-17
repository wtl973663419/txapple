import Foundation

// MARK: - BaZi (八字) Calculator

/// Complete BaZi (Four Pillars of Destiny) birth chart calculator.
/// Ported from Android ChatDetailActivity.kt
final class BaZiCalculator {

    // MARK: - Constants: Heavenly Stems (天干)

    static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    static let heavenlyStemsElement = ["甲": "木", "乙": "木", "丙": "火", "丁": "火", "戊": "土", "己": "土",
                                       "庚": "金", "辛": "金", "壬": "水", "癸": "水"]

    // MARK: - Constants: Earthly Branches (地支)

    static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    static let earthlyBranchesElement = ["子": "水", "丑": "土", "寅": "木", "卯": "木",
                                          "辰": "土", "巳": "火", "午": "火", "未": "土",
                                          "申": "金", "酉": "金", "戌": "土", "亥": "水"]

    // MARK: - Constants: Hidden Stems (藏干) for each earthly branch

    static let hiddenStems: [String: [String]] = [
        "子": ["癸"],
        "丑": ["己", "癸", "辛"],
        "寅": ["甲", "丙", "戊"],
        "卯": ["乙"],
        "辰": ["戊", "乙", "癸"],
        "巳": ["丙", "庚", "戊"],
        "午": ["丁", "己"],
        "未": ["己", "丁", "乙"],
        "申": ["庚", "壬", "戊"],
        "酉": ["辛"],
        "戌": ["戊", "辛", "丁"],
        "亥": ["壬", "甲"]
    ]

    // MARK: - Constants: NaYin Five Elements (纳音五行) for the 60 JiaZi pairs

    static let naYinWuXing: [String: String] = {
        let naYinGroups = [
            "金": ["甲子", "乙丑", "壬寅", "癸卯", "庚辰", "辛巳", "甲午", "乙未", "壬申", "癸酉", "庚戌", "辛亥"],
            "木": ["戊辰", "己巳", "壬午", "癸未", "庚寅", "辛卯", "戊戌", "己亥", "壬子", "癸丑", "庚申", "辛酉"],
            "水": ["丙子", "丁丑", "甲寅", "乙卯", "壬辰", "癸巳", "丙午", "丁未", "甲申", "乙酉", "壬戌", "癸亥"],
            "火": ["甲辰", "乙巳", "丙寅", "丁卯", "戊午", "己未", "丙申", "丁酉", "甲戌", "乙亥", "戊子", "己丑"],
            "土": ["庚子", "辛丑", "戊寅", "己卯", "丙辰", "丁巳", "庚午", "辛未", "戊申", "己酉", "丙戌", "丁亥"]
        ]
        var map: [String: String] = [:]
        for (element, pairs) in naYinGroups {
            for pair in pairs {
                map[pair] = element
            }
        }
        return map
    }()

    // MARK: - Constants: 10 Gods (十神)

    static let tenGodsMap: [String: [String: Any]] = [
        // Day Master  比肩  劫财  食神  伤官  偏财  正财  七杀  正官  偏印  正印
        "甲": ["木": "比肩", "火": ["丙":"食神","丁":"伤官","午":"伤官","巳":"食神"], "土": ["戊":"偏财","己":"正财","辰":"偏财","戌":"偏财","丑":"正财","未":"正财"], "金": ["庚":"七杀","辛":"正官","申":"七杀","酉":"正官"], "水": ["壬":"偏印","癸":"正印","子":"正印","亥":"偏印"]],
        "乙": ["木": "比肩", "火": ["丙":"伤官","丁":"食神","午":"食神","巳":"伤官"], "土": ["戊":"正财","己":"偏财","辰":"正财","戌":"正财","丑":"偏财","未":"偏财"], "金": ["庚":"正官","辛":"七杀","申":"正官","酉":"七杀"], "水": ["壬":"正印","癸":"偏印","子":"偏印","亥":"正印"]],
        "丙": ["火": "比肩", "土": ["戊":"食神","己":"伤官","辰":"食神","戌":"食神","丑":"伤官","未":"伤官"], "金": ["庚":"偏财","辛":"正财","申":"偏财","酉":"正财"], "水": ["壬":"七杀","癸":"正官","子":"正官","亥":"七杀"], "木": ["甲":"偏印","乙":"正印","寅":"偏印","卯":"正印"]],
        "丁": ["火": "比肩", "土": ["戊":"伤官","己":"食神","辰":"伤官","戌":"伤官","丑":"食神","未":"食神"], "金": ["庚":"正财","辛":"偏财","申":"正财","酉":"偏财"], "水": ["壬":"正官","癸":"七杀","子":"七杀","亥":"正官"], "木": ["甲":"正印","乙":"偏印","寅":"正印","卯":"偏印"]],
        "戊": ["土": "比肩", "金": ["庚":"食神","辛":"伤官","申":"食神","酉":"伤官"], "水": ["壬":"偏财","癸":"正财","子":"正财","亥":"偏财"], "木": ["甲":"七杀","乙":"正官","寅":"七杀","卯":"正官"], "火": ["丙":"偏印","丁":"正印","午":"正印","巳":"偏印"]],
        "己": ["土": "比肩", "金": ["庚":"伤官","辛":"食神","申":"伤官","酉":"食神"], "水": ["壬":"正财","癸":"偏财","子":"偏财","亥":"正财"], "木": ["甲":"正官","乙":"七杀","寅":"正官","卯":"七杀"], "火": ["丙":"正印","丁":"偏印","午":"偏印","巳":"正印"]],
        "庚": ["金": "比肩", "水": ["壬":"食神","癸":"伤官","子":"伤官","亥":"食神"], "木": ["甲":"偏财","乙":"正财","寅":"偏财","卯":"正财"], "火": ["丙":"七杀","丁":"正官","午":"正官","巳":"七杀"], "土": ["戊":"偏印","己":"正印","辰":"偏印","戌":"偏印","丑":"正印","未":"正印"]],
        "辛": ["金": "比肩", "水": ["壬":"伤官","癸":"食神","子":"食神","亥":"伤官"], "木": ["甲":"正财","乙":"偏财","寅":"正财","卯":"偏财"], "火": ["丙":"正官","丁":"七杀","午":"七杀","巳":"正官"], "土": ["戊":"正印","己":"偏印","辰":"正印","戌":"正印","丑":"偏印","未":"偏印"]],
        "壬": ["水": "比肩", "木": ["甲":"食神","乙":"伤官","寅":"食神","卯":"伤官"], "火": ["丙":"偏财","丁":"正财","午":"正财","巳":"偏财"], "土": ["戊":"七杀","己":"正官","辰":"七杀","戌":"七杀","丑":"正官","未":"正官"], "金": ["庚":"偏印","辛":"正印","申":"偏印","酉":"正印"]],
        "癸": ["水": "比肩", "木": ["甲":"伤官","乙":"食神","寅":"伤官","卯":"食神"], "火": ["丙":"正财","丁":"偏财","午":"偏财","巳":"正财"], "土": ["戊":"正官","己":"七杀","辰":"正官","戌":"正官","丑":"七杀","未":"七杀"], "金": ["庚":"正印","辛":"偏印","申":"正印","酉":"偏印"]]
    ]

    // MARK: - JieQi (Solar Terms) approximate dates

    struct JieQiInfo {
        let name: String
        let month: Int
        let day: Int
        let branchIndex: Int // Corresponding earthly branch month
    }

    static let jieQiList: [JieQiInfo] = [
        JieQiInfo(name: "立春", month: 2, day: 4, branchIndex: 2),   // 寅月
        JieQiInfo(name: "惊蛰", month: 3, day: 6, branchIndex: 3),   // 卯月
        JieQiInfo(name: "清明", month: 4, day: 5, branchIndex: 4),   // 辰月
        JieQiInfo(name: "立夏", month: 5, day: 6, branchIndex: 5),   // 巳月
        JieQiInfo(name: "芒种", month: 6, day: 6, branchIndex: 6),   // 午月
        JieQiInfo(name: "小暑", month: 7, day: 7, branchIndex: 7),   // 未月
        JieQiInfo(name: "立秋", month: 8, day: 8, branchIndex: 8),   // 申月
        JieQiInfo(name: "白露", month: 9, day: 8, branchIndex: 9),   // 酉月
        JieQiInfo(name: "寒露", month: 10, day: 8, branchIndex: 10),  // 戌月
        JieQiInfo(name: "立冬", month: 11, day: 7, branchIndex: 11),  // 亥月
        JieQiInfo(name: "大雪", month: 12, day: 7, branchIndex: 0),   // 子月
        JieQiInfo(name: "小寒", month: 1, day: 6, branchIndex: 1)    // 丑月
    ]

    // MARK: - Hour to Earthly Branch (时辰 → 地支)

    static let hourToBranch: [(startHour: Int, branchIndex: Int, name: String)] = [
        (23, 0, "子"), (1, 1, "丑"), (3, 2, "寅"), (5, 3, "卯"),
        (7, 4, "辰"), (9, 5, "巳"), (11, 6, "午"), (13, 7, "未"),
        (15, 8, "申"), (17, 9, "酉"), (19, 10, "戌"), (21, 11, "亥")
    ]

    // MARK: - Five Tiger Chant (五虎遁) — Month stem from year stem

    static let fiveTigerStemStart: [String: Int] = [
        "甲": 2, "己": 2,  // 丙寅
        "乙": 4, "庚": 4,  // 戊寅
        "丙": 6, "辛": 6,  // 庚寅
        "丁": 8, "壬": 8,  // 壬寅
        "戊": 0, "癸": 0   // 甲寅
    ]

    // MARK: - Five Rat Chant (五鼠遁) — Hour stem from day stem

    static let fiveRatStemStart: [String: Int] = [
        "甲": 0, "己": 0,  // 甲子
        "乙": 2, "庚": 2,  // 丙子
        "丙": 4, "辛": 4,  // 戊子
        "丁": 6, "壬": 6,  // 庚子
        "戊": 8, "癸": 8   // 壬子
    ]

    // MARK: - Chinese Surnames (300+ for auto-detection)

    static let chineseSurnames: Set<String> = [
        "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈", "褚", "卫", "蒋", "沈", "韩", "杨",
        "朱", "秦", "尤", "许", "何", "吕", "施", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜",
        "戚", "谢", "邹", "喻", "柏", "水", "窦", "章", "云", "苏", "潘", "葛", "奚", "范", "彭", "郎",
        "鲁", "韦", "昌", "马", "苗", "凤", "花", "方", "俞", "任", "袁", "柳", "酆", "鲍", "史", "唐",
        "费", "廉", "岑", "薛", "雷", "贺", "倪", "汤", "滕", "殷", "罗", "毕", "郝", "邬", "安", "常",
        "乐", "于", "时", "傅", "皮", "卞", "齐", "康", "伍", "余", "元", "卜", "顾", "孟", "平", "黄",
        "和", "穆", "萧", "尹", "姚", "邵", "湛", "汪", "祁", "毛", "禹", "狄", "米", "贝", "明", "臧",
        "计", "伏", "成", "戴", "谈", "宋", "茅", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "梁",
        "杜", "阮", "蓝", "闵", "席", "季", "麻", "强", "贾", "路", "娄", "危", "江", "童", "颜", "郭",
        "梅", "盛", "林", "刁", "钟", "徐", "邱", "骆", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍",
        "虞", "万", "支", "柯", "咎", "管", "卢", "莫", "经", "房", "裘", "缪", "干", "解", "应", "宗",
        "丁", "宣", "贲", "邓", "郁", "单", "杭", "洪", "包", "诸", "左", "石", "崔", "吉", "钮", "龚",
        "程", "嵇", "邢", "滑", "裴", "陆", "荣", "翁", "荀", "羊", "於", "惠", "甄", "曲", "家", "封",
        "芮", "羿", "储", "靳", "汲", "邴", "糜", "松", "井", "段", "富", "巫", "乌", "焦", "巴", "弓",
        "牧", "隗", "山", "谷", "车", "侯", "宓", "蓬", "全", "郗", "班", "仰", "秋", "仲", "伊", "宫",
        "宁", "仇", "栾", "暴", "甘", "钭", "厉", "戎", "祖", "武", "符", "刘", "景", "詹", "束", "龙",
        "叶", "幸", "司", "韶", "郜", "黎", "蓟", "薄", "印", "白", "怀", "蒲", "邰", "从", "鄂", "索",
        "咸", "籍", "赖", "卓", "蔺", "屠", "蒙", "池", "乔", "阴", "胥", "能", "苍", "双", "闻", "莘",
        "党", "翟", "谭", "贡", "劳", "逄", "姬", "申", "扶", "堵", "冉", "宰", "郦", "雍", "璩", "桑",
        "桂", "濮", "牛", "寿", "通", "边", "扈", "燕", "冀", "郏", "浦", "尚", "农", "温", "别", "庄",
        "晏", "柴", "瞿", "阎", "充", "慕", "连", "茹", "习", "宦", "艾", "鱼", "容", "向", "古", "易",
        "慎", "戈", "廖", "庾", "终", "暨", "居", "衡", "步", "都", "耿", "满", "弘", "匡", "国", "文",
        "寇", "广", "禄", "阙", "东", "欧", "殳", "沃", "利", "蔚", "越", "夔", "隆", "师", "巩", "厍",
        "聂", "晁", "勾", "敖", "融", "冷", "訾", "辛", "阚", "那", "简", "饶", "空", "曾", "毋", "沙",
        "乜", "养", "鞠", "须", "丰", "巢", "关", "蒯", "相", "查", "后", "荆", "红", "游", "竺", "权",
        "逯", "盖", "益", "桓", "公", "万俟", "司马", "上官", "欧阳", "夏侯", "诸葛", "闻人", "东方", "赫连",
        "皇甫", "尉迟", "公羊", "澹台", "公冶", "宗政", "濮阳", "淳于", "单于", "太叔", "申屠", "公孙", "仲孙",
        "轩辕", "令狐", "钟离", "宇文", "长孙", "慕容", "鲜于", "闾丘", "司徒", "司空", "丌官", "司寇", "仉督",
        "子车", "颛孙", "端木", "巫马", "公西", "漆雕", "乐正", "壤驷", "公良", "拓拔", "夹谷", "宰父", "谷梁",
        "晋", "楚", "闫", "法", "汝", "鄢", "涂", "钦", "段干", "百里", "东郭", "南门", "呼延", "归", "海",
        "羊舌", "微生", "岳", "帅", "缑", "亢", "况", "郈", "有", "琴", "梁丘", "左丘", "东门", "西门",
        "商", "牟", "佘", "佴", "伯", "赏", "南宫", "墨", "哈", "谯", "笪", "年", "爱", "阳", "佟", "言",
        "福", "刘" // Keep duplicates - Set will deduplicate
    ]

    // MARK: - Main Calculation

    /// Calculate complete birth chart from birth date and time.
    /// Parameters:
    ///   - birthYear: Gregorian year (e.g., 1990)
    ///   - month: Gregorian month (1-12)
    ///   - day: Gregorian day (1-31)
    ///   - hour: Hour of day (0-23)
    ///   - gender: "男" or "女"
    /// Returns: Full analysis text in Chinese
    func calculateChart(birthYear: Int, month: Int, day: Int, hour: Int, gender: String) -> String {
        // Calculate four pillars
        let yearPillar = calcYearPillar(year: birthYear)
        let monthPillar = calcMonthPillar(year: birthYear, month: month, day: day)
        let dayPillar = calcDayPillar(year: birthYear, month: month, day: day)
        let hourPillar = calcHourPillar(dayStem: dayPillar.stem, hour: hour)

        let dayMaster = dayPillar.stem
        let dayMasterElem = BaZiCalculator.heavenlyStemsElement[dayMaster] ?? "?"

        // Analyze
        var result = ""
        result += generateChartDisplay(yearPillar: yearPillar, monthPillar: monthPillar,
                                        dayPillar: dayPillar, hourPillar: hourPillar,
                                        year: birthYear, month: month, day: day, hour: hour,
                                        gender: gender)
        result += "\n\n\(generatePersonalityAnalysis(dayMaster: dayMaster))"
        result += "\n\n\(generateWealthFortune(dayMaster: dayMaster, dayMasterElem: dayMasterElem))"
        result += "\n\n\(generateCareerFortune(dayMaster: dayMaster, dayMasterElem: dayMasterElem))"
        result += "\n\n\(generateMarriageFortune(dayMaster: dayMaster, dayMasterElem: dayMasterElem, allPillars: [yearPillar, monthPillar, dayPillar, hourPillar]))"
        result += "\n\n\(generateHealthReading(dayMaster: dayMaster, dayMasterElem: dayMasterElem, allPillars: [yearPillar, monthPillar, dayPillar, hourPillar]))"
        result += "\n\n\(generateSummary(dayMaster: dayMaster, dayMasterElem: dayMasterElem, gender: gender))"

        return result
    }

    // MARK: - Pillar Calculation

    struct Pillar {
        let stem: String
        let branch: String
    }

    /// Calculate year pillar from Gregorian year.
    private func calcYearPillar(year: Int) -> Pillar {
        // The Chinese year starts at LiChun (~Feb 4). For simplicity, use year as-is
        // 甲子 = 1984, cycle of 60
        let baseYear = 1984
        let offset = ((year - baseYear) % 60 + 60) % 60
        let stemIndex = offset % 10
        let branchIndex = offset % 12
        return Pillar(stem: BaZiCalculator.heavenlyStems[stemIndex],
                       branch: BaZiCalculator.earthlyBranches[branchIndex])
    }

    /// Calculate month pillar based on JieQi (solar terms).
    private func calcMonthPillar(year: Int, month: Int, day: Int) -> Pillar {
        // Determine which JieQi month we are in
        var monthBranchIndex = -1
        let dateValue = month * 100 + day

        let sortedJieQi = BaZiCalculator.jieQiList.sorted { a, b in
            let va = a.month * 100 + a.day
            let vb = b.month * 100 + b.day
            return va < vb
        }

        // Find the JieQi group: compare by circular list
        // JieQi list sorted: 小寒(1/6) -> 立春(2/4) -> ... -> 大雪(12/7)
        for i in 0..<sortedJieQi.count {
            let current = sortedJieQi[i]
            let currentVal = current.month * 100 + current.day
            let next = sortedJieQi[(i + 1) % sortedJieQi.count]
            let nextVal = next.month * 100 + next.day

            if current.month <= next.month {
                // Same year transition
                if dateValue >= currentVal && dateValue < nextVal {
                    monthBranchIndex = current.branchIndex
                    break
                }
            } else {
                // Year boundary (e.g., 大雪 Dec 7 to 小寒 Jan 6 next year)
                if dateValue >= currentVal || dateValue < nextVal {
                    monthBranchIndex = current.branchIndex
                    break
                }
            }
        }

        if monthBranchIndex == -1 {
            // Fallback: standard mapping
            monthBranchIndex = (month + 1) % 12
        }

        // Month heavenly stem from Five Tiger Chant
        let yearStem = calcYearPillar(year: year).stem
        let startStem = BaZiCalculator.fiveTigerStemStart[yearStem] ?? 0
        let monthStemIndex = (startStem + monthBranchIndex - 2 + 12) % 10 // -2 because 寅(2) is first

        return Pillar(
            stem: BaZiCalculator.heavenlyStems[monthStemIndex],
            branch: BaZiCalculator.earthlyBranches[monthBranchIndex]
        )
    }

    /// Calculate day pillar from Gregorian date.
    /// Uses the formula: days from 1900-01-01 (甲戌日).
    private func calcDayPillar(year: Int, month: Int, day: Int) -> Pillar {
        // Reference: 1900-01-01 = 甲戌日 (stem index 0, branch index 10)
        let days = daysSince1900(year: year, month: month, day: day)
        let refStem = 0  // 甲
        let refBranch = 10 // 戌
        let stemIndex = ((refStem + days) % 10 + 10) % 10
        let branchIndex = ((refBranch + days) % 12 + 12) % 12
        return Pillar(stem: BaZiCalculator.heavenlyStems[stemIndex],
                       branch: BaZiCalculator.earthlyBranches[branchIndex])
    }

    /// Calculate days from 1900-01-01 to given date.
    private func daysSince1900(year: Int, month: Int, day: Int) -> Int {
        var days = 0
        for y in 1900..<year {
            days += isLeapYear(y: y) ? 366 : 365
        }
        let monthDays = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for m in 1..<month {
            days += monthDays[m]
            if m == 2 && isLeapYear(y: year) { days += 1 }
        }
        days += day - 1
        return days
    }

    private func isLeapYear(y: Int) -> Bool {
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }

    /// Calculate hour pillar.
    private func calcHourPillar(dayStem: String, hour: Int) -> Pillar {
        // Find the earthly branch for this hour
        var branchIndex = 0
        for entry in BaZiCalculator.hourToBranch {
            if hour == entry.startHour || (hour > entry.startHour && hour < entry.startHour + 2) {
                branchIndex = entry.branchIndex
                break
            }
        }
        // Handle 23:00-23:59 already covered by first entry. Handle 0:00 as part of 子时
        if hour >= 23 || hour < 1 {
            branchIndex = 0 // 子
        }

        // Hour heavenly stem from Five Rat Chant
        let startStem = BaZiCalculator.fiveRatStemStart[dayStem] ?? 0
        let stemIndex = (startStem + branchIndex) % 10

        return Pillar(stem: BaZiCalculator.heavenlyStems[stemIndex],
                       branch: BaZiCalculator.earthlyBranches[branchIndex])
    }

    // MARK: - Chart Display

    private func generateChartDisplay(yearPillar: Pillar, monthPillar: Pillar,
                                       dayPillar: Pillar, hourPillar: Pillar,
                                       year: Int, month: Int, day: Int, hour: Int,
                                       gender: String) -> String {
        let yearNaYin = BaZiCalculator.naYinWuXing[yearPillar.stem + yearPillar.branch] ?? "?"
        let monthNaYin = BaZiCalculator.naYinWuXing[monthPillar.stem + monthPillar.branch] ?? "?"
        let dayNaYin = BaZiCalculator.naYinWuXing[dayPillar.stem + dayPillar.branch] ?? "?"
        let hourNaYin = BaZiCalculator.naYinWuXing[hourPillar.stem + hourPillar.branch] ?? "?"

        let genderText = gender == "男" ? "乾造" : "坤造"

        var text = ""
        text += "═══════════════════════\n"
        text += "    \(genderText)八字命盘\n"
        text += "═══════════════════════\n"
        text += "出生时间：\(year)年\(month)月\(day)日 \(hour)时\n\n"

        text += "年柱：\(yearPillar.stem)\(yearPillar.branch) (\(yearNaYin)金)\n"
        text += "月柱：\(monthPillar.stem)\(monthPillar.branch) (\(monthNaYin))\n"
        text += "日柱：\(dayPillar.stem)\(dayPillar.branch) (\(dayNaYin))\n"
        text += "时柱：\(hourPillar.stem)\(hourPillar.branch) (\(hourNaYin))\n\n"

        let dayMaster = dayPillar.stem
        let dayElem = BaZiCalculator.heavenlyStemsElement[dayMaster] ?? "?"
        text += "日主：\(dayMaster) (\(dayElem))\n"
        text += "═══════════════════════\n"

        // Ten Gods for each pillar
        text += "\n【十神】\n"
        text += "年干十神：\(getTenGod(dayMaster: dayMaster, targetStem: yearPillar.stem))\n"
        text += "月干十神：\(getTenGod(dayMaster: dayMaster, targetStem: monthPillar.stem))\n"
        text += "日干十神：日主/元男\n"
        text += "时干十神：\(getTenGod(dayMaster: dayMaster, targetStem: hourPillar.stem))\n"

        // Hidden stems
        text += "\n【藏干】\n"
        text += "年支藏干：\(BaZiCalculator.hiddenStems[yearPillar.branch]?.joined(separator: "、") ?? "无")\n"
        text += "月支藏干：\(BaZiCalculator.hiddenStems[monthPillar.branch]?.joined(separator: "、") ?? "无")\n"
        text += "日支藏干：\(BaZiCalculator.hiddenStems[dayPillar.branch]?.joined(separator: "、") ?? "无")\n"
        text += "时支藏干：\(BaZiCalculator.hiddenStems[hourPillar.branch]?.joined(separator: "、") ?? "无")\n"

        // NaYin
        text += "\n【纳音】\n"
        text += "年柱纳音：\(yearNaYin)\n"
        text += "月柱纳音：\(monthNaYin)\n"
        text += "日柱纳音：\(dayNaYin)\n"
        text += "时柱纳音：\(hourNaYin)\n"

        return text
    }

    private func getTenGod(dayMaster: String, targetStem: String) -> String {
        guard let masterInfo = BaZiCalculator.tenGodsMap[dayMaster],
              let targetElem = BaZiCalculator.heavenlyStemsElement[targetStem] else {
            return "未知"
        }

        // If same element as day master → 比肩 (simplified: in reality depends on yin/yang polarity)
        if targetElem == BaZiCalculator.heavenlyStemsElement[dayMaster] {
            return "比肩"
        }

        // Check detailed mapping
        let value = masterInfo[targetElem]
        if let elemMap = value as? [String: String] {
            return elemMap[targetStem] ?? "未知"
        }
        if let simple = value as? String {
            return simple
        }

        return "待考"
    }

    // MARK: - Personality Analysis

    private func generatePersonalityAnalysis(dayMaster: String) -> String {
        let elem = BaZiCalculator.heavenlyStemsElement[dayMaster] ?? "?"

        var text = "═══════════════════════\n"
        text += "    【性格分析】\n"
        text += "═══════════════════════\n\n"
        text += "日主\(dayMaster)(\(elem))："

        switch elem {
        case "木":
            text += "木主仁，命主心性仁慈善良，性格正直，有进取心和开拓精神。如参天大树，志向远大，追求成长与发展。为人耿直、有原则，不轻易妥协。具有领导才能和创造力，适合从事教育、医疗、环保、文化艺术等行业。\n\n"
            text += "但木过旺则固执己见，刚愎自用，容易钻牛角尖。木弱则优柔寡断，缺乏主见，需要增强自信心。"
        case "火":
            text += "火主礼，命主热情奔放，待人接物彬彬有礼。性格开朗外向，精力充沛，具有强烈的感染力和号召力。思维敏捷，反应迅速，在社交场合如鱼得水。适合从事演艺、传媒、公关、科技等需要表现力和创造力的行业。\n\n"
            text += "但火过旺则急躁冲动，容易意气用事，缺乏耐心。火弱则缺乏活力和热情，容易萎靡不振，需要激励和推动。"
        case "土":
            text += "土主信，命主忠厚诚实，守信用讲义气。性格稳重踏实，做事有计划有条理，是值得信赖的伙伴。为人宽厚包容，有大局观和长远眼光。适合从事房地产、建筑、农业、食品、金融等稳健型行业。\n\n"
            text += "但土过旺则保守顽固，缺乏变通，过于墨守成规。土弱则缺乏主心骨，容易随波逐流，需要建立坚定的信念。"
        case "金":
            text += "金主义，命主刚毅果断，有正义感和担当精神。性格坚毅，做事雷厉风行，追求效率和结果。逻辑思维能力强，善于分析和决断。适合从事法律、金融、军事、机械制造、精密技术等行业。\n\n"
            text += "但金过旺则冷酷严苛，缺乏人情味，容易得罪人。金弱则优柔寡断，缺乏决断力，需要加强执行力和自信心。"
        case "水":
            text += "水主智，命主聪明睿智，思维灵活多变。性格圆融通达，适应能力强，善于在不同环境中找到生存之道。直觉敏锐，有深刻的洞察力和领悟力。适合从事咨询、研究、贸易、物流、旅游、文化等行业。\n\n"
            text += "但水过旺则漂浮不定，缺乏定力，容易三心二意。水弱则思虑过度，行动力不足，需要减少犹豫增强行动力。"
        default:
            text += "命主性格独特，不拘一格，具有多重性格特质。"
        }

        return text
    }

    // MARK: - Wealth Fortune

    private func generateWealthFortune(dayMaster: String, dayMasterElem: String) -> String {
        var text = "═══════════════════════\n"
        text += "    【财运分析】\n"
        text += "═══════════════════════\n\n"

        let wealthElement: String
        switch dayMasterElem {
        case "木": wealthElement = "土"
        case "火": wealthElement = "金"
        case "土": wealthElement = "水"
        case "金": wealthElement = "木"
        case "水": wealthElement = "火"
        default: wealthElement = "?"
        }

        text += "日主\(dayMaster)(\(dayMasterElem))，以\(wealthElement)为财星。\n\n"

        switch dayMasterElem {
        case "木":
            text += "木命人以土为财。适合通过稳健积累获取财富，如房地产投资、长期股权、农业项目等。财富增长如同树木生长，需要耐心等待和持续耕耘。\n\n"
            text += "财运旺盛的年份：逢土旺之年（辰、戌、丑、未年）财运最旺。建议在土运年份积极投资布局。\n\n"
            text += "温馨提示：投资宜长线，避免频繁操作。股票投资可选择土地资源、基建类板块。"
        case "火":
            text += "火命人以金为财。适合通过专业技能和才华变现，如技术服务、咨询顾问、金融投资等。财富获取快速但波动较大，需合理规划。\n\n"
            text += "财运旺盛的年份：逢金旺之年（申、酉年）财运最旺。适合在金融、贵金属等领域有所作为。\n\n"
            text += "温馨提示：适合短线灵活操作，但要注意风险控制。股票投资可选择金融、科技类板块。"
        case "土":
            text += "土命人以水为财。适合通过智慧和信息差获取财富，如贸易流通、知识付费、咨询服务等。财运如流水，善于周转则财源滚滚。\n\n"
            text += "财运旺盛的年份：逢水旺之年（亥、子年）财运最旺。适合拓展人脉资源，以信息优势获利。\n\n"
            text += "温馨提示：适合多元化投资，灵活调配资金。股票投资可选择消费、物流类板块。"
        case "金":
            text += "金命人以木为财。适合通过创新和开拓获取财富，如创业、研发、文化创意等。财富需要对新兴领域的敏锐嗅觉和敢为天下先的勇气。\n\n"
            text += "财运旺盛的年份：逢木旺之年（寅、卯年）财运最旺。适合在新兴行业投资布局。\n\n"
            text += "温馨提示：适合投资成长型企业和新兴赛道。股票投资可选择新能源、科技类板块。"
        case "水":
            text += "水命人以火为财。适合通过影响力和知名度获取财富，如自媒体、品牌运营、市场营销等。财如烛火，需要不断添油才能保持旺盛。\n\n"
            text += "财运旺盛的年份：逢火旺之年（巳、午年）财运最旺。适合打造个人品牌影响力。\n\n"
            text += "温馨提示：适合投资品牌消费类公司。股票投资可选择传媒、消费电子类板块。"
        default:
            text += "财星不显，需寻访专业命理师详批。"
        }

        return text
    }

    // MARK: - Career Fortune

    private func generateCareerFortune(dayMaster: String, dayMasterElem: String) -> String {
        var text = "═══════════════════════\n"
        text += "    【事业运程】\n"
        text += "═══════════════════════\n\n"

        let officerElement: String
        switch dayMasterElem {
        case "木": officerElement = "金"
        case "火": officerElement = "水"
        case "土": officerElement = "木"
        case "金": officerElement = "火"
        case "水": officerElement = "土"
        default: officerElement = "?"
        }

        text += "日主\(dayMaster)(\(dayMasterElem))，以\(officerElement)为官星（事业星）。\n\n"

        switch dayMasterElem {
        case "木":
            text += "木命以金为官，金克木而成器。事业上需要通过严格的自律和规范来实现突破，适合在体制内或大型企业中发展。\n"
            text += "有利岗位：管理岗位、金融行业、法律行业、军队公安系统。\n"
            text += "事业黄金期：申酉年（猴年、鸡年）官运亨通。\n"
            text += "事业贵人：金属性之人或属猴、属鸡之人。"
        case "火":
            text += "火命以水为官，水克火而济功。事业上需要以柔克刚，善于协调各方关系，适合管理、行政、人力资源等岗位。\n"
            text += "有利岗位：行政管理、公关协调、教育行业、公益事业。\n"
            text += "事业黄金期：亥子年（猪年、鼠年）官运亨通。\n"
            text += "事业贵人：水属性之人或属猪、属鼠之人。"
        case "土":
            text += "土命以木为官，木克土而成形。事业上需要创新思维和开拓精神，适合创业、项目管理、产品开发等需要创造力的岗位。\n"
            text += "有利岗位：项目经理、产品经理、创业者、建筑师。\n"
            text += "事业黄金期：寅卯年（虎年、兔年）事业上升期。\n"
            text += "事业贵人：木属性之人或属虎、属兔之人。"
        case "金":
            text += "金命以火为官，火克金而成器。事业上需要热情和表现力，适合市场、销售、演艺、媒体等需要影响力的岗位。\n"
            text += "有利岗位：市场营销、品牌策划、演艺娱乐、公共演讲。\n"
            text += "事业黄金期：巳午年（蛇年、马年）事业腾飞。\n"
            text += "事业贵人：火属性之人或属蛇、属马之人。"
        case "水":
            text += "水命以土为官，土克水而成形。事业上需要扎实的基础和稳固的平台，适合技术、研究、财务、后勤等需要深耕的岗位。\n"
            text += "有利岗位：技术研发、财务审计、学术研究、基础建设。\n"
            text += "事业黄金期：辰戌丑未年（龙狗牛羊年）事业稳步上升。\n"
            text += "事业贵人：土属性之人或属龙、属狗、属牛、属羊之人。"
        default:
            text += "事业运程需具体分析八字全局。"
        }

        return text
    }

    // MARK: - Marriage Fortune

    private func generateMarriageFortune(dayMaster: String, dayMasterElem: String,
                                          allPillars: [Pillar]) -> String {
        var text = "═══════════════════════\n"
        text += "    【姻缘分析】\n"
        text += "═══════════════════════\n\n"

        let dayBranch = allPillars[2].branch

        // Check spouse palace (日支)
        text += "配偶宫：\(dayBranch)（\(BaZiCalculator.earthlyBranchesElement[dayBranch] ?? "?")）\n\n"

        let spouseElem = BaZiCalculator.earthlyBranchesElement[dayBranch] ?? "?"

        // Relationship between day master element and spouse palace element
        if spouseElem == dayMasterElem {
            text += "配偶宫与日主五行相同，代表夫妻志趣相投，价值观接近。婚姻生活和谐稳定，宛如知己。但需注意双方性格可能过于相似，缺少互补，需培养各自的独立空间。\n\n"
        } else if isGenerating(generator: spouseElem, receiver: dayMasterElem) {
            text += "配偶宫生助日主，代表另一半对你关怀备至，在生活和事业上对你多有助益。贵人运旺，婚后运势往往有所提升。要懂得珍惜和感恩对方。\n\n"
        } else if isGenerating(generator: dayMasterElem, receiver: spouseElem) {
            text += "日主生配偶宫，代表你为家庭和伴侣付出较多，是家中的支柱。需要注意不过度操劳，学会与伴侣分享责任和快乐。\n\n"
        } else if isControlling(controller: spouseElem, controlled: dayMasterElem) {
            text += "配偶宫克制日主，代表另一半性格强势，家庭中对方主导较多。需要学会沟通和妥协的艺术，互相尊重才能长久。建议多培养共同的兴趣爱好。\n\n"
        } else if isControlling(controller: dayMasterElem, controlled: spouseElem) {
            text += "日主克制配偶宫，代表你在感情中占主导地位。另一半对你有较强的依赖和仰慕。需避免过于强势，给对方足够的安全感和尊重。\n\n"
        }

        // General marriage advice
        text += "【姻缘建议】\n"
        text += "1. 选择与日主五行相生相合的伴侣，婚姻更为美满。\n"
        text += "2. 避开日支相冲之年结婚（\(dayBranch)的冲支为\(oppositeBranch(dayBranch))）。\n"
        text += "3. 感情需要经营，无论命带何种格局，真诚和尊重才是长久之道。\n"

        return text
    }

    // MARK: - Health Reading

    private func generateHealthReading(dayMaster: String, dayMasterElem: String,
                                        allPillars: [Pillar]) -> String {
        var text = "═══════════════════════\n"
        text += "    【健康运程】\n"
        text += "═══════════════════════\n\n"

        // Count five elements in chart
        var elemCount: [String: Int] = ["木": 0, "火": 0, "土": 0, "金": 0, "水": 0]
        for pillar in allPillars {
            if let e = BaZiCalculator.heavenlyStemsElement[pillar.stem] {
                elemCount[e, default: 0] += 1
            }
            if let e = BaZiCalculator.earthlyBranchesElement[pillar.branch] {
                elemCount[e, default: 0] += 1
            }
        }

        // Check for missing/weak elements
        let missing = elemCount.filter { $0.value == 0 }.map { $0.key }
        let strong = elemCount.filter { $0.value >= 3 }.map { $0.key }

        text += "八字五行分布：\n"
        for (elem, count) in elemCount.sorted(by: { $0.key < $1.key }) {
            let emoji = CharWuxingLoader.shared.elementEmoji(element: elem)
            let bar = String(repeating: "█", count: count)
            text += "\(emoji) \(elem)：\(bar) (\(count))\n"
        }

        if !missing.isEmpty {
            text += "\n缺失五行：\(missing.joined(separator: "、"))。缺\(missing.joined(separator: "、"))需注意"
            for m in missing {
                switch m {
                case "木": text += "肝胆、筋骨方面"
                case "火": text += "心血管、眼睛方面"
                case "土": text += "脾胃、消化系统方面"
                case "金": text += "呼吸系统、大肠方面"
                case "水": text += "肾脏、泌尿系统方面"
                default: break
                }
                text += "。"
            }
        }

        if !strong.isEmpty {
            text += "\n\n五行过旺：\(strong.joined(separator: "、"))。五行讲究平衡，过旺则"
            for s in strong {
                switch s {
                case "木": text += "肝胆火旺"
                case "火": text += "心火上炎"
                case "土": text += "脾胃积滞"
                case "金": text += "肺气过燥"
                case "水": text += "肾水泛滥"
                default: break
                }
                text += "。"
            }
        }

        text += "\n\n【养生建议】\n"
        text += "1. 顺应四季变化，春夏养阳，秋冬养阴。\n"
        text += "2. 根据五行偏颇，选择相宜的饮食和运动。\n"
        text += "3. 保持心情舒畅，七情过度皆可伤身。\n"
        text += "4. 定期体检，预防胜于治疗。\n"

        return text
    }

    // MARK: - Summary

    private func generateSummary(dayMaster: String, dayMasterElem: String, gender: String) -> String {
        var text = "═══════════════════════\n"
        text += "    【综合运势】\n"
        text += "═══════════════════════\n\n"

        text += "以上八字分析由「股半仙」根据传统命理学推算，仅供娱乐参考。\n\n"
        text += "命由天定，运由己造。八字乃先天格局，后天努力更显重要。\n"
        text += "愿施主洞悉己命，顺势而为，积德行善，福报自来。\n\n"
        text += "阿弥陀佛，善哉善哉。"

        return text
    }

    // MARK: - Helpers

    private func isGenerating(generator: String, receiver: String) -> Bool {
        let cycle = ["木": "火", "火": "土", "土": "金", "金": "水", "水": "木"]
        return cycle[generator] == receiver
    }

    private func isControlling(controller: String, controlled: String) -> Bool {
        let cycle = ["木": "土", "土": "水", "水": "火", "火": "金", "金": "木"]
        return cycle[controller] == controlled
    }

    private func oppositeBranch(_ branch: String) -> String {
        let pairs: [String: String] = ["子": "午", "午": "子", "丑": "未", "未": "丑",
                                        "寅": "申", "申": "寅", "卯": "酉", "酉": "卯",
                                        "辰": "戌", "戌": "辰", "巳": "亥", "亥": "巳"]
        return pairs[branch] ?? "?"
    }

    // MARK: - Helper: extract birth info from user text

    /// Try to extract birth year, month, day, hour from natural language Chinese text.
    /// Returns (year, month, day, hour, gender) or nil if not found.
    func extractBirthInfo(from text: String) -> (year: Int, month: Int, day: Int, hour: Int, gender: String)? {
        var year: Int?
        var month: Int?
        var day: Int?
        var hour: Int?
        var gender = "男"

        // Detect gender
        if text.contains("女") { gender = "女" }

        // Extract year (4-digit)
        let yearPattern = try? NSRegularExpression(pattern: "(\\d{4})\\s*年", options: [])
        if let match = yearPattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) {
                year = Int(text[range])
            }
        }
        // Also try bare 4-digit year
        if year == nil {
            let yearPattern2 = try? NSRegularExpression(pattern: "(19\\d{2}|20\\d{2})", options: [])
            if let match = yearPattern2?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    year = Int(text[range])
                }
            }
        }

        // Extract month
        let monthPattern = try? NSRegularExpression(pattern: "(\\d{1,2})\\s*月", options: [])
        if let match = monthPattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) {
                month = Int(text[range])
            }
        }

        // Extract day
        let dayPattern = try? NSRegularExpression(pattern: "(\\d{1,2})\\s*[日号]", options: [])
        if let match = dayPattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) {
                day = Int(text[range])
            }
        }

        // Extract hour
        // Match "X点" or "X时" or "X:00"
        let hourPattern = try? NSRegularExpression(pattern: "(\\d{1,2})\\s*[点时:]", options: [])
        if let match = hourPattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) {
                hour = Int(text[range])
            }
        }
        // Also try two-number time like "15:30" or "15：30"
        if hour == nil {
            let timePattern = try? NSRegularExpression(pattern: "(\\d{1,2})[：:]\\d{2}", options: [])
            if let match = timePattern?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    hour = Int(text[range])
                }
            }
        }

        // Also try Chinese shichen names
        let shichenMap: [String: Int] = ["子时": 0, "丑时": 2, "寅时": 4, "卯时": 6,
                                          "辰时": 8, "巳时": 10, "午时": 12, "未时": 14,
                                          "申时": 16, "酉时": 18, "戌时": 20, "亥时": 22]
        for (name, h) in shichenMap {
            if text.contains(name) {
                hour = h
                break
            }
        }

        guard let y = year, let m = month, let d = day, let h = hour else {
            return nil
        }

        guard m >= 1 && m <= 12, d >= 1 && d <= 31, h >= 0 && h <= 23 else {
            return nil
        }

        return (y, m, d, h, gender)
    }
}
