# 待办与下一轮优先事项

## 进行中

（无）

## P0 — 功能实际失效（用户可感知）

- [ ] **应用更新通道失效**：`ld.rrrc.me` NXDOMAIN，`home_controller.dart:200` 是唯一更新源。
      方案：改为可配置的更新源 + GitHub Releases API 兜底；校验 APK 签名证书指纹后才允许安装提示。
- [ ] **DoH 是假开关**：`DohService.resolve()` 零调用。方案二选一：
      (a) 在 `IOHttpTransport` 用 `HttpClient.connectionFactory` 真接线；
      (b) 若无法可靠接线，移除设置项，避免"设置骗人"。

## P1 — 核心体验缺陷

- [ ] **MessageBus 是 3 秒轮询而非长轮询**：`_poll()` 末尾固定 `Timer(3s)`。
      应改为服务端 `timeout` 长轮询 + 指数退避 + 前后台启停（`WidgetsBindingObserver`）。
- [ ] **通知内容未解析**：固定文案"有人回复了你的话题"，应解析 `data` 生成标题/摘要，点击跳转对应帖子。
- [ ] **深链缺失**：`linuxdo://` 与 `https://linux.do/t/...` 无 intent-filter，App 内外链接无法互相唤起。

## P2 — UI / UX

- [ ] 空状态与错误状态检查：多个页面只有 loading，无区分。
- [ ] `CachedImage` 未设 `memCacheWidth`，长列表头像按原尺寸解码 → 内存与 jank 风险。
- [ ] assets 大图未压缩：`profile-header-bg.png` 3.0MB、`profile-header.jpg` 1.4MB、`search-banner.png` 0.77MB×2。

## P3 — 功能扩展（参考开源项目后决定）

- [ ] 草稿箱（当前仅单条草稿 `create_post_draft`）
- [ ] 离线缓存（列表页 + 详情页）
- [ ] 阅读进度记忆
- [ ] 分享进（ACTION_SEND / 分享 linux.do 链接到 App）

## P4 — 架构 / 性能

- [ ] Repository 层拆分（Topic / User / Auth / Notification）
- [ ] 统一存储抽象（SecureStore / CacheStore）
- [ ] 拆 `html_widget.dart`（2676 行）为 PostBody / PostPoll / PostQuote
- [ ] 移除无直接引用的依赖：`keframe`、`cupertino_icons`、`flutter_layout_grid`、`flutter_highlighter`、`markdown`

## P5 — 文档与开发者体验

- [ ] 补充 API 契约测试
- [ ] 补充 CONTRIBUTING.md
- [ ] 崩溃上报（`FlutterError.onError` + `PlatformDispatcher.onError` 本地环形日志）

## 已验证不可行 / 需外部条件

- `permission_handler` 13.x：`permission_handler_android 14.1.1` 要求 `compileSdk = 37`，
  当前只装到 android-36，已回退到 12.0.1。升级需先装 API 37 平台。
- 真机 / 真实账号端到端验证：需要设备与账号，静态分析与单测无法替代。