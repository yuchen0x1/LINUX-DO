# 贡献指南

## 环境要求

| 组件 | 版本 | 说明 |
|---|---|---|
| Flutter | 3.35.7 及以上 | CI 固定 3.35.7；本地更高版本亦可 |
| Dart | 3.9.0 及以上 | 见 `pubspec.yaml` 的 `environment.sdk` |
| JDK | 17 | AGP 8.11.x 要求 |
| Android SDK | compileSdk 36 / targetSdk 35 / minSdk 24 | |
| Gradle | 8.14.x | 更高版本可编译，但会提示升级 |
| NDK | 28.x | 仅 16KB 对齐校验脚本需要 |

## 首次配置

1. 拉依赖：

   ```bash
   flutter pub get
   ```

2. 配置签名（**仅打包 release 需要**）。在 `android/keystore/` 下放 `key.properties`：

   ```properties
   storeFile=app/release-key.jks
   storePassword=****
   keyAlias=linuxdo
   keyPassword=****
   ```

   该文件已在 `.gitignore` 中，**不要提交**。`key.properties` 缺失时 release 构建
   产出未签名 APK（会打 warning，不报错），便于只做编译验证。

3. 确认能用 debug 构建：

   ```bash
   flutter run
   ```

## 提交前必须通过的检查

```bash
dart format --set-exit-if-changed .
flutter analyze --no-pub          # 必须 0 error / 0 warning
flutter test                      # 全部通过
```

`flutter analyze` 目前仍有若干 `info` 级提示（历史遗留），**新增代码不应引入新的
`info`**。若确需抑制，用 `// ignore: <rule>` 并在同一行写明原因。

改动涉及 Android 原生或依赖时，额外跑：

```bash
flutter build apk --release --target-platform android-arm64
bash scripts/check_16k_alignment.sh build/app/outputs/flutter-apk/app-release.apk
```

16KB 对齐检查对 **arm64-v8a** 是硬性要求；32 位 ABI 未对齐只告警（不受该规则约束）。

## 代码约定

- 状态管理统一用 GetX（`BaseController` + `.obs` + `Obx`），新页面沿用现有模式。
- 网络层只走 `NetClient.getInstance().dio`，不要在页面里 new `Dio`——会绕过
  代理、DoH、Cookie、重试与 401 处理。
- **敏感数据禁止写 `SharedPreferences`**：API Key、RSA 私钥一律走
  `SecureStore`（系统密钥库）。
- 日志禁止打印 token / cookie / API Key；`http_client.dart` 已有脱敏工具，复用即可。
- 用户可见文案使用中文；代码注释也以中文为主，与现有风格一致。
- 新增第三方依赖前先确认：许可证、是否仍在维护、是否有原生 `.so`（决定 16KB
  对齐风险）。

## 测试

- 纯逻辑（解析、比较、状态机）用单元测试覆盖，放在 `test/`。
- 依赖 JSON 契约的改动，请更新 `test/api_contract_test.dart` 的样本。
- 涉及 `Get` 全局状态的测试，先 `Get.testMode = true`，或把逻辑抽成静态纯函数
  （参考 `DeepLinkService.resolve`、`ShareIntentService.classify`）。

## 提交信息

采用 `<emoji> <范围>: <描述>` 的格式，正文说明**改了什么、为什么改、怎么验证的**。
涉及安全的改动请显式标注影响面。

## 不要做的事

- 不要把签名文件、`key.properties`、任何密钥提交进仓库。
- 不要直接把崩溃日志或用户内容上传到第三方服务。
- 不要为了「让检查通过」而关闭 lint 规则、跳过测试或用 `// ignore` 掩盖真实问题。
- 不要引入来源不明的二进制依赖。
