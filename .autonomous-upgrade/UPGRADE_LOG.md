# 升级日志

> 记录每一轮实际落地的改动、验证方式与遗留问题。规则：**未运行验证的条目不记入「已完成」**。
> 所有验证命令均在 Windows 10 + Flutter 3.50.0-0.3.pre / Dart 3.13.7 下执行。

---

## Round 1 — 安全与合规基线

提交：`cccfbb9`（前一轮已入库）

| 项目 | 改动 | 验证 |
|---|---|---|
| 签名口令 | 从 `build.gradle` 硬编码改为读 `keystore/key.properties`，文件不在版本库内 | 旧口令确认失效；新口令可签 |
| 证书连续性 | 轮换密码但**不换证书** | `apksigner` 输出 SHA-256 `4B:0E:72:06:...:D5:17`，与旧版一致，老用户可覆盖升级 |
| 备份泄露面 | `allowBackup=false` + `fullBackupContent=false` + `dataExtractionRules` 排除 `sharedpref` / `.cookies/` | `aapt2 dump xmltree` 实测三项属性生效 |
| 16KB 页对齐 | 升级 `cronet_http 1.3.0→1.10.1`、`mobile_scanner 3.5.7→7.5.0`（jni 0.9.3→1.1.2） | `llvm-readelf` 逐个 lib 检查 `LOAD align ≥ 0x4000`；新增 `scripts/check_16k_alignment.sh` |
| targetSdk | 33 → 35 | `aapt2 dump badging` 显示 `targetSdkVersion:'35'` |
| 重试拦截器 | 移除重复注册（同一条链上挂了两次，重试次数被平方放大） | 新增 8 项单测，含「重复注册不放大重试次数」断言恰好 3 次调用 |
| 日志脱敏 | `authorization` / `cookie` / `user-api-key` / `x-csrf-token` 打码；CF cookie 只打长度 | 人工核对日志代码路径 |
| 401 处理 | 单次会话过期只处理一次，清 cookie / API Key / 缓存，回登录页 | 代码审查 + 无编译告警 |
| CI | 新增 `ci.yml`：format → analyze → test → build + 16KB 校验；`build_ios.yml` 摘除自动发布 | 工作流文件落盘 |
| 依赖 | `pubspec.lock` 入库；SDK 下限 `>=3.9.0`；`production` 依赖收敛 | `flutter pub get` 通过 |

**遗留**：无真机/模拟器，全部为静态与构建级验证。

---

## Round 2 — 更新通道 / DoH / 长轮询 / 深链

提交：`a818d06`

| 项目 | 改动 | 验证 |
|---|---|---|
| P0 更新通道 | `lib/net/update_checker.dart`：GitHub Releases（`yuchen0x1/LINUX-DO`）为主、旧接口兜底；`isTrustedDownload()` 只放行 https + github 系域名；`home_controller` 拒收不可信地址 | 11 项单测（semver 数值比较、预发布后缀、build number、域名白名单、明文拒绝） |
| P0 DoH 假开关 | `proxy_service._applyDoh()` 用 `HttpClient.connectionFactory` + `Socket.startConnect` 真正接管解析；网络设置页改动后调用 `applyProxy()` 重建 client | 编译通过；`Socket.startConnect` 返回类型与签名匹配 |
| P1 长轮询 | MessageBus 从固定 3s 轮询改为 `POST message-bus/{clientId}/poll?timeout=25`，`receiveTimeout=35s`；失败指数退避 `2→60s`；`handleLifecycle` 前后台暂停/恢复 | 代码审查 + 编译 |
| P1 通知内容 | 按 `notification_type` 1/2/3/5/9/12 生成「谁 + 做了什么」；点击通知带 `payload=topicId` 直达帖子 | 代码审查 |
| P1 身份补全 | `syncUserIdentity()` 拉 `session/current.json` 补 `userId`/`username`（API Key 登录流程原本不返回身份，导致通知频道订阅不到） | 代码审查 |
| P1 深链 | `lib/net/deep_link_service.dart`；`app_links 7.2.2`；manifest 加 `linuxdo` scheme 与 `linux.do` host；冷启动链接暂存至首页就绪 | 12 项单测 |
| 主题 | `AppTheme.withPrimaryColor()` 只覆盖主色相关字段，保留其余自定义样式（原实现 `copyWith(primaryColor:)` 会把 AppBar/TabBar 样式打回默认） | 编译 + 代码审查 |

