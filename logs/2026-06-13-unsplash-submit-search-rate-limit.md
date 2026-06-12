# 2026-06-13 搜索提交与额度保护

- 首页搜索框改为按键盘 Search 提交后才触发 Unsplash 远程搜索，输入过程不再逐字请求。
- `SearchField` 增加 `.submitLabel(.search)` 和提交回调。
- Unsplash 403 `Rate Limit Exceeded` 识别为额度用完状态，展示明确提示并暂停自动加载更多。
