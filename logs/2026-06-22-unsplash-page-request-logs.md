# 2026-06-22 Unsplash 首页分页请求日志

- 为首页 Unsplash 数据流添加分页请求日志。
- 初始加载和加载更多都会在 Debug 控制台输出请求页码、query、perPage、成功返回数量、实际追加数量、总页数、当前两列数量和失败原因。
- 本记录仅描述分页请求日志改动；自动分页触发修复见 `2026-06-22-unsplash-user-scroll-pagination-guard.md`。
