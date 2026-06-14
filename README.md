# 花火记 FlowerFireNote

花火记是一款 SwiftUI 原生实现的 iOS 摄影 / 插画灵感社区 App。当前版本聚焦灵感浏览、图文详情、本地收藏和发布页交互原型。

![花火记 App 展示](docs/images/flowerfirenote-showcase.jpg)

## 功能亮点

- 首页灵感流：接入 Unsplash `GET /search/photos`，以双列瀑布流展示远程图片。
- 搜索与频道：支持搜索提交和 `今日灵感` / `摄影` / `插画` / `胶片感` / `配色` 频道切换，并发起远程搜索。
- 图文详情：保留原图比例展示图片，提供作者信息、正文、标签、评论区和底部互动栏。
- 本地收藏：使用 SwiftData 保存收藏快照，首页卡片、详情页和“我的”页共享收藏状态。
- 发布页原型：提供图片占位、标题字节限制、详情输入、保存草稿和发布按钮状态。
- 设计还原：参考 `OpenDesignFFN/` 下的 OpenDesign HTML 设计稿，使用 SwiftUI 原生界面实现。

## 技术栈

- SwiftUI
- SwiftData
- NukeUI / LazyImage
- Unsplash API
- Xcode / iOS Simulator

## 运行方式

1. 克隆仓库：

   ```bash
   git clone https://github.com/XunMengWinter/FlowerFireNote.git
   cd FlowerFireNote
   ```

2. 使用 Xcode 打开项目：

   ```bash
   open FlowerFireNote3.xcodeproj
   ```

3. 选择 iPhone 17 模拟器，运行 `FlowerFireNote3` scheme。

也可以使用命令行编译：

```bash
xcodebuild -project FlowerFireNote3.xcodeproj \
  -scheme FlowerFireNote3 \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## 数据说明

- 首页图片来自 Unsplash public API，使用 public access key 请求。
- 收藏数据仅保存在本机 SwiftData，不接后端，也不写回 Unsplash。
- 点赞、评论、关注、分享等互动目前仅作为本地 UI 状态或界面占位。
- 发布页当前是本地交互原型，不会上传图片或创建远程内容。

## 项目结构

```text
FlowerFireNote3/          SwiftUI App 源码
FlowerFireNote3.xcodeproj Xcode 工程
OpenDesignFFN/            OpenDesign 导出的设计稿与交付说明
docs/images/              README 展示图
logs/                     每次任务的 markdown 变更记录
```

## 开源说明

当前仓库尚未包含 `LICENSE` 文件。使用、分发或二次开发前，请以后续仓库中的许可文件为准。
