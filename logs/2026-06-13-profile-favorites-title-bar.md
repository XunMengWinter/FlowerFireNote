# 2026-06-13 我的页收藏标题栏

## 改动
- 将“我的”页面顶部的品牌标题栏替换为“我的收藏”栏。
- “我的收藏”栏固定显示收藏数量，空状态和收藏列表共用同一个顶部栏。
- 移除空状态卡片中重复的“我的收藏”标题，仅保留心形图标和“还没有收藏”提示。

## 验证
- `xcodebuild -project FlowerFireNote3.xcodeproj -scheme FlowerFireNote3 -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` 通过。
