import SwiftUI

struct StockDetailSheet: View {
    let stock: StockInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    // OHLC Grid
                    ohlcGrid

                    // Valuation metrics
                    valuationSection

                    // Deep analysis
                    if let analysis = deepAnalysisData {
                        deepAnalysisSection(analysis)
                    }
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle(stock.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(stock.code)
                .font(.caption)
                .foregroundColor(.appTextHint)

            Text(stock.price.priceString)
                .font(.system(size: 36, weight: .bold))
                .stockColor(stock.isUp)

            HStack(spacing: 8) {
                Text(stock.changePercent.percentString)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(stock.isUp ? Color.appChipRed.opacity(0.2) : Color.appChipGreen.opacity(0.2))
                    )
                    .foregroundColor(stock.isUp ? .appStockUp : .appStockDown)

                Text("成交量: \(stock.volume.volumeString)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - OHLC Grid

    private var ohlcGrid: some View {
        VStack(spacing: 0) {
            Text("OHLC 数据")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ohlcItem(label: "开盘", value: stock.open.priceString, color: .appTextPrimary)
                ohlcItem(label: "昨收", value: stock.yesterdayClose.priceString, color: .appTextSecondary)
                ohlcItem(label: "最高", value: stock.high.priceString, color: .appStockUp)
                ohlcItem(label: "最低", value: stock.low.priceString, color: .appStockDown)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func ohlcItem(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.appTextHint)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(color)
        }
        .padding(10)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(8)
    }

    // MARK: - Valuation

    private var valuationSection: some View {
        VStack(spacing: 8) {
            Text("估值指标")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                metricItem(label: "市盈率(PE)", value: stock.pe > 0 ? String(format: "%.2f", stock.pe) : "--")
                metricItem(label: "市净率(PB)", value: stock.pb > 0 ? String(format: "%.2f", stock.pb) : "--")
                metricItem(label: "换手率", value: stock.turnover > 0 ? String(format: "%.2f%%", stock.turnover) : "--")
                metricItem(label: "总市值", value: stock.marketCap > 0 ? (stock.marketCap / 1_0000_0000).volumeString + "亿" : "--")
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func metricItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextHint)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(8)
    }

    // MARK: - Deep Analysis

    private func deepAnalysisSection(_ analysis: DeepAnalysis) -> some View {
        VStack(spacing: 12) {
            Text("深度分析")
                .font(.caption.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            analysisRow(label: "护城河", value: analysis.moat)
            Divider().background(Color.appDivider)
            analysisRow(label: "行业地位", value: analysis.industryPosition)
            Divider().background(Color.appDivider)
            analysisRow(label: "销售状况", value: analysis.salesStatus)
            Divider().background(Color.appDivider)
            analysisRow(label: "生产状况", value: analysis.productionStatus)
            Divider().background(Color.appDivider)
            analysisRow(label: "机构观点", value: analysis.institutionView)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func analysisRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.appPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Deep Analysis Data

    private var deepAnalysisData: DeepAnalysis? {
        if let existing = stock.deepAnalysis {
            return existing
        }
        return StockDetailSheet.hardcodedAnalysis[stock.code]
    }

    static let hardcodedAnalysis: [String: DeepAnalysis] = [
        "600519": DeepAnalysis(
            moat: "品牌壁垒极强，国酒地位不可撼动。高端白酒市场占有率超过50%，消费者心智占领度高，具有极强的定价权。",
            industryPosition: "白酒行业绝对龙头，市值超2万亿，营收和利润规模遥遥领先于第二名五粮液。",
            salesStatus: "直销渠道占比持续提升，i茅台数字营销平台贡献增量。经销商渠道稳定，终端动销良好，库存处于合理水平。",
            productionStatus: "茅台镇核心产区产能有限，供不应求格局长期存在。基酒产能稳步释放，系列酒产能扩张中。",
            institutionView: "北向资金持续配置，公募基金重仓股。机构目标价集中在1800-2000元区间，看好长期价值增长。"
        ),
        "000858": DeepAnalysis(
            moat: "浓香型白酒代表，品牌价值深厚。与茅台形成双寡头格局，次高端市场优势明显。",
            industryPosition: "白酒行业第二，浓香型品类第一。产品矩阵丰富，覆盖高端到中低端全价格带。",
            salesStatus: "渠道改革成果显现，批价逐步回升。团购渠道发力，数字化营销体系建设中。",
            productionStatus: "纯粮固态发酵产能充足，优质酒出酒率稳步提升。酿酒专用粮基地建设完善。",
            institutionView: "机构认为估值处于历史低位，具有较好的安全边际。看好中秋国庆旺季催化。"
        ),
        "300750": DeepAnalysis(
            moat: "动力电池技术全球领先，CTP3.0麒麟电池技术壁垒高。客户覆盖全球主流车企，规模效应显著。",
            industryPosition: "全球动力电池市占率约37%，连续多年全球第一。国内市占率超过45%。",
            salesStatus: "海外市场快速拓展，欧洲工厂产能爬坡。国内市场订单饱满，储能业务高速增长。",
            productionStatus: "全球化产能布局完善，锂矿自供比例提升。回收技术行业领先，成本控制能力强。",
            institutionView: "机构普遍看好储能第二增长曲线，认为估值已进入合理区间。关注锂价波动对毛利率的影响。"
        ),
        "002594": DeepAnalysis(
            moat: "垂直整合一体化生产模式，成本优势突出。DM-i超级混动技术行业领先，技术储备深厚。",
            industryPosition: "国内新能源汽车销量冠军，市占率约35%。全球新能源汽车销量前二。",
            salesStatus: "多品牌战略(仰望、方程豹、腾势)覆盖全价格带。海外出口爆发式增长，泰国、巴西工厂建设中。",
            productionStatus: "整车产能充裕，刀片电池自供比例高。半导体业务拆分上市推进中。",
            institutionView: "机构认为智能驾驶能力被低估，仰望品牌提升了品牌溢价。关注高端化战略执行效果。"
        ),
        "688981": DeepAnalysis(
            moat: "中国大陆技术最先进、规模最大的晶圆代工厂。国产替代核心标的，国家战略支撑。",
            industryPosition: "全球晶圆代工第五，大陆第一。先进制程14nm已量产，N+1/N+2工艺推进中。",
            salesStatus: "产能利用率触底回升，中国客户订单增长迅速。成熟制程产能吃紧，价格趋稳。",
            productionStatus: "四条12英寸生产线，8英寸线满产运行。CAPEX投入巨大，设备国产化比例提升。",
            institutionView: "机构看好国产替代长期趋势，短期受行业周期影响。关注先进制程突破进度和设备管制风险。"
        ),
        "002415": DeepAnalysis(
            moat: "全球安防行业龙头，AI技术积累深厚。完整的物联网解决方案提供商，渠道覆盖全球。",
            industryPosition: "全球视频监控市场份额第一（~25%），海外收入占比超过30%。",
            salesStatus: "EBG和SMBG业务恢复增长，海外新兴市场增长强劲。创新业务(萤石、机器人)增速亮眼。",
            productionStatus: "智能制造能力行业领先，自研AI芯片降低成本。柔性产线可快速响应市场需求。",
            institutionView: "机构认为制裁影响已充分消化，AI大模型赋能安防场景。关注海外业务恢复进度。"
        ),
        "601318": DeepAnalysis(
            moat: "金融+科技双轮驱动，综合金融集团。保险+银行+资管全牌照布局，客户基数庞大。",
            industryPosition: "保险行业综合实力第一，寿险和产险均为行业前二。平安银行零售之王。",
            salesStatus: "寿险改革进入收获期，代理人质态改善。产险综合成本率行业领先，银行净息差稳定。",
            productionStatus: "科技专利数行业领先，AI辅助核保理赔。金融壹账通和陆金所科技输出。",
            institutionView: "机构认为估值处于历史底部，利空出清后有望修复。关注地产风险敞口化解进度。"
        ),
        "600036": DeepAnalysis(
            moat: "零售银行龙头，财富管理护城河深。零售客户AUM规模行业第一，客户粘性高。",
            industryPosition: "股份制银行中营收和利润规模第一。私行业务市场领先，数字化银行标杆。",
            salesStatus: "净息差优于同业，非息收入占比持续提升。零售贷款风险可控，拨备覆盖充足。",
            productionStatus: "科技投入行业领先，APP月活超1亿。风控模型成熟，不良贷款率处于低位。",
            institutionView: "机构看好经济复苏下零售信贷需求改善。关注地产下行对公业务影响。"
        ),
        "300274": DeepAnalysis(
            moat: "光伏逆变器全球龙头，储能系统技术领先。全球化布局完善，品牌优势明显。",
            industryPosition: "全球光伏逆变器出货量前二，国内储能系统市占率第一。电站投资开发规模领先。",
            salesStatus: "海外收入占比超过60%，欧美市场毛利率高。储能业务爆发式增长，订单饱满。",
            productionStatus: "产能全球化布局(印度、泰国)，供应链管理能力强。IGBT等核心器件国产化推进。",
            institutionView: "机构认为储能业务高增长可持续，逆变器毛利率有望维持。关注海外贸易政策风险。"
        ),
        "601012": DeepAnalysis(
            moat: "单晶硅片全球龙头，技术路线引领行业。垂直一体化布局，成本控制能力突出。",
            industryPosition: "全球硅片和组件出货量前二，BC电池技术领先。氢能装备布局前瞻。",
            salesStatus: "组件出货量全球领先，分布式市场占有率高。氢能业务起步阶段，增长潜力大。",
            productionStatus: "单晶生长技术行业领先，非硅成本持续下降。N型电池产能快速释放。",
            institutionView: "机构看好BC技术差异化优势，但行业产能过剩竞争加剧。关注盈利拐点。"
        ),
        "300124": DeepAnalysis(
            moat: "工业自动化龙头，伺服系统市占率第一。新能源车电驱电控技术领先。",
            industryPosition: "国内工业自动化行业第一，伺服系统和低压变频器市占率超20%。",
            salesStatus: "通用自动化业务受制造业周期影响，新能源汽车电驱业务高速增长。",
            productionStatus: "研发投入占比超10%，掌握核心算法。产能弹性大，可快速响应客户需求。",
            institutionView: "机构看好长期国产替代趋势，短期受制造业周期波动影响。关注人形机器人业务进展。"
        ),
        "002230": DeepAnalysis(
            moat: "AI语音技术全球领先，星火大模型国内前三。教育、医疗、智慧城市场景落地领先。",
            industryPosition: "中文语音市场市占率超过60%，AI开放平台开发者数量第一。",
            salesStatus: "智慧教育收入占比最高，GBC三端联动。开放平台和消费者业务快速增长。",
            productionStatus: "AI研发投入占比超20%，技术储备深厚。算力基础设施持续投入，自研芯片推进中。",
            institutionView: "机构看好星火大模型商业化落地，但短期烧钱模式承压。关注教育信息化政策支持。"
        ),
        "688111": DeepAnalysis(
            moat: "国产办公软件龙头，WPS Office用户粘性高。信创+云化双驱动，替代MS Office空间大。",
            industryPosition: "国内办公软件市占率第一，个人用户超5亿。政企市场市占率超90%。",
            salesStatus: "个人订阅收入高速增长，政企信创订单稳定。AI功能商业化推进(收费版AI助手)。",
            productionStatus: "云文档和协作办公功能持续迭代。AI大模型深度集成到WPS产品线。",
            institutionView: "机构看好AI对于WPS的提价和增购驱动。关注信创预算落地节奏。"
        ),
        "300059": DeepAnalysis(
            moat: "互联网券商龙头，天天基金网流量优势。券商+基金代销双轮驱动，用户规模第一。",
            industryPosition: "互联网券商综合实力第一，股基交易市场份额持续提升。基金代销规模行业前三。",
            salesStatus: "市场成交活跃度影响经纪业务收入。基金代销尾随佣金收入稳定，AI投顾产品推进中。",
            productionStatus: "研发投入行业领先，自研交易系统延时低。移动端月活超2000万，用户体验优秀。",
            institutionView: "机构看好AI应用提升用户粘性和付费率。关注市场成交量和监管政策变化。"
        ),
    ]
}

#Preview {
    StockDetailSheet(stock: StockDetailSheet.hardcodedAnalysis.keys.first.map {
        StockInfo(code: $0, name: $0, price: 100.0, changePercent: 1.5, volume: 1_000_000, deepAnalysis: nil)
    } ?? StockInfo(code: "600519", name: "贵州茅台", price: 1680.50, changePercent: 1.25, volume: 3_200_000, deepAnalysis: nil))
}
