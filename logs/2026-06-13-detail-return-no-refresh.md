# 2026-06-13 详情返回首页防刷新

- 修复从详情页返回首页时 `HomeView.task` 重新执行导致首页列表清空并闪动的问题。
- 新增 `UnsplashFeedStore.reloadIfNeeded(query:)`，同一远程查询且已有内容时跳过 reload。
- 搜索框和频道切换仍会在查询变化时触发 Unsplash 远程搜索。
