import SwiftUI

struct InspirationPost: Identifiable, Hashable {
    enum VisualStyle: String, CaseIterable, Hashable {
        case window
        case studio
        case film
        case garden
        case desk
        case night

        var gradientColors: [Color] {
            switch self {
            case .window:
                return [HuahuoTheme.sky, .white.opacity(0.92), HuahuoTheme.lilac]
            case .studio:
                return [HuahuoTheme.rose, HuahuoTheme.butter, HuahuoTheme.mint]
            case .film:
                return [HuahuoTheme.peach, HuahuoTheme.rose, HuahuoTheme.lilac]
            case .garden:
                return [HuahuoTheme.mint, HuahuoTheme.butter, HuahuoTheme.sky]
            case .desk:
                return [HuahuoTheme.lilac, .white.opacity(0.92), HuahuoTheme.rose]
            case .night:
                return [HuahuoTheme.sky, HuahuoTheme.lilac, HuahuoTheme.rose]
            }
        }
    }

    enum CardSize: String, Hashable {
        case short
        case medium
        case tall

        var aspectRatio: CGFloat {
            switch self {
            case .short: 1 / 0.86
            case .medium: 1 / 1.08
            case .tall: 1 / 1.34
            }
        }

        var heightWeight: Double {
            switch self {
            case .short: 0.86
            case .medium: 1.08
            case .tall: 1.34
            }
        }
    }

    var id: String
    var title: String
    var author: String
    var likes: Int
    var style: VisualStyle
    var size: CardSize
    var copy: String
    var liked: Bool
    var imageURL: URL?
    var detailImageURL: URL?
    var imageWidth: Int?
    var imageHeight: Int?
    var photoPageURL: URL?
    var authorAvatarURL: URL?
    var sourceName: String

    init(
        id: String = UUID().uuidString,
        title: String,
        author: String,
        likes: Int,
        style: VisualStyle,
        size: CardSize,
        copy: String,
        liked: Bool = false,
        imageURL: URL? = nil,
        detailImageURL: URL? = nil,
        imageWidth: Int? = nil,
        imageHeight: Int? = nil,
        photoPageURL: URL? = nil,
        authorAvatarURL: URL? = nil,
        sourceName: String = "花火记"
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.likes = likes
        self.style = style
        self.size = size
        self.copy = copy
        self.liked = liked
        self.imageURL = imageURL
        self.detailImageURL = detailImageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.photoPageURL = photoPageURL
        self.authorAvatarURL = authorAvatarURL
        self.sourceName = sourceName
    }

    var imageAspectRatio: CGFloat {
        guard let imageWidth, let imageHeight, imageWidth > 0, imageHeight > 0 else {
            return size.aspectRatio
        }
        return CGFloat(imageWidth) / CGFloat(imageHeight)
    }

    var attributionText: String {
        if sourceName == "Unsplash" {
            return "Photo by \(author) · Unsplash"
        }
        return "花火记 · 摄影 / 插画灵感"
    }

    var tags: [String] {
        switch style {
        case .window:
            return ["#窗边光影", "#蓝调摄影", "#安静插画"]
        case .studio:
            return ["#奶油色系", "#花束拍摄", "#日常布景"]
        case .film:
            return ["#胶片感", "#低饱和调色", "#街角灵感"]
        case .garden:
            return ["#薄荷绿", "#春日配色", "#封面灵感"]
        case .desk:
            return ["#桌面拼贴", "#相纸便签", "#创作日常"]
        case .night:
            return ["#雨夜光影", "#淡紫色", "#氛围记录"]
        }
    }

    var comments: [PostComment] {
        let topic = tags.first?.replacingOccurrences(of: "#", with: "") ?? "灵感"
        return [
            PostComment(name: "南枝", text: "这个\(topic)好温柔，想拿来做下一组手账封面。", time: "刚刚"),
            PostComment(name: "小盐", text: "留白比例很舒服，收藏了，周末照着试一组。", time: "12 分钟前")
        ]
    }

    var heightWeight: Double {
        let imageWeight: Double
        if let imageWidth, let imageHeight, imageWidth > 0, imageHeight > 0 {
            imageWeight = min(max(Double(imageHeight) / Double(imageWidth), 0.72), 1.58)
        } else {
            imageWeight = size.heightWeight
        }
        return imageWeight + Double((title.count + 9) / 10) * 0.16
    }

    static let samples: [InspirationPost] = [
        InspirationPost(
            title: "窗边一束蓝调光，适合画安静人物",
            author: "阿岚",
            likes: 128,
            style: .window,
            size: .tall,
            copy: "把白纱窗和浅蓝阴影留出来，人物只用一点暖粉做脸颊，画面会有很轻的呼吸感。适合做头像、日记插画或摄影情绪板。"
        ),
        InspirationPost(
            title: "奶油黄背景里的小花束拍法",
            author: "椿野",
            likes: 96,
            style: .studio,
            size: .medium,
            copy: "用低饱和黄色垫纸做背景，花束不要摆正，留一角空白给手写字。成片更像随手记录，而不是商品图。"
        ),
        InspirationPost(
            title: "胶片颗粒感：别把阴影提太亮",
            author: "Momo",
            likes: 214,
            style: .film,
            size: .short,
            copy: "阴影保留一点密度，亮部用柔和奶白压住，颗粒才会像真实胶片。适合咖啡店、街角和傍晚窗口。"
        ),
        InspirationPost(
            title: "薄荷绿 + 珊瑚粉，春天封面组合",
            author: "六月",
            likes: 183,
            style: .garden,
            size: .tall,
            copy: "薄荷绿负责清爽，珊瑚粉只放在标题或小物件上。两种颜色都别铺满，画面会更像轻插画杂志页。"
        ),
        InspirationPost(
            title: "桌面拼贴：相纸、便签和一枚夹子",
            author: "栗子",
            likes: 77,
            style: .desk,
            size: .medium,
            copy: "先定一个主照片，再用便签和色块做边角。元素数量控制在三种以内，留白比贴满更有 Pinterest 感。"
        ),
        InspirationPost(
            title: "雨后路灯可以这样画成淡紫色",
            author: "星回",
            likes: 142,
            style: .night,
            size: .short,
            copy: "路灯不要用纯黄，混一点淡紫灰，雨后的空气会更柔。地面反光用长条形，不要画得太均匀。"
        ),
        InspirationPost(
            title: "拍插画本时，让手指只出现一点点",
            author: "小满",
            likes: 65,
            style: .studio,
            size: .short,
            copy: "手指只压住纸角，能给画面增加真实使用感。背景保持浅色，插画本的色彩自然成为主角。"
        ),
        InspirationPost(
            title: "一张照片拆出三组头像配色",
            author: "南风",
            likes: 201,
            style: .window,
            size: .tall,
            copy: "从照片里抽取背景、中间调和点缀色，再分别给头像的衣服、肤色和小饰品。这样配色会自然很多。"
        ),
        InspirationPost(
            title: "用圆角色块画出可爱的旅行票根",
            author: "山茶",
            likes: 118,
            style: .garden,
            size: .medium,
            copy: "票根边缘不用追求真实，圆角和浅色块更适合日常记录。加一行日期和地点，就能形成完整的小故事。"
        ),
        InspirationPost(
            title: "夜晚橱窗：只保留两处高光",
            author: "苒苒",
            likes: 156,
            style: .film,
            size: .tall,
            copy: "高光太多会散，保留橱窗灯和玻璃反射两处就够。其余部分用低对比粉紫过渡，画面更安静。"
        )
    ]
}

struct PostComment: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var text: String
    var time: String
}
