# 2026-06-13 Unsplash 分页失败重试

- 修复首页加载更多失败后 `errorMessage` 阻断后续分页重试的问题。
- `canLoadMore` 不再把当前错误提示作为分页能力判断条件，失败提示仍由首页 footer 展示并通过重试按钮再次请求下一页。
- 搜索和频道切换仍通过 `reloadIfNeeded(query:)` 发起新的 Unsplash 远程搜索，并会清理上一轮错误状态。
