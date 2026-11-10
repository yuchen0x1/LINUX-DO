# 最终报告

> 项目：LINUX DO Android 客户端（Flutter）
> 分支：`upgrade/2026-11-autonomous`
> 时间：2026-11-10
> 提交范围：`cccfbb9` … `7ff1d5e`（6 个提交，未发布任何正式版本）

---

## 一、一句话结论

**P0 阻塞项已全部清除，并额外修复了 9 个真实缺陷、补齐 7 项此前只有 UI 没有实现的功能。**
但**所有改动都没有经过真机验证**——这一点在下面第五节如实列出，不做任何粉饰。

---

## 二、本轮做了什么

### 2.1 解决了什么（有前后对比）

| 问题 | 之前 | 现在 |
|---|---|---|
| 签名口令泄露 | 硬编码在 `build.gradle` 里，随仓库分发 | 读 `key.properties`，文件不入库；证书不变，老用户可覆盖升级 |
| 16KB 页设备启动崩溃 | 3 个 arm64 库 `LOAD align = 0x1000` | 全部 ≥ `0x4000`，并有校验脚本 + CI 门禁 |
| `targetSdk` 过期 | 33 | 35 |
| API Key / RSA 私钥明文落盘 | 明文存 `SharedPreferences` | 系统密钥库（Keystore/Keychain），启动自动迁移 |
| 重试次数被平方放大 | 拦截器注册两次 | 移除重复，测试锁定「恰好 3 次调用」 |
| analyzer warning | 108 | **0** |
| 单元测试 | 10 | **49** |
| 更新检查 | 接口已失效，永远检不到新版 | GitHub Releases + 域名白名单 |
| DoH | 只有 UI 开关，零调用方 | `connectionFactory` 真接管解析 |
| 消息推送 | 固定 3 秒轮询 | 服务端长轮询 + 指数退避 + 前后台暂停 |
| 深链 / 分享入站 | 无 | 已实现（含冷启动链接暂存） |
| 草稿 | 只有手动保存，返回即丢 | 3 秒防抖自动保存 + 离开落盘 |
| 空态自定义文案 | 传入即被丢弃 | 生效 |
| APK 体积 | 52.5 MB | **45.4 MB** |
| 大图资源 | 6 张合计 6.3 MB | 334 KB（-94.7%） |

### 2.2 关键判断（为什么这么做）

**先修 P0，再谈 UI。** 一个在 16KB 页新设备上启动即崩、签名口令随代码公开分发的
应用，讨论交互动效没有意义。

**不重写架构。** 282 个 Dart 文件、62913 行，controller 直接调 `ApiService`。
把 `net` 层整体抽成 Repository 是正确方向，但一次性重写会在没有真机验证的前提下
引入大面积不可测风险。因此本轮只做**局部去耦**（网络层不再依赖路由字面量之外的东西），
把结构性重构写进 `NEXT_UPGRADE_PLAN.md` 而不是硬做。

**发现「假功能」就当场补实现，而不是删掉 UI 假装没有。**
- DoH 开关：原来只有 UI，`DohService` 零调用方 → 接上 `connectionFactory`
- 更新检查：原来请求一个已失效的地址 → 换 GitHub Releases
- `ACTION_SEND` intent-filter：加了 filter 却没有 Dart 处理 → 补 MethodChannel
- `StateView.empty(message:)`：参数传了但代码里从来没用 → 修

**不删除用户的文件。** 大图改 WebP 后，原图 `git mv` 到 `assets/design/source/`，
只是移出打包范围，仓库里仍可回溯。`profile-header.jpg`（1.5MB，无任何引用）同样处理，
而不是删掉。

**不上传任何用户数据。** 崩溃记录只写应用私有目录，明确不联网。调研同类项目时
只读公开仓库元数据，未上传本项目任何内容。

---

## 三、调研结论（详见 `OPEN_SOURCE_RESEARCH.md`）

GitHub API 实时核对（2026-11-10），**不只看 star**：

| 项目 | Star | 语言 | 许可证 | 判断 |
|---|---|---|---|---|
| `xuemk/linuxdo-android` | 198 | Kotlin | **无** | 同站点原生端，但无许可证＝不可复制代码，仅作功能参照 |
| `discourse/DiscourseMobile` | 293 | JS (RN) | MIT | 官方，但非 Flutter，栈不通用 |
| `forumcopilot/discourse-app` | 1 | Dart | MIT | **最有价值**：Flutter+GetX+Dio 分包架构 + 三份审计文档 |
| `w4mxl/V2LF` | 478 | Dart | **GPL-3.0** | 高星但停更 4 年且 GPL 传染，**不采纳** |

从 `forumcopilot` 直接采纳的两条：

