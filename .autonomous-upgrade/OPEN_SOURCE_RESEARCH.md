# 开源同类项目调研

> 检索时间：2026-11-10，数据来源为 GitHub REST API（`api.github.com`）实时查询，非记忆。
> 复现方式：`curl -s https://api.github.com/repos/<owner>/<repo>`。
>
> **不只看 star**。筛选维度：最近推送时间、许可证、架构可借鉴性、是否同目标站点。

---

## 一、结论速览

| 项目 | Star | 语言 | 许可证 | 最近推送 | 判断 |
|---|---|---|---|---|---|
| `xuemk/linuxdo-android` | 198 | Kotlin | **无** | 2026-11-01 | 同站点原生客户端，**代码不可借鉴**（无许可证＝保留所有权利），仅作功能清单参照 |
| `discourse/DiscourseMobile` | 293 | JavaScript (React Native) | MIT | 2026-10-19 | 官方移动端，**非 Flutter**，技术栈不可迁移 |
| `forumcopilot/discourse-app` | 1 | Dart | MIT | 2026-10-27 | **最有价值**：Flutter + GetX + Dio 的分包架构与三份审计文档 |
| `xhuohai/sudo` | 3 | Kotlin | MIT | 2026-03-06 | 小型 Kotlin 客户端，可参照但体量太小 |
| `fzlzjerry/linuxdo-macos` | 5 | TypeScript (Tauri) | MIT | 2026-08-21 | 桌面端，技术栈不重叠 |
| `w4mxl/V2LF` | 478 | Dart | **GPL-3.0** | 2022-01-19 | 高星但**已停更 4 年**，且 GPL 传染性，**不建议引入** |
| `anghunk/linuxdo-scripts` | 2832 | Vue | Apache-2.0 | 2026-11-02 | 高星但是**浏览器扩展**，非 App，仅可参考交互设计 |

一句话：**同站点最活跃的是 Kotlin 原生项目但无许可证；Flutter 侧唯一有参考价值的是 `forumcopilot/discourse-app`（MIT）。**

---

## 二、`forumcopilot/discourse-app`（MIT，重点研究对象）

这是唯一一个与我们技术栈高度重合（Flutter + GetX + Dio + Discourse）且许可证宽松（MIT）的项目。

### 2.1 分包架构

根目录 `packages/` 下 6 个本地包：

```
packages/
├── forumcopilot_sdk/        # 与 Discourse 的传输层
├── discourse_core/          # 领域模型 + API 调用
├── discourse_ui/            # 页面与组件
├── discourse_notifications/ # 通知
├── discourse_appearance/    # 主题/配色
└── forum_kit/               # 通用工具（图片、文件、WebView）
```

依赖方向是单向的：`core → ui → app`，`kit` 被各处复用。**没有**出现反向依赖。

依赖选型（读取各包 `pubspec.yaml` 得到）：`get 4.7.3`、`dio 5.4.0`、`cached_network_image`、`infinite_scroll_pagination`、`flutter_image_compress`、`flutter_secure_storage 9.2.4`、`material_color_utilities`。

**对我们的启发**：我们当前是扁平结构（`lib/pages`、`lib/net`、`lib/widgets`、`lib/models`），
`net` 层直接依赖 `Get`（`message_bus_service`、`deep_link_service` 都 import 了 get）。
分包在 Flutter 里成本不低，但**先把 `net` 对路由层的依赖去掉**是低成本、高收益的一步。

### 2.2 密钥存储（安全，已在本轮落地）

`discourse_core/pubspec.yaml` 注释原文：

> `# Keychain/Keystore storage for the User API Key + handshake private key`
> `flutter_secure_storage: ^9.2.4`

对照我们的实现：`UserApiKeyAuthService` 把 **User API Key 和 RSA 私钥都明文写进 `SharedPreferences`**
（`StorageManager.setData(keyUserApiKey, ...)`、`keyUserPrivateKey`）。

- 我们已经用 `allowBackup=false` 堵掉了「备份拖走」这条路
- 但 root 设备、以及任何拿到应用私有目录读取权限的途径仍可读到私钥
- 私钥泄露 = 他人可伪造 handshake，长期冒用身份

**结论：这是本轮调研中最该立刻修的一条。** 已按 `flutter_secure_storage` 方案改造（见 `UPGRADE_LOG.md` Round 4）。

### 2.3 性能审计文档（`docs/perf-audit-2026-09.md`）

他们把自己 App 的性能问题排了序，**前四条**：

1. **列表未虚拟化**：`ListView(children: [...])` 包住 `Column`，每次 `setState` 重建全部行
2. **隐藏的五份列表镜像**：`IndexedStack` + `Positioned(-10000)` + `Opacity(0)`，Latest 流被构建两次
3. **每行重复计算**：`withEmojiShortcodes`、`formatSmartDateTime` 每次 build 重算
4. **头像按原始尺寸解码**，且解了两次（240px 头像塞进 40px 槽位）

