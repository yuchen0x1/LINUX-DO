# 下一阶段升级计划

> 前提说明：本轮所有改动只有**静态分析 + 单元测试 + 构建级**证据，没有真机或
> 模拟器验证。因此下一阶段的优先级不是「加功能」，而是**先把手上的改动验证完**。

---

## P0 —— 必须真机验证（阻塞后续一切发布）

这些功能已写进代码并编译进 APK，但它们的正确性只能在设备上确认。
**在完成这些之前，不应发布任何版本。**

| # | 验证项 | 怎么验 | 失败时看哪里 |
|---|---|---|---|
| 1 | 密钥库迁移不丢登录 | 装旧版 → 登录（走 User API Key 授权）→ 覆盖安装新版 → 确认仍是登录态 | `SecureStore._load` 的迁移分支；`l.w('迁移 … 失败')` |
| 2 | 深链唤起 | `adb shell am start -a android.intent.action.VIEW -d "https://linux.do/t/<slug>/<id>"` | `DeepLinkService.resolve` 与 `_flushPending` |
| 3 | 通知点击跳转 | 真实触发一条提醒（他人回复/提及），点通知 | `MessageBusService._onNotificationTap` 的 payload 解析 |
| 4 | 分享入站 | 从浏览器/微信选「分享到 LINUX DO」 | `MainActivity.extractSharedText` 与 `ShareIntentService.classify` |
| 5 | 长轮询不耗电 | 前台静置 10 分钟看电量曲线；切后台确认轮询停止 | `handleLifecycle` 与 `_schedulePoll` 的退避值 |
| 6 | DoH 实际生效 | 开 DoH 后抓包确认没有明文 DNS 查询 | `proxy_service._applyDoh` 的 `connectionFactory` |
| 7 | 16KB 页设备启动 | 有 16KB 页机型/模拟器时确认冷启动正常 | 若崩溃看 `libbarhopper` 之外的库 |

---

## P1 —— 已知缺陷与安全加固

| # | 问题 | 说明 |
|---|---|---|
| 1 | **权限判定靠状态码** | 调研发现同类项目的坑：`can_tag_topics` 对游客 false、对登录 TL1 用户 true；用「接口是否 403」推断权限会在游客态与登录态得出相反结论。应显式读 `current_user.can_*` |
| 2 | **阅读位置 key 无上限** | `topic_post_<id>` 每读一个帖子留一个 int，长期使用会持续增长。可加 LRU 上限（如只保留最近 200 个） |
| 3 | `isSecureAvailable` 为 false 时的用户提示 | 目前只在日志里告警，用户不知道自己的密钥退回了普通存储。设置页应显示状态 |
| 4 | 单槽位草稿 | 现在只有一份草稿，第二次新建会覆盖第一次。多草稿箱需要列表页 + 按 id 存取 |
| 5 | `html_widget.dart` 未拆分 | 2676 行单文件。见 P3-1 |

---

## P2 —— 待真机确认的性能项

来自同类项目 `forumcopilot/discourse-app` 的性能审计（`docs/perf-audit-2026-09.md`），
其前两条我们尚未自查：

1. **列表是否虚拟化**：检查主题列表是不是 `ListView(children: [...])` 一次性构建全部行。
   若是，改 `CustomScrollView` + `SliverList.builder`。
2. **每行重复计算**：`withEmojiShortcodes`、时间格式化是否在 `build()` 里重算。
   应下沉到模型层或用 id 做缓存。
3. 我们已修的第 4 条（头像按原图解码）与其审计结论一致。

---

## P3 —— 结构性重构（有明确收益但风险高）

### P3-1 拆分 `lib/widgets/html/html_widget.dart`（2676 行）

建议拆法（按职责，不要按行数平均切）：

```
widgets/html/
├── html_widget.dart          # 只保留入口与 dispatch
├── inline/                   # 行内标签：a / code / emoji / strong
├── block/                    # 块级：p / list / quote / heading
├── media/                    # img / video / iframe / 附件
├── table/                    # 表格（含 flutter_html_table 适配）
└── policy/                   # 公约/规则类特殊块
```

**风险**：HTML 渲染是核心路径，任何拆分都可能引入难以察觉的布局回归。
建议先补 3–5 个 golden 截图测试再动手。

### P3-2 网络层去掉对路由层的依赖

`message_bus_service.dart` 与 `share_intent_service.dart` 直接 `Get.toNamed`，
`deep_link_service.dart` 里还用字面量路由名绕开循环依赖。建议引入一个
`NavigatorPort` 抽象（接口放在 `net/`，实现放在 `pages/`），让网络层只依赖接口。

### P3-3 Repository 分层

当前 controller 直接调 `ApiService`（78 个端点），业务规则散落在 controller 里。
可先给「主题列表」「帖子详情」「用户资料」三条主链路加 Repository，其余保持不动。

---

## P4 —— 工具链升级（有明确时间窗）

构建时已有三条 warning：

| 组件 | 当前 | Flutter 要求 | 备注 |
|---|---|---|---|
| Gradle | 8.14.3 | ≥ 9.1.0 | 需同时确认所有插件兼容 |
| AGP | 8.11.1 | ≥ 9.0.1 | AGP 9 有较大行为变更 |
| Kotlin | 2.2.20 | ≥ 2.3.20 | |

建议顺序：**Kotlin → Gradle → AGP**，每步单独验证构建与 16KB 对齐，不要一次性跳。

其他：

- `permission_handler` 仍锁 12.0.1。13.x 的 android 包要求 `compileSdk 37`，本机只装了
  android-36，升级前需先装 SDK 37。
- Windows 上 `flutter pub get` 提示需要开启「开发者模式」才能用符号链接构建插件。
  Android 构建不受影响，但 Windows/macOS 桌面端构建会受阻。

---

## P5 —— 体验补齐（用户可感知）

| # | 功能 | 现状 |
|---|---|---|
| 1 | 离线缓存最近浏览的帖子 | 无 |
| 2 | 多草稿箱 | 单槽位 |
| 3 | 「导出诊断信息」入口 | `CrashReporter.readRecent()` 已就绪，缺 UI |
| 4 | 通知免打扰时段 | 有设置页，未与 MessageBus 联动 |
| 5 | 图片上传前压缩 | 直接用原图上传，同类项目用 `flutter_image_compress` |

---

## 明确不做的事

| 候选 | 原因 |
|---|---|
| 引入 `forumcopilot_sdk` | 与现有 78 个 Retrofit 端点重复，迁移成本远大于收益 |
| 参考 `w4mxl/V2LF` 代码 | GPL-3.0 传染性 + 停更 4 年 |
| 参考 `xuemk/linuxdo-android` 代码 | 仓库无 LICENSE，默认保留所有权利 |
| 把 `net` 层整体改成 Riverpod | 与现有 GetX 体系冲突，收益不明确 |
