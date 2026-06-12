# 2026-06-13 详情页固定标题栏和根导航

## 本次改动
- 将 `NavigationStack` 提升到 `ContentView` 根部包裹系统 `TabView`，详情页由根导航栈承载。
- 将首页卡片详情 destination 从瀑布流懒加载布局中移到根导航层，避免详情页继续显示底部 tab。
- 将详情页顶部标题栏移出 `ScrollView`，滚动时只滚动作品、正文和评论内容。

## 验证
- 已使用 XcodeBuildMCP 在 `iPhone 17` 模拟器目标下完成 Debug simulator build。
- 构建结果：成功，无 warnings/errors。
- 已启动 App 并进入首页第一张卡片详情页；详情页 runtime snapshot 不再包含 `首页 / 发布 / 我的` tab。
- 已在详情页执行滚动手势；滚动后 `返回首页 / 关注 / 更多` 顶部标题栏仍保持可见。
