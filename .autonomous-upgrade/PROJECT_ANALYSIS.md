# 项目分析

> 生成：2026-11-10 14:46　｜　分支：`upgrade/2026-11-autonomous`　｜　基线提交：`cccfbb9`

## 定位

LINUX DO（linux.do，Discourse 论坛）第三方 Android 客户端。Flutter 原生渲染，非 WebView 套壳。

## 技术栈

| 层 | 技术 |
|---|---|
| 框架 | Flutter 3.50.0-0.3.pre（本地）/ Dart 3.13.7 |
| 状态管理 | GetX 4.7.3（263 处 `.obs`、157 处 `Obx`、163 处 `Get.put/find`） |
| 网络 | Dio 5.11.1 + Retrofit 4.10.0（78 个端点）+ dio_cookie_manager + cookie_jar |
| 网络栈 | Cronet（Chromium TLS 指纹过 Cloudflare）或 Dart HttpClient + findProxy |
| 本地存储 | SharedPreferences（StorageManager）+ GetStorage（仅收藏）+ PersistCookieJar |
| 构建 | Gradle 8.14.3 / AGP 8.11.1 / Kotlin 2.2.20 / JDK 17 / compileSdk 36 / targetSdk 35 / minSdk 24 |
| 包名 | `com.linux.linuxdo` |

## 规模

| 指标 | 值 |
|---|---|
| Dart 文件（lib） | 277 |
| 非生成代码行数 | ~55,000 |
| 页面文件 | 115 |
| API 端点 | 78 |
| 资产 | 15MB（images 7.9M / emojis 6.1M） |

## 目录职责

```
lib/
├── app.dart            应用初始化（Storage/GetStorage/DeviceUtil/NetClient/ApiService/GlobalController）
├── main.dart           入口，动态初始路由，主题包装
├── const/              颜色、常量、主题、尺寸、间距、图标、图片
├── controller/         GlobalController（登录态/用户信息/clientId）、BaseController、ShareController
├── models/             Discourse 数据模型（含 .g.dart 生成代码）
├── net/                ★ 核心复杂区：HttpClient、Retry、DoH、Proxy、Cronet、CF 过盾、MessageBus、API Key 认证
├── pages/              115 个页面（Controller + View 同文件）
├── routes/             GetX 路由表
├── utils/              StorageManager、Log、Emoji、Bookmark、EventBus、Tag、UserCache
└── widgets/            通用组件，html_widget.dart 2676 行（HTML→Flutter 渲染器）
```

## 已确认的架构问题

1. **无 Repository 层**：Controller 直接持有 `ApiService`，网络失败处理散落各页。
2. **三套存储并存**：SharedPreferences + GetStorage + PersistCookieJar，无统一抽象。
3. **超长文件**：`html_widget.dart` 2676 行、`topic_detail_controller.dart` 1414 行、`avatar_widget.dart` 1330 行。
4. **模型层设计缺陷**：`PostDetail extends Post` 手写 29 个 `@override` 字段（已通过排除 .g.dart 从分析器移除噪音，但结构问题仍在）。
5. **无 Repository/UseCase 边界** → 关键路径难以单测。

## 功能实现状态（代码实证）

| 模块 | 状态 | 证据 |
|---|---|---|
| 游客浏览 | 可用 | `isAnonymousMode` 分支 |
| WebView 授权登录 | 可用（仅 App 内 WebView 路径） | `web_page.dart:335` 拦截 `linuxdo://auth` |
| User API Key 登录 | 可用，但此前不写 userId（**已修**） | `message_bus_service.dart` syncUserIdentity() |
| MessageBus 实时通知 | **半可用**：能订阅 `/latest`，但 `/notification/{uid}` 依赖 userId（已补）；仍是轮询非长轮询；消息内容未解析 | `_poll()` 固定 3 秒 Timer |
| DoH | **假开关**：`DohService.resolve()` 全仓零调用 | 待接线或移除 |
| HTTP 代理 | 可用（Dio findProxy + WebView ProxyController） | `proxy_service.dart` |
| Cloudflare 过盾 | 可用（403 挑战检测 + WebView Turnstile + 收割） | `cloudflare_clearance_service.dart` |
| Cruise/Cronet 网络栈 | 可用（无代理时默认） | `cronet_adapter.dart` |
| 主题换色 | **已修**（原先丢样式） | `AppTheme.withPrimaryColor` |
| 应用更新 | **失效**：`ld.rrrc.me` NXDOMAIN | `home_controller.dart:200` |
| 深链 | 缺失：`linuxdo://` 无 intent-filter | 待补 |

## 本轮已完成（基线 `cccfbb9`）

- 签名口令出仓库 + 轮换 keystore 口令（证书不变，SHA256 `4b0e7206…`）
- v3/v4 签名启用
- `allowBackup=false` + `dataExtractionRules`
- RetryInterceptor 重写（单一注册 / 幂等 / 429 退避）+ 8 条单测
- 日志脱敏（cookie/token/api-key/csrf）
- 401 会话过期统一处理
- targetSdk 35 + 退出强制 edge-to-edge
- 依赖升级：mobile_scanner 7.5.0、cronet_http 1.10.1、permission_handler 12.0.1、flutter_local_notifications 19.5.0
- 全部 native 库 16KB 对齐（原 3 个 4KB → 全部 ≥ 0x4000）+ 校验脚本
- CI 门禁（format / analyze / test / build / 对齐校验）
- iOS workflow 移除自动建 Release
- `pubspec.lock` 入库、SDK 约束收紧到 `>=3.9.0`
- 分析器 244 issues → 129（0 warning / 0 error）
- 通知权限运行时申请
- API Key 登录补 userId + 登出清 userId