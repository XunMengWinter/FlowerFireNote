# 2026-06-13 SwiftData 收藏功能

## 改动
- 新增 `FavoritePost` SwiftData 本地收藏模型，保存图文快照、远程图片 URL、头像 URL、图片宽高、样式、卡片尺寸、来源和收藏时间。
- 在 App 根部注入 `FavoritePost` 的 SwiftData model container。
- 将首页卡片和详情页爱心统一接入 SwiftData 收藏状态，点击爱心只收藏/取消收藏，不写回 Unsplash，也不本地改写来源点赞数。
- 将“我的”页面从占位改为收藏页，支持空状态和两列收藏图文流，并可从收藏页进入详情。

## 验证
- `xcodebuild -project FlowerFireNote3.xcodeproj -scheme FlowerFireNote3 -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` 通过。
- `xcrun simctl install booted .../FlowerFireNote3.app` 与 `xcrun simctl launch booted pet.zzz.FlowerFireNote3` 通过，应用已在 iPhone 17 模拟器启动。
- 通过运行时 UI 快照验证：首页进入详情后点击爱心，首页卡片变为“取消收藏”，“我的”页显示 1 条收藏；重启 App 后收藏仍保留；在“我的”页取消收藏后恢复“还没有收藏”空状态。
