# 更新日志

本文件按时间倒序记录本次自主升级的改动。更细的逐轮记录见
`.autonomous-upgrade/UPGRADE_LOG.md`。

---

## [1.1.0-dev] — 2026-11-10

本次为「安全与体验」并行升级，共 6 个提交。**未发布正式版本**（不发版是
刻意的：没有真机验证前不应对外发布）。

### 安全

- **签名口令移出仓库**：`build.gradle` 不再硬编码密码，改为读取
  `android/keystore/key.properties`（已 gitignore）。文件缺失时 release 产物
  不签名并给出 warning，而不是报错。
- **密钥轮换但不换证书**：口令替换为随机 24 字符，证书 SHA-256 保持
  `4B:0E:72:06:...:D5:17`，老用户可覆盖升级。
- **备份泄露面收窄**：`allowBackup=false` + `fullBackupContent=false` +
  `dataExtractionRules` 排除 `sharedpref`、`.cookies/`、根目录，cloud-backup
  与 device-transfer 两侧都排除。
- **API Key 与 RSA 私钥迁入系统密钥库**（新增 `flutter_secure_storage`）：
  此前二者明文存放在 `SharedPreferences`，root 设备可直接读取私钥并长期冒用
  身份。现在走 Android Keystore / iOS Keychain，启动时自动迁移旧明文并删除副本；
  密钥库不可用时降级为普通存储并告警，不阻断登录。
- **日志脱敏**：`authorization`、`cookie`、`set-cookie`、`user-api-key`、
  `x-csrf-token` 一律打码；Cloudflare cookie 只输出长度。
- **401 单次处理**：会话过期只处理一次，清 cookie / API Key / 缓存后回登录页，
  不会同时弹出多个提示。

### 修复

- **重试被平方放大**：`RetryInterceptor` 曾在同一条拦截器链上注册两次，
  实际重试次数被平方。已移除重复注册，并补测试断言「重复注册后仍只调用 3 次」。
- **帖子详情空列表越界**：主题帖子全部被删除或权限受限时 `posts[0]` 抛
  `RangeError` 导致白屏，已改为判空。
- **空态文案被丢弃**：`StateView.empty(message: ...)` 的 `message` 参数从未被
  使用，所有调用方传的自定义文案都无效（影响收藏、热门、关注等页面）。
- **错误态配图错误**：错误态复用了「空状态」插图，已改用 `state-net-error`。
- **`CachedImage` 空指针与单位混用**：`circle=true` 且未指定宽高时 `height!.w`
  抛异常；圆角计算里 `width!.w` 与 `width!` 混用导致 screenutil 二次缩放。
- **`getChatBg()` 指向不存在的文件**：代码写 `chat-background.png`，实际文件是
  `chat-backgroud.png`（上游拼写错误）。
- **主题切换丢失样式**：`changeTheme` 与 `main.dart` 用 `copyWith(primaryColor:)`
  会把 AppBar/TabBar 等自定义样式打回默认。新增 `AppTheme.withPrimaryColor()`
  只覆盖主色相关字段。
- **`_checkCloudflareEnabled` 错误默认值**：请求失败时误判为「未启用」，已改为
  沿用上次结果并加 5 分钟缓存。

### 新增

- **更新检查**：`lib/net/update_checker.dart`，GitHub Releases 为主、旧接口兜底，
  下载地址只接受 https + GitHub 系域名白名单，非可信地址一律忽略。
- **DoH 真接入**：此前是纯 UI 开关，零调用方。现通过
  `HttpClient.connectionFactory` 接管 DNS 解析，改配置即时重建 client。
- **消息长轮询**：从固定 3 秒轮询改为服务端长轮询（`timeout=25`），失败指数退避
  2→60 秒，前后台切换自动暂停/恢复；通知按 `notification_type` 生成「谁 + 做了
  什么」，点击通知直达对应帖子。
- **深链**：支持 `linuxdo://` 与 `https://linux.do/t|/u|/c`，冷启动链接暂存到
  首页就绪后消费，不抢占授权回调与其他域名。
- **分享入站**：其他 App「分享文本」时，命中 linux.do 帖子链接直达帖子，否则进
  发帖页预填正文（新增 `MainActivity` MethodChannel 承接 `ACTION_SEND`）。
- **草稿自动保存**：输入停顿 3 秒自动落盘、离开页面立刻保存（原来只有手动点保存，
  直接返回会丢内容）；恢复前检查编辑区是否已有内容，避免覆盖用户输入。
- **崩溃记录**（`CrashReporter`）：`FlutterError.onError` +
  `PlatformDispatcher.onError` + `runZonedGuarded`，只写应用私有目录，**不上传
  任何数据**，超过 256KB 自动截断。
- **图片解码降采样**：`CachedImage` 新增 `memCacheWidth/Height`，按设备像素比
  推导，避免列表头像按原图分辨率解码导致 OOM。

### 性能与体积

- 6 张大图 PNG → WebP 并按显示尺寸降分辨率：**6348 KB → 334 KB（-94.7%）**。
  原图移动到 `assets/design/source/`（不删除，仅移出打包范围）。
- release APK：**52.5 MB → 45.4 MB**。
- 移除 4 个零引用直接依赖：`keframe`、`flutter_layout_grid`、
  `flutter_highlighter`、`markdown`。

### 工程

- 新增 CI：`format → analyze → test → build + 16KB 对齐校验`，产物上传 APK 与
  symbols。iOS workflow 摘除「自动上传到 GitHub Release」的步骤。
- `pubspec.lock` 入库；SDK 下限提到 `>=3.9.0`。
- `targetSdk 33 → 35`；升级 `cronet_http 1.10.1`、`mobile_scanner 7.5.0`，
  使所有 arm64 native 库满足 16KB 页对齐。
- 全量应用 `dart format`（tall 风格，因 SDK 下限提升而切换）。
- 新增 `CONTRIBUTING.md`、测试 39 项（10 → 49）。

### 测试

- `flutter analyze`：**0 error / 0 warning**（warning 从 108 清零）。
- `flutter test`：**49/49 通过**。
- `flutter build apk --release`：成功；`apksigner` v2+v3 通过；arm64 全部
  `LOAD align ≥ 0x4000`。

---

## 升级前状态（基线，供对照）

- `targetSdk 33`（Play 已要求 35）
- 部分 arm64 native 库 `LOAD align = 0x1000`，在 16KB 页设备上会启动即崩溃
- 签名口令硬编码在 `build.gradle`
- `RetryInterceptor` 重复注册
- 更新检查接口已失效（指向的地址不再返回）
- DoH 只有 UI 开关，无任何实现
- 消息推送固定 3 秒轮询
- 2 个单元测试文件，10 个用例
- 108 个 analyzer warning