**验证**：`flutter test` 33/33；`flutter analyze` 0 warning / 0 error；release APK 构建成功；`aapt2 dump xmltree` 确认 4 个 intent-filter 全部合并；`apksigner` v2+v3 通过、证书未变。

---

## Round 3 — 资源瘦身 / 图片解码 / 空态修复 / 分享入站

| 项目 | 改动 | 处理 |
|---|---|---|
| 大图压缩 | 6 张大图 PNG→WebP + 限制最大宽度：`profile-header-bg` 3045KB→23KB、`search-banner`(light/dark) 585/755KB→50/58KB、聊天背景 4 张合计 1.96MB→200KB | **6348KB → 334KB（-94.7%）** |
| 原图保留 | 全部原图 `git mv` 到 `assets/design/source/`，该目录不在 `pubspec` 声明中，不进包 | 文件未删除，仓库内可回溯 |
| 死资源 | `profile-header.jpg`（1.5MB）与 `getChatBg()`/`getChatListBg()` 无任何调用者，确认后一并移出打包范围 | 未删文件，仅移出 bundle |
| 拼写 bug | 代码引用的 `chat-background.png` 实际文件是 `chat-backgroud.png`（上游拼写错误），指向修正 | 修正为 `chat-backgroud.webp` |
| CachedImage | 新增 `memCacheWidth`/`memCacheHeight`，按 `MediaQuery.devicePixelRatioOf × 1.1` 自动推导；`cacheKey` 带尺寸避免不同展示尺寸互相顶掉解码缓存 | 长列表头像不再按原图分辨率解码 |
| CachedImage 空安全 | 原实现在 `circle=true` 且未指定宽高时 `height!.w` 会抛异常；`width!.w` 与 `width!` 单位混用（screenutil 二次缩放） | 统一走 `_shortestSide()`，无空值风险 |
| 空态文案 | `StateView.empty(message: ...)` 的 `message` 参数**被完全忽略**，永远显示默认文案；影响 `bookmark_page`/`popular_page`/`follow_page` 等 | 改为 `emptyMessage ?? 默认` |
| 错误态配图 | 错误态复用了「空状态」插图 | 改用 `state-net-error.png` |
| 分享入站 | `ACTION_SEND text/plain` 只加了 intent-filter、Dart 侧没有处理（半成品）。新增 `MainActivity.kt` MethodChannel + `lib/net/share_intent_service.dart`；命中 linux.do 帖子链接直达帖子，否则进发帖页预填正文 | 9 项单测 |

**验证**：`flutter test` **42/42**；`flutter analyze` **0 error / 0 warning**（129 info 为历史遗留）；
`flutter build apk --release` 成功，**52.5MB → 45.3MB**；`unzip -l` 确认包内只有 `.webp`、原 PNG 已不在 APK。

**踩坑记录**：Kotlin 支持**嵌套块注释**，KDoc 里写 `text/*` 会让 `/*` 再开一层注释，编译器报「Unclosed comment」。已改为行注释。

---

## Round 4 — 密钥库迁移 / 开源调研 / 16KB 校验修正

提交：`54cdf0b`

| 项目 | 改动 | 验证 |
|---|---|---|
| 密钥进系统密钥库 | 新增 `lib/utils/secure_store.dart`：User API Key + RSA 公私钥从明文 `SharedPreferences` 迁到 Android Keystore / iOS Keychain（`flutter_secure_storage 9.2.4`）。启动时自动迁移旧明文并删除副本；密钥库不可用时降级为普通存储并告警。同步读接口用内存缓存保持不变，避免异步传染到拦截器 | analyze 干净；构建通过；42 单测 |
| 调研 | `.autonomous-upgrade/OPEN_SOURCE_RESEARCH.md`：GitHub API 实时核对 6 个同类项目，含许可证判断 | 数据可复现（`curl api.github.com/...`） |
| 16KB 脚本修正 | 原脚本把 32 位 `armeabi-v7a` 的 `0x1000` 也判为 FAIL，属假警报。16KB 页要求仅适用于 64 位 ABI，已改为 FAIL 只针对 `lib/arm64-v8a/*`，32 位输出 WARN | 重跑脚本 exit=0 |