第 4 条与我们 Round 3 修的 `CachedImage.memCacheWidth` 是**同一个问题**，独立印证了这个方向正确。

**待自查**：我们的 `topics_page` 是否也存在 `ListView(children: [...])` 形式的非虚拟化列表？已列入 `TODO_NEXT.md`。

### 2.4 SDK 字段审计文档（`docs/sdk-gap-audit-discourse.md`）

方法论值得直接借用：**对每个接口拉真实 payload，枚举 key，检查该 key 字符串是否在代码里出现过**，统计「从没读过」的比例。他们的实测结果（2026-08-08，对 try.discourse.org）：

| Payload | 从未读取 |
|---|---|
| `/latest.json` 的 `topics[]` | 9 / 36 |
| 主题详情 `/t/{id}.json` | 32 / 61 |
| `post_stream.posts[]` | 32 / 63 |
| `/u/{name}.json` | 23 / 47 |
| `/site.json` | **41 / 41（完全没读）** |

更重要的是一条**陷阱**，原文：

> capability 是「当前查看者」的答案，不是这个论坛的答案。
> `can_tag_topics` 对游客是 false，对登录的 TL1 用户是 true；
> `/chat/api/me/channels` 对游客 403，登录后 200。
> 用状态码推断权限，他们踩了两次坑。

**对我们的启发**：我们渲染 UI 时若用「接口是否报错」来判断权限（比如能否发帖、能否用标签），
在游客态与登录态之间会得出相反结论。应当显式读取 `current_user.can_*` 字段。

---

## 三、`xuemk/linuxdo-android`（无许可证，仅作功能参照）

- Kotlin + Gradle KTS，2026-10-08 创建，2026-11-01 最后推送，198 star / 10 fork / 0 open issue
- **`license: null`** —— GitHub 上没有任何 LICENSE 文件。这意味着**默认保留所有权利**，
  即使仓库公开，也不授予复制、修改、再分发权。
- 我们的处理：**不读取、不复制其任何源码**，只把它当作「同一站点上用户会期待哪些功能」的参照物。

同类还有 `xyuuii/linuxdo-harmony`（Apache-2.0，README 自述「inspired by xuemk/」）——
若将来需要 HarmonyOS 端，那是可合法借鉴的入口。

## 四、`discourse/DiscourseMobile`（MIT，官方）

- 293 star / 69 fork，MIT，2026-10-19 推送，**语言是 JavaScript → React Native，不是 Flutter**
- 早期（2016 创建）与现在的技术栈不同，README 未在此次检索中取得有效内容
- 价值：**功能范围**的权威参照（官方认为一个 Discourse 客户端该有什么），
  但代码与我们的 Flutter 栈不通用，**不建议迁移任何实现**

## 五、`w4mxl/V2LF`（GPL-3.0，高星但不可用）

- 478 star，Dart/Flutter，GPL-3.0，**最后推送 2022-01-19**
- 两个否决理由：
  1. **许可证**：GPL-3.0 有传染性，把其中代码并入闭源/其他许可项目会强制整体 GPL 化
  2. **时效**：停更近 4 年，Flutter 版本、空安全、Material 3 都已脱节
- 结论：**不引入**。若要读它的列表滚动实现，需先确认许可证兼容，且大概率已过时。

---

## 六、按投入产出比排序：立刻可做的三件事

1. **密钥进 Keystore/Keychain**（安全，半小时级）
   `SharedPreferences` 里的 User API Key 与 RSA 私钥迁移到 `flutter_secure_storage`。
   洞是实打实的：私钥明文落盘。已在 Round 4 落地。

2. **列表虚拟化自查**（性能，1 小时级）
   对照他们第 1 条发现，检查我们的主题列表是否 `ListView(children:)` 一次性构建。
   这是「滚动卡顿」最常见的单一原因。

3. **权限字段显式读取**（正确性，半天级）
   凡是 UI 依据「接口成功/失败」推断权限的地方，改为读 `current_user.can_*`，
   避免游客态与登录态判断相反。

---

## 七、明确不采纳

| 候选 | 不采纳原因 |
|---|---|
| `w4mxl/V2LF` | GPL-3.0 传染 + 停更 4 年 |
| `xuemk/linuxdo-android` 代码 | 无许可证＝不可复制 |
| `DiscourseMobile` 实现 | React Native，栈不通用 |
| `anghunk/linuxdo-scripts` 代码 | 浏览器扩展，运行环境不同 |
| 引入 `forumcopilot_sdk` | 与我们已有 78 个 Retrofit 端点重复，迁移成本 > 收益 |

---

## 附：本次未核实的部分

- `xuemk/linuxdo-android` 的 README 在 `master` 分支上为空文件，无法确认其功能清单，故未描述其特性。
- `forumcopilot/discourse-app` 仅 1 star，无法从社区反馈判断质量；其价值在于**文档方法论**而非代码成熟度。
- 以上 star / 推送时间为 2026-11-10 单次快照，会随时间变化。
