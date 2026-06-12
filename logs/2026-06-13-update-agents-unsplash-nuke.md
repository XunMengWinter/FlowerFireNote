# 2026-06-13 更新 AGENTS.md：Unsplash 与 NukeUI 约束

## 本次改动
- 将首页当前事实写入 `AGENTS.md`：首页通过 Unsplash `search/photos` 获取远程图片流。
- 明确 `UnsplashFeedStore` 是首页远程数据入口。
- 明确 `NukeUI` / `LazyImage` 是当前已批准的 Swift Package 依赖例外。
- 明确只写入 Unsplash Access Key，不写入或要求 Secret Key。
- 补充搜索、频道、分页去重、图片宽高比例、点赞本地状态和 `Package.resolved` 保留规则。
- 将旧的“第一版只做页面，无需接入数据”调整为“首页可接入远程图片数据；发布页和我的页默认不扩展后端数据接入”。

## 验证
- `git diff --check` 通过。
