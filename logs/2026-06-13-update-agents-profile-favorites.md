# 2026-06-13 更新 AGENTS 收藏与标题栏规则

## 改动
- 在 `AGENTS.md` 增加页面与导航约束：底部 Tab 保持首页、发布、我的；每个 Tab 各自持有 `NavigationStack`；“我的”页使用 SwiftUI 默认系统标题栏，标题为“我的收藏”。
- 在 `AGENTS.md` 增加收藏约束：收藏使用本地 SwiftData `FavoritePost`，爱心状态在首页、详情页和“我的”收藏页共享，不写回 Unsplash。

## 验证
- 本次仅更新文档与日志，未改动 Swift 源码。
