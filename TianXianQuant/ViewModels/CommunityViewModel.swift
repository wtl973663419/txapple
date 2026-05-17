import SwiftUI
import Observation

@Observable
final class CommunityViewModel {
    var posts: [Post] = []
    var selectedCategory: String = "全部"
    var isLoading: Bool = false

    let categories = ["全部", "技术分析", "基本面", "量化策略", "复盘笔记", "新手交流"]

    func loadPosts() {
        isLoading = true
        posts = CommunityViewModel.mockPosts()
        isLoading = false
    }

    var filteredPosts: [Post] {
        if selectedCategory == "全部" {
            return posts
        }
        return posts.filter { $0.category == selectedCategory }
    }

    func filterByCategory(_ category: String) {
        selectedCategory = category
    }

    func likePost(id: String) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].likes += 1
    }

    func addPost(title: String, content: String, category: String) {
        let newPost = Post(
            id: "post_\(UUID().uuidString.prefix(8))",
            author: "当前用户",
            userId: "me",
            avatar: "person.circle.fill",
            title: title,
            content: content,
            time: "刚刚",
            likes: 0,
            comments: 0,
            category: category,
            isVip: false,
            images: [],
            commentList: []
        )
        posts.insert(newPost, at: 0)
    }

    func addComment(postId: String, content: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let newComment = Comment(
            id: "comment_\(UUID().uuidString.prefix(8))",
            postId: postId,
            author: "当前用户",
            authorAvatar: "person.circle.fill",
            content: content,
            time: "刚刚",
            likes: 0,
            isLiked: false
        )
        posts[index].commentList.append(newComment)
        posts[index].comments = posts[index].commentList.count
    }

    func likeComment(postId: String, commentId: String) {
        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard let commentIndex = posts[postIndex].commentList.firstIndex(where: { $0.id == commentId }) else { return }
        if posts[postIndex].commentList[commentIndex].isLiked {
            posts[postIndex].commentList[commentIndex].isLiked = false
            posts[postIndex].commentList[commentIndex].likes -= 1
        } else {
            posts[postIndex].commentList[commentIndex].isLiked = true
            posts[postIndex].commentList[commentIndex].likes += 1
        }
    }

    // MARK: - Mock Data

    static func mockPosts() -> [Post] {
        [
            Post(
                id: "p1",
                author: "量化猎手",
                userId: "u1",
                avatar: "person.circle.fill",
                title: "MACD金叉+放量突破，这个标的值得关注",
                content: "今天复盘发现一只票，日线级别MACD零轴上方金叉，同时成交量放大到5日均量的2.3倍。周线级别也站上了20周均线，短期趋势看多。\n\n基本面方面，该股属于新能源赛道，一季报超预期，PE回落至合理区间。建议在回调至5日线附近低吸，止损位设在20日均线下方3%。\n\n另外值得注意的是，北向资金连续3日净买入，机构席位也有明显介入迹象。",
                time: "2小时前",
                likes: 128,
                comments: 15,
                category: "技术分析",
                isVip: true,
                images: [],
                commentList: [
                    Comment(id: "c1_1", postId: "p1", author: "股市小虾米", authorAvatar: "person.circle.fill", content: "学习了！MACD金叉确实是个好信号，但也要注意大环境。", time: "1小时前", likes: 23, isLiked: false),
                    Comment(id: "c1_2", postId: "p1", author: "趋势为王", authorAvatar: "person.circle.fill", content: "北向资金的数据在哪里看的？我一直用东方财富。", time: "30分钟前", likes: 8, isLiked: false),
                    Comment(id: "c1_3", postId: "p1", author: "量化猎手", authorAvatar: "person.circle.fill", content: "回复@趋势为王：东方财富和同花顺都可以，我习惯用Wind。", time: "15分钟前", likes: 5, isLiked: false)
                ]
            ),
            Post(
                id: "p2",
                author: "价值投资者",
                userId: "u2",
                avatar: "person.circle.fill",
                title: "深度分析：白酒板块的估值回归逻辑",
                content: "白酒板块经历了近两年的调整，目前整体PE已经回到25倍以下的合理区间。头部企业如茅台、五粮液的股息率已经超过3%，具备较好的防守属性。\n\n从行业库存周期来看，渠道库存去化接近尾声，批价企稳回升。下半年随着消费刺激政策落地，板块有望迎来估值修复行情。\n\n重点推荐：高端白酒（茅台、五粮液）+ 地产酒龙头（古井贡酒、今世缘）。",
                time: "5小时前",
                likes: 256,
                comments: 42,
                category: "基本面",
                isVip: true,
                images: [],
                commentList: [
                    Comment(id: "c2_1", postId: "p2", author: "白酒信仰", authorAvatar: "person.circle.fill", content: "同意！茅台现在这个价格确实有性价比了。", time: "4小时前", likes: 45, isLiked: false),
                    Comment(id: "c2_2", postId: "p2", author: "理性投资", authorAvatar: "person.circle.fill", content: "不过消费降级趋势还在，短期可能还会震荡。", time: "3小时前", likes: 18, isLiked: false)
                ]
            ),
            Post(
                id: "p3",
                author: "算法大师",
                userId: "u3",
                avatar: "person.circle.fill",
                title: "分享一个双均线突破策略，回测年化35%+",
                content: "最近在优化均线策略，发现EMA(12)+EMA(26)+MACD组合在A股市场表现不错。\n\n策略逻辑：\n1. EMA12上穿EMA26形成金叉\n2. MACD柱状线由负转正\n3. 成交量大于20日均量的1.5倍\n4. 股价站上20日均线\n\n回测2019-2024，年化收益35.6%，最大回撤18.2%，夏普比率1.82。\n\n注意：策略在震荡市中表现一般，需要结合大盘趋势过滤。源码放评论区了。",
                time: "8小时前",
                likes: 398,
                comments: 67,
                category: "量化策略",
                isVip: true,
                images: [],
                commentList: [
                    Comment(id: "c3_1", postId: "p3", author: "Python股民", authorAvatar: "person.circle.fill", content: "大佬能分享下源码吗？最近在学量化。", time: "7小时前", likes: 52, isLiked: false),
                    Comment(id: "c3_2", postId: "p3", author: "算法大师", authorAvatar: "person.circle.fill", content: "源码放GitHub了，搜txquant_cn/ema_strategy。", time: "6小时前", likes: 38, isLiked: false),
                    Comment(id: "c3_3", postId: "p3", author: "量化小白", authorAvatar: "person.circle.fill", content: "夏普1.82确实不错，但是35%的年化可能有过拟合风险吧？", time: "5小时前", likes: 12, isLiked: false)
                ]
            ),
            Post(
                id: "p4",
                author: "盘手日记",
                userId: "u4",
                avatar: "person.circle.fill",
                title: "今日复盘：半导体领涨，AI概念再度活跃",
                content: "今天大盘缩量震荡，上证收涨0.32%，创业板涨1.15%。板块方面：\n\n强势板块：半导体(+3.2%)、AI算力(+2.8%)、消费电子(+1.9%)\n弱势板块：地产(-1.5%)、银行(-0.8%)、建材(-0.6%)\n\n涨停家数：47家（含ST 12家）\n跌停家数：8家\n\n个人操作：早盘减仓了银行，加仓了半导体ETF。明天关注AI板块能否继续走强。",
                time: "12小时前",
                likes: 185,
                comments: 31,
                category: "复盘笔记",
                isVip: false,
                images: [],
                commentList: [
                    Comment(id: "c4_1", postId: "p4", author: "短线高手", authorAvatar: "person.circle.fill", content: "半导体这波确实强，我早盘买了北方华创。", time: "11小时前", likes: 28, isLiked: false),
                    Comment(id: "c4_2", postId: "p4", author: "盘手日记", authorAvatar: "person.circle.fill", content: "回复@短线高手：北方华创是好票，我也在关注。", time: "10小时前", likes: 15, isLiked: false)
                ]
            ),
            Post(
                id: "p5",
                author: "新韭菜上路",
                userId: "u5",
                avatar: "person.circle.fill",
                title: "新手求教：如何设置合理的止损位？",
                content: "入市三个月了，总是赚小钱亏大钱。每次都是跌了舍不得卖，结果越套越深。想请教各位前辈：\n\n1. 止损位一般设多少合适？（5%? 8%? 10%?）\n2. 是固定止损还是移动止损？\n3. 碰到急跌直接穿止损价怎么办？\n\n感谢各位大佬指点！",
                time: "1天前",
                likes: 89,
                comments: 56,
                category: "新手交流",
                isVip: false,
                images: [],
                commentList: [
                    Comment(id: "c5_1", postId: "p5", author: "老股民老张", authorAvatar: "person.circle.fill", content: "建议新手用8%止损，严格执行，不要扛单。", time: "23小时前", likes: 67, isLiked: false),
                    Comment(id: "c5_2", postId: "p5", author: "风控第一", authorAvatar: "person.circle.fill", content: "移动止损更好，盈利后用最高价回落3%作为止盈/止损。", time: "20小时前", likes: 41, isLiked: false),
                    Comment(id: "c5_3", postId: "p5", author: "量化猎手", authorAvatar: "person.circle.fill", content: "急跌穿止损直接市价卖，少亏就是赚。纪律比技术重要！", time: "18小时前", likes: 55, isLiked: false)
                ]
            ),
            Post(
                id: "p6",
                author: "财报分析",
                userId: "u6",
                avatar: "person.circle.fill",
                title: "一季报梳理：这些公司业绩超预期",
                content: "整理了近期一季报超预期的公司，按行业分类：\n\n新能源：宁德时代（净利同比+32%）、阳光电源（+45%）\n半导体：中芯国际（营收环比+18%）、韦尔股份（扭亏）\n医药：药明康德（+25%）、恒瑞医药（+30%）\n消费：贵州茅台（+15%）、海天味业（+8%）\n\n整体来看，科技和医药板块的业绩弹性最大，消费板块稳健增长。建议关注业绩拐点明确的个股。",
                time: "1天前",
                likes: 312,
                comments: 48,
                category: "基本面",
                isVip: true,
                images: [],
                commentList: [
                    Comment(id: "c6_1", postId: "p6", author: "数据说话", authorAvatar: "person.circle.fill", content: "很详细的梳理！宁德这个增速确实超预期。", time: "22小时前", likes: 34, isLiked: false),
                    Comment(id: "c6_2", postId: "p6", author: "医药爱好者", authorAvatar: "person.circle.fill", content: "恒瑞的业绩拐点终于来了，熬了很久了。", time: "20小时前", likes: 26, isLiked: false)
                ]
            ),
            Post(
                id: "p7",
                author: "涨停板猎手",
                userId: "u7",
                avatar: "person.circle.fill",
                title: "打板心得：如何提高封板率？",
                content: "打板两年了，总结几点经验分享给大家：\n\n1. 首板优于连板：首板封板率高，炸板率低\n2. 板块效应：有板块联动的板成功率更高\n3. 量能配合：封板成交量需高于前日150%以上\n4. 避开尾盘板：下午2:30以后的板第二天溢价差\n5. 关注龙虎榜：有知名游资介入的板更有溢价\n\n最重要的是：控制仓位！单票不超过20%仓位，错了果断止损。",
                time: "2天前",
                likes: 445,
                comments: 89,
                category: "复盘笔记",
                isVip: true,
                images: [],
                commentList: [
                    Comment(id: "c7_1", postId: "p7", author: "追板小王子", authorAvatar: "person.circle.fill", content: "学习了！第4点确实深有同感，尾盘板坑太多了。", time: "1天前", likes: 78, isLiked: false),
                    Comment(id: "c7_2", postId: "p7", author: "稳健派", authorAvatar: "person.circle.fill", content: "打板风险还是太大，不适合普通散户。", time: "1天前", likes: 32, isLiked: false),
                    Comment(id: "c7_3", postId: "p7", author: "涨停板猎手", authorAvatar: "person.circle.fill", content: "回复@稳健派：确实，新手还是先从趋势交易入手比较稳。", time: "20小时前", likes: 21, isLiked: false)
                ]
            )
        ]
    }
}