1. **密钥必须进 Keystore**（其 `pubspec` 注释原文写明用途）→ 已在 Round 4 落地
2. **性能审计里「头像按原图解码」是前 3 大问题** → 与我们 Round 3 的
   `CachedImage.memCacheWidth` 修复方向一致，独立印证

---

## 四、改动清单

```
7ff1d5e 🛡️ round6: 帖子详情空列表越界 + API 契约测试 + 贡献指南
1921647 style: 全量应用 dart format（tall 风格）
8a1664b 🧹 round5: 依赖清理 + 本地崩溃记录 + 草稿自动保存
54cdf0b 🔐 round4: API Key/RSA 私钥迁入系统密钥库 + 开源调研 + 16KB 校验修正
f645f21 ⚡ round3: 资源瘦身 -94.7% + 图片解码降采样 + 空态修复 + 分享入站
a818d06 ✨ round2: 更新通道复活 + DoH 真接入 + 长轮询推送 + 深链
cccfbb9 chore: 安全与合规基线
```

新增文件（主要）：

| 文件 | 作用 |
|---|---|
| `lib/net/update_checker.dart` | 更新检查 + 下载域名白名单 |
| `lib/net/deep_link_service.dart` | 深链解析与路由 |
| `lib/net/share_intent_service.dart` | 分享入站解析 |
| `lib/utils/secure_store.dart` | 敏感数据密钥库封装 + 迁移 |
| `lib/utils/crash_reporter.dart` | 本地崩溃记录 |
| `android/.../MainActivity.kt` | `ACTION_SEND` MethodChannel |
| `scripts/check_16k_alignment.sh` | 16KB 对齐校验 |
| `scripts/optimize_assets.py` | 大图转 WebP |
| `.github/workflows/ci.yml` | format/analyze/test/build/对齐 门禁 |
| `test/*.dart` ×5 | 39 个新用例 |
| `CONTRIBUTING.md` | 贡献指南 |

---

## 五、未完成与未验证（重要）

### 5.1 完全未经真机验证

以下功能**代码已写完、编译进 APK、有单元测试，但没有在设备上跑过一次**：

深链唤起 · 通知点击跳转 · 分享入站 · DoH 实际解析 · 消息长轮询 ·
密钥库迁移后登录态保持 · 滚动流畅度

我在 `TEST_REPORT.md` 和 `NEXT_UPGRADE_PLAN.md` 的 P0 里都把它们列为
**发布前必须验证**。**现在不应该发布。**

### 5.2 计划内但本轮没做

| 项 | 原因 |
|---|---|
| 拆分 `html_widget.dart`（2676 行） | HTML 渲染是核心路径，无 golden 测试就拆分风险过高，已写详细方案进 P3-1 |
| Repository 分层 | 一次性重写 282 文件不可测，改为给出分步方案 |
| 多草稿箱 | 需要新 UI 页面；本轮先解决了「返回丢内容」这个更痛的问题 |
| 离线缓存 / 阅读进度增强 | 阅读进度**本来就有**（已核实存+读回），无需重做；离线缓存是新功能，优先级低于修复 |
| Gradle 9 / AGP 9 / Kotlin 2.3 升级 | 有明确时间窗，一次性跳三个版本风险过高，已给分批顺序 |
| 权限字段显式读取（`current_user.can_*`） | 需要先定位所有「靠状态码推断权限」的点，属于需要真机对照的工作 |

### 5.3 遗留的已知小问题

- analyzer 仍有 128 个 `info`（历史风格提示），未批量修改以免掩盖真实改动
- `armeabi-v7a/libbarhopper_v3.so` 仍为 `0x1000`（32 位 ABI 不受 16KB 要求约束）
- 阅读位置 key 无上限，长期使用会缓慢增长
- Windows 构建需开启「开发者模式」（不影响 Android）

---

## 六、如何验证我说的话

所有结论都可用以下命令复现，命令与预期输出见 `TEST_REPORT.md` 第 6 节。

```bash
flutter analyze --no-pub        # 预期 0 error / 0 warning
flutter test                    # 预期 49 passed
flutter build apk --release --target-platform android-arm64
bash scripts/check_16k_alignment.sh build/app/outputs/flutter-apk/app-release.apk
```

---

## 七、给下一位接手的人

1. 先读 `.autonomous-upgrade/NEXT_UPGRADE_PLAN.md` 的 P0 —— 七个真机验证项，这是唯一阻塞发布的东西。
2. `.autonomous-upgrade/UPGRADE_LOG.md` 记录了每一轮踩过的坑（例如 Kotlin 嵌套块注释、
   `dart format .` 会走进 `build/` 报错），能省不少时间。
3. 判断权限时读 `current_user.can_*`，不要用「接口是否报错」推断——这是调研中
   别人踩过两次的坑。
4. 新增依赖前先看许可证和有没有原生 `.so`（后者决定 16KB 对齐风险）。
