# 2026-06-13 Unsplash + NukeUI 首页图片流

## 本次改动
- 首页从本地样例过滤改为 Unsplash `search/photos` 远程图片流。
- 新增 `UnsplashConfig`、`UnsplashAPIClient`、`UnsplashFeedStore`，集中处理搜索、分页、去重、loading、error 和 retry 状态。
- 接入 Swift Package `https://github.com/kean/Nuke.git`，target 使用 `NukeUI`，通过 `LazyImage` 渲染首页卡片、详情大图和作者头像。
- `InspirationPost` 扩展远程图片 metadata：图片 URL、详情图 URL、宽高、作者头像、Unsplash 来源信息。
- 首页搜索框增加 350ms debounce；频道切换会触发对应 Unsplash query；滚动到底部附近自动加载下一页。
- 详情页改为使用远程图片，点赞仍保持本地 UI 状态，不写回 Unsplash。

## Key 处理
- 按本次要求，将 Unsplash Access Key 直接写入 `UnsplashConfig.accessKey`。
- 未接入、未写入 Unsplash Secret Key。

## 验证
- `build_sim`：iPhone 17 / Debug / `FlowerFireNote3` 编译成功，无 warning。
- `build_run_sim`：iPhone 17 模拟器启动成功，无 warning。
- 运行态检查：首页成功加载 Unsplash 标题、作者和远程图片。
- 运行态检查：输入 `window light` 后进入 loading 并刷新为新搜索结果。
- 运行态检查：滚动列表后继续显示后续远程内容，分页/懒加载路径未崩溃。
- 运行态检查：点击卡片进入详情页，详情远程大图、作者、标题、标签、评论和底部操作按钮正常显示。
