# 2026-06-22 Unsplash 自动分页滚动门禁

- 修复首页打开后 footer `onAppear` 连续触发 Unsplash 分页请求的问题。
- 保留现有两列瀑布流结构，不改为 `LazyVGrid`；外层滚动内容改为 `LazyVStack`，让 footer 作为懒加载哨兵。
- 自动加载更多现在由末尾卡片出现触发，并且必须同时满足用户已拖动滚动、触发卡片属于当前末尾候选、store 允许分页；每次触发加载后都会重置滚动门禁。
- footer 保留一个手动“加载更多”按钮作为兜底，避免自动触发未命中时用户无法继续分页。
- 加载初始页和分页加载期间的拖动不会预授权下一次自动分页，避免串行连续请求。
- 移除基于 `PreferenceKey` 的底部位置监听，避免运行时出现 `Bound preference LoadMoreSentinelMinYPreferenceKey tried to update multiple times per frame` 警告。
- 瀑布流分列策略改为优先保持两列 item 数差不超过 1，数量相等时再按估算高度选择较短列。