**踩坑**：Kotlin 支持**嵌套块注释**。KDoc 里写 `text/*` 会让 `/*` 再开一层注释，
编译器报 `Unclosed comment`。改为行注释后编译通过。

---

## Round 5 — 依赖清理 / 崩溃记录 / 草稿自动保存

提交：`8a1664b`

| 项目 | 改动 | 验证 |
|---|---|---|
| 依赖清理 | 移除零引用的 `keframe`、`flutter_layout_grid`、`flutter_highlighter`、`markdown`。保留 `cupertino_icons`（321 处 `CupertinoIcons` 引用）与 `flutter_markdown`（2 处）。`flutter_layout_grid` 仍由 `flutter_html_table` 间接引入 | `pub get` + analyze + 49 单测 + 构建 |
| 崩溃记录 | 新增 `CrashReporter`：`FlutterError.onError` + `PlatformDispatcher.onError` + `runZonedGuarded`。**只写应用私有目录，不上传**。超 256KB 截断为尾部 128KB；IO 失败只降级为普通日志 | analyze 干净 |
| 草稿自动保存 | 输入停顿 3 秒自动落盘、`onClose` 立刻保存。原实现只有手动点保存，直接返回会丢内容 | analyze 干净 |

**已修但需注意**：`restoreDraft()` 原本会无条件覆盖编辑区——分类是异步加载的，
用户在加载完成前输入的内容会被草稿冲掉。现改为「编辑区已有内容则跳过恢复」。

---

## Round 6 — 空列表越界 / API 契约测试 / 贡献指南 / 全量格式化

提交：`1921647`（纯格式化）、`7ff1d5e`（功能）

| 项目 | 改动 | 验证 |
|---|---|---|
| 帖子详情越界 | `fetchTopicDetail` 里 `posts[0]`、`stream[0]` 未防空。主题帖子全被删除或权限受限时 `posts` 为空，`postFrameCallback` 抛 `RangeError` 导致白屏 | analyze 干净 |
| API 契约测试 | 新增 `test/api_contract_test.dart`（7 项）：用真实 `/latest.json` 形状的固定样本锁定 snake_case → 模型字段映射，覆盖 `avatar_template` 的 `{size}` 替换、`tags` 列表、缺省字段容错、`findUserById` 未命中占位 | 7/7 通过 |
| 贡献指南 | `CONTRIBUTING.md`：环境、签名配置、提交前必过检查、代码约定、明确禁止「为通过检查而关闭 lint」 | — |
| 全量格式化 | SDK 下限提到 `>=3.9.0` 后 `dart format` 切到 tall 风格，212 个文件与格式门禁不一致 → CI 会失败。已全量格式化并单独提交 | format 检查 0 changed；analyze 128/0/0；49 单测；构建通过 |

**核实结论**：阅读进度**并非缺失**。`onClose` 已保存楼层号、`fetchTopicDetail`
会读回并定位到对应楼层。本轮只修了该链路上的越界缺陷，没有重写。

**踩坑**：`dart format .` 会走进 `build/` 下的 Gradle 缓存目录，遇到残留 transform
路径时抛 `PathNotFoundException`。CI 与本地检查都必须限定为 `lib test`。

---

## 遗留（明确未完成）

- **所有功能均无真机/模拟器端到端验证**：深链唤起、通知点击、分享入站、DoH 实际解析、
  长轮询、密钥库迁移后的登录态，只有单元测试与编译级证据。发布前必须逐项验证，
  清单见 `NEXT_UPGRADE_PLAN.md` 的 P0。
- 未做：拆分 `html_widget.dart`（2676 行）、Repository 分层、多草稿箱、离线缓存、
  Gradle 9 / AGP 9 / Kotlin 2.3 升级、权限字段显式读取。
- 遗留小问题：128 个 analyzer `info`；`armeabi-v7a/libbarhopper_v3.so` 仍为 `0x1000`
  （32 位不受约束）；阅读位置 key 无上限。

