# 2026-06-13 Unsplash 缓存与搜索状态

- Unsplash 搜索请求改为 `reloadIgnoringLocalCacheData`，并携带 `Cache-Control: no-cache`，避免本地 URL cache 影响错误恢复判断。
- `reloadIfNeeded` 改为接收首页 `queryToken`，以搜索框和频道的真实 UI 输入变化判断是否需要重新搜索。
- 修复搜索输入发生变化但最终英文 query 相同的情况下，旧逻辑误跳过远程搜索的问题。
- 分页请求也绑定当前 `queryToken`，避免旧分页响应追加到新搜索列表。
