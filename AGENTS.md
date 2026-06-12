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

## 数据与图片加载
- 首页已接入 Unsplash `GET /search/photos`，数据入口集中在 `UnsplashFeedStore`
- Unsplash 请求使用 public authentication：`Authorization: Client-ID <Access Key>` 与 `Accept-Version: v1`
- Unsplash Access Key 当前按用户要求直接写入 `UnsplashConfig.accessKey`；不要写入或要求 Unsplash Secret Key
- 首页搜索框和频道切换必须发起远程搜索，不要退化成本地过滤已加载卡片
- 首页分页追加时按 Unsplash photo id 去重，避免 SwiftUI diff 出现重复 id
- Unsplash 返回的 `width` / `height` 应用于卡片和详情图比例，不要固定裁切破坏瀑布流
- 点赞、评论等互动仅保持本地 UI 状态，不写回 Unsplash
- `Package.resolved` 是 SwiftPM 依赖锁文件，应保留在 git 中

## 交付要求
- 使用 SwiftUI 原生实现，不使用 WebView 承载 HTML
- 当前首页可接入远程图片数据；发布页和我的页除非明确要求，仍保持页面/本地状态，不扩展后端数据接入
- 每次任务完成时，将本次改动以 markdown 格式写入到 logs 文件夹
- 确保在 iPhone 17 模拟器下可编译成功
- 运行过程中产生的临时文件请不要放入 git
