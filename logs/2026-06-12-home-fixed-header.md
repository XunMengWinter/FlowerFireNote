# 2026-06-12 首页固定标题和搜索

## 本次改动
- 调整首页布局层级，将标题栏和搜索框移出信息流 `ScrollView`。
- 保持频道 tags 和双列瀑布流在首页列表中一起滚动。
- 未改动详情页、发布页和底部系统 `TabView` 行为。

## 验证
- 已使用 XcodeBuildMCP 在 `iPhone 17` 模拟器目标下完成 Debug simulator build。
- 构建结果：成功，无 warnings/errors。
- 已启动 App 并执行首页滚动手势；滚动后标题栏和搜索框保持固定，频道 tags 随列表内容滚动。
