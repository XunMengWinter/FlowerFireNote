# AGENTS.md

## Product
这是一个 SwiftUI iOS 摄影/插画社区 App，名称为“花火记”。

## 设计稿
参考 OpenDesign 设计稿：
- OpenDesignFFN/huahuoji-ios-home.html
- OpenDesignFFN/home.html
- OpenDesignFFN/detail.html
- OpenDesignFFN/publish.html

## 技术约束
- 首页 TabView 使用系统默认方案
- 不主动引入第三方库；当前已批准的例外是 Swift Package `https://github.com/kean/Nuke.git`，仅使用 `NukeUI` / `LazyImage` 做远程图片加载
- 如使用 ObservableObject，请 import Combine

## 页面与导航
- 底部 Tab 保持 `首页` / `发布` / `我的` 三个入口，不新增“收藏”底部 Tab。
- `TabView` 使用系统默认方案；为避免不同 Tab 的导航栏显隐互相影响，每个 Tab 应各自持有 `NavigationStack`。
- 首页和发布页如使用自定义顶部区域，可在各自导航栈内隐藏系统导航栏。
- “我的”Tab 直接显示收藏内容，并使用 SwiftUI 默认系统标题栏，标题为“我的收藏”；不要再额外实现自定义顶部标题栏替代系统标题栏。
- 图文详情页可以隐藏系统导航栏，继续使用当前自定义详情顶部栏与返回按钮。

## 数据与图片加载
- 首页已接入 Unsplash `GET /search/photos`，数据入口集中在 `UnsplashFeedStore`
- Unsplash 请求使用 public authentication：`Authorization: Client-ID <Access Key>` 与 `Accept-Version: v1`
- Unsplash Access Key 当前按用户要求直接写入 `UnsplashConfig.accessKey`；不要写入或要求 Unsplash Secret Key
- 首页搜索框和频道切换必须发起远程搜索，不要退化成本地过滤已加载卡片
- 首页分页追加时按 Unsplash photo id 去重，避免 SwiftUI diff 出现重复 id
- Unsplash 返回的 `width` / `height` 应用于卡片和详情图比例，不要固定裁切破坏瀑布流
- 点赞、评论等互动仅保持本地 UI 状态，不写回 Unsplash
- `Package.resolved` 是 SwiftPM 依赖锁文件，应保留在 git 中

## 收藏
- 收藏功能使用本地 SwiftData 实现，模型为 `FavoritePost`；不接后端，不写回 Unsplash。
- 爱心按钮表示本地收藏状态，首页卡片、图文详情页和“我的”收藏页必须共享同一份收藏状态。
- 收藏时保存图文快照，确保从“我的”收藏页进入详情后，即使取消收藏，当前详情内容也能保持到用户返回。
- “我的”Tab 的收藏页为空时显示“还没有收藏”；有收藏时显示两列收藏流，并继续使用远程图片 URL 与原图比例。

## 交付要求
- 使用 SwiftUI 原生实现，不使用 WebView 承载 HTML
- 当前首页可接入远程图片数据；发布页和我的页除非明确要求，仍保持页面/本地状态，不扩展后端数据接入
- 每次任务完成时，将本次改动以 markdown 格式写入到 logs 文件夹
- 确保在 iPhone 17 模拟器下可编译成功
- 运行过程中产生的临时文件请不要放入 git
