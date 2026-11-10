# 待办与下一轮优先事项

> 状态更新时间：2026-11-10（Round 6 结束）
> 详细方案见 `NEXT_UPGRADE_PLAN.md`；逐轮改动见 `UPGRADE_LOG.md`。

## P0 — 必须真机验证（阻塞发布）

代码已完成、已编译进 APK、有单测，但**没有在设备上跑过一次**。
在验证完之前不要发布任何版本。

- [ ] 密钥库迁移后登录态保持（旧版登录 → 覆盖安装新版 → 仍登录）
- [ ] 深链唤起：`adb shell am start -a android.intent.action.VIEW -d "https://linux.do/t/<slug>/<id>"`
- [ ] 通知点击跳转（真实触发一条提醒）
- [ ] 分享入站（从其他 App「分享到 LINUX DO」）
- [ ] 长轮询不耗电（前台静置 10 分钟 + 切后台确认停止）
- [ ] DoH 实际生效（抓包确认无明文 DNS）
- [ ] 16KB 页设备冷启动正常

## P1 — 已知缺陷与安全加固

- [ ] **权限判定靠状态码**：应显式读 `current_user.can_*`，不要用「接口是否 403」推断
      （同类项目在此踩过两次：游客态与登录态结论相反）
- [ ] 阅读位置 key `topic_post_<id>` 无上限，加 LRU（建议保留 200 个）
- [ ] `isSecureAvailable == false` 时用户无感知，设置页应显示密钥存储状态
- [ ] 草稿仍是单槽位，第二次新建会覆盖第一次

## P2 — 待真机确认的性能项

- [ ] 自查主题列表是否 `ListView(children: [...])` 非虚拟化（同类项目性能审计第 1 名问题）
- [ ] 自查每行是否在 `build()` 里重算 emoji 替换与时间格式化

## P3 — 结构性重构（收益明确但风险高）

- [ ] 拆 `lib/widgets/html/html_widget.dart`（2676 行）——**先补 golden 截图测试再动手**
- [ ] `net` 层去路由依赖：引入 `NavigatorPort` 抽象
- [ ] Repository 分层（先做主题列表 / 帖子详情 / 用户资料三条主链路）

## P4 — 工具链升级

- [ ] Kotlin 2.2.20 → 2.3.20（先）
- [ ] Gradle 8.14.3 → 9.1.0（后）
- [ ] AGP 8.11.1 → 9.0.1（最后；行为变更最大）
- [ ] 每步单独验证构建 + 16KB 对齐，不要一次性跳

## P5 — 体验补齐

- [ ] 离线缓存最近浏览的帖子
- [ ] 多草稿箱
- [ ] 「导出诊断信息」UI（`CrashReporter.readRecent()` 已就绪）
- [ ] 免打扰时段与 MessageBus 联动（设置页已有，未接线）
- [ ] 图片上传前压缩（`flutter_image_compress`）

## 已完成（本轮）

- [x] 更新通道失效 → GitHub Releases + 域名白名单
- [x] DoH 假开关 → `connectionFactory` 真接入
- [x] MessageBus 3 秒轮询 → 服务端长轮询 + 退避 + 前后台启停
- [x] 通知内容固定文案 → 按 `notification_type` 生成 + 点击跳转
- [x] 深链缺失 → 已实现
- [x] 空态/错误态 → 修复 `StateView` 丢弃 message、错误态用错配图
- [x] `CachedImage` → `memCacheWidth/Height` 按密度降采样
- [x] 大图未压缩 → WebP 化 6348KB → 334KB
- [x] 分享入站 → 已实现
- [x] 草稿 → 自动保存
- [x] 阅读进度 → **核实本来就有**（存 + 读回），只修了同链路空列表越界
- [x] 依赖清理 → 移除 4 个零引用依赖
- [x] 崩溃记录 → 本地文件，不上传
- [x] API 契约测试 → 7 项
- [x] CONTRIBUTING.md

## 已验证不可行 / 需外部条件

- `permission_handler` 13.x：要求 `compileSdk = 37`，当前只装到 android-36，锁在 12.0.1
- Windows 构建插件需开启「开发者模式」（不影响 Android）
- `dart format .` 会走进 `build/` 报 `PathNotFoundException`，必须限定 `lib test`
- 真机 / 真实账号端到端验证：需要设备与账号，静态分析与单测无法替代
