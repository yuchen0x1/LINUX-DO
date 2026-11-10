# 测试与验证报告

执行环境

| 项 | 值 |
|---|---|
| OS | Windows 10.0.26340 x64 |
| Flutter | 3.50.0-0.3.pre (stable) |
| Dart | 3.13.7 |
| JDK | 17 |
| Gradle | 8.14.3 |
| AGP | 8.11.1 |
| Kotlin | 2.2.20 |

执行时间：2026-11-10

---

## 1. 静态分析

```bash
flutter analyze --no-pub
```

```
128 issues found. (ran in 6.4s)
```

按严重级别拆分：

| 级别 | 数量 |
|---|---|
| error | **0** |
| warning | **0** |
| info | 128 |

info 全部为历史遗留（`use_key_in_widget_constructors`、`prefer_const_constructors`、
`avoid_print` 等风格类提示），未在本轮批量修改——它们是全量重排的噪音，会掩盖真实改动。

**基线对比**：本轮开始时为 244 issues / 108 warning / 0 error；warning 已清零。

---

## 2. 代码格式

```bash
dart format --output=none --set-exit-if-changed lib test
```

```
Formatted 289 files (0 changed)
```

> 注意：不能用 `dart format .`。它会走进 `build/` 下的 Gradle 缓存目录，遇到
> 残留的 transform 路径时抛 `PathNotFoundException`。CI 已限定为 `lib test`。

---

## 3. 单元测试

```bash
flutter test
```

```
00:04 +49: All tests passed!
```

| 测试文件 | 用例数 | 覆盖内容 |
|---|---|---|
| `retry_interceptor_test.dart` | 8 | GET/POST 重试策略、HTML 网关页不重试、429 退避、`RateLimitExhaustedException`、**重复注册不放大重试次数** |
| `update_checker_test.dart` | 11 | semver 数值比较（1.10 > 1.9）、build number/预发布后缀剥离、下载域名白名单、明文与畸形地址拒绝 |
| `deep_link_service_test.dart` | 12 | `/t/<slug>/<id>`、`/t/<id>`、带页码查询串、`/u/<name>`、`/c/<slug>/<id>`、`linuxdo://topic/<id>`、授权回调不接管、非本站/非法 id 忽略 |
| `share_intent_service_test.dart` | 9 | 纯文本转发帖、帖链直达、查询串/页码、中文全角标点截断、多行保留、首个链接判定 |
| `api_contract_test.dart` | 7 | Discourse `snake_case` → 模型字段映射、`avatar_template` 的 `{size}` 替换、`tags` 列表、缺省字段容错、`findUserById` 未命中占位 |
| `storage_manager_test.dart` | 1 | 并发首次初始化只执行一次 |
| `widget_test.dart` | 1 | 启动页可渲染 |
| **合计** | **49** | |

**基线对比**：本轮开始时为 10 个用例；新增 39 个。

---

## 4. 构建验证

```bash
flutter build apk --release --target-platform android-arm64
```

```
√ Built build\app\outputs\flutter-apk\app-release.apk (45.4MB)
```

| 指标 | 本轮开始 | 现在 | 说明 |
|---|---|---|---|
| APK 体积 | 52.5 MB | **45.4 MB** | 资源转 WebP + 移出未打包大图 |
| 实测字节 | — | 47,615,332 | `ls -l` |

构建过程出现三条版本提示（Gradle 8.14.3 < 9.1.0、AGP 8.11.1 < 9.0.1、
Kotlin 2.2.20 < 2.3.20），**均为 warning，不影响产物**，已记入
`NEXT_UPGRADE_PLAN.md`。

### 4.1 清单合并校验

```bash
aapt2 dump badging app-release.apk
aapt2 dump xmltree --file AndroidManifest.xml app-release.apk
```

| 检查项 | 结果 |
|---|---|
| `package` / `versionCode` / `versionName` | `com.linux.linuxdo` / 11 / 1.0.9 |
| `minSdkVersion` | 24 |
| `targetSdkVersion` | **35** |
| `compileSdkVersion` | 36 |
| `android:allowBackup` | **false** |
| `android:dataExtractionRules` | 已挂载（`@0x7f120000`） |
| `linuxdo` scheme intent-filter | 已合并 |
| `https`/`http` + host `linux.do` | 已合并 |
| `ACTION_SEND` + `text/plain` | 已合并 |

### 4.2 16KB 页对齐

```bash
bash scripts/check_16k_alignment.sh app-release.apk
```

```
OK    lib/arm64-v8a/libapp.so                      LOAD align=0x10000
OK    lib/arm64-v8a/libbarhopper_v3.so             LOAD align=0x4000
OK    lib/arm64-v8a/libdartjni.so                  LOAD align=0x4000
OK    lib/arm64-v8a/libdatastore_shared_counter.so LOAD align=0x4000
OK    lib/arm64-v8a/libflutter.so                  LOAD align=0x10000
OK    lib/arm64-v8a/libimage_processing_util_jni.so LOAD align=0x4000
OK    lib/arm64-v8a/libsurface_util_jni.so         LOAD align=0x4000
WARN  lib/armeabi-v7a/libbarhopper_v3.so           LOAD align=0x1000（32 位 ABI，不受 16KB 页要求约束）
...
所有 native 库均满足 16KB 页对齐。
```

arm64-v8a 全部 ≥ 0x4000。armeabi-v7a 的 `libbarhopper_v3.so` 仍为 0x1000，
但 16KB 页要求只针对 64 位 ABI，故只告警不失败（脚本已按此规则修正）。

### 4.3 签名

```bash
apksigner verify --print-certs --verbose app-release.apk
```

```
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme (APK Signature Scheme v2): true
Verified using v3 scheme (APK Signature Scheme v3): true
Number of signers: 1
Signer #1 certificate SHA-256 digest: 4b0e72061c8d08da00cf99f8bc3e6df730530965f9b1c8ba9803a66e28bdd517
Signer #1 certificate DN: CN=linuxdo, OU=linuxdo, O=linuxdo, L=Beijing, ST=Beijing, C=CN
```

证书 SHA-256 与升级前一致（`4B:0E:72:06:1C:...:D5:17`），因此**已安装用户可覆盖升级**，
不需要卸载重装。

### 4.4 包内资源校验

```bash
unzip -l app-release.apk | grep assets/images
```

包内只有 `.webp`，原始 PNG 已不在 APK 中：

```
56512  assets/flutter_assets/assets/images/dark/chat-backgroud.webp
49790  assets/flutter_assets/assets/images/dark/chat-list-background.webp
57898  assets/flutter_assets/assets/images/dark/search-banner.webp
55790  assets/flutter_assets/assets/images/light/chat-backgroud.webp
48584  assets/flutter_assets/assets/images/light/chat-list-background.webp
50610  assets/flutter_assets/assets/images/light/search-banner.webp
23352  assets/flutter_assets/assets/images/profile-header-bg.webp
```

---

## 5. 未验证的部分（明确声明）

以下内容**没有**真机或模拟器证据，只有静态分析、单元测试与构建级证据：

| 项目 | 缺什么 |
|---|---|
| 深链唤起（`https://linux.do/t/...`） | 需要设备上用浏览器/其他 App 实际点击验证 |
| 通知点击跳转 | 需要真实登录态 + 触发一条通知 |
| 分享入站（`ACTION_SEND`） | 需要从其他 App 实际分享一次 |
| DoH 实际解析效果 | 需要抓包确认未走系统 DNS |
| 消息长轮询 | 需要真实 `message-bus` 端点与登录态 |
| 密钥库迁移 | 需要验证旧版本升级后 API Key 仍可用 |
| 手势/滚动流畅度 | 需要真机帧率数据 |

这些项目在 `NEXT_UPGRADE_PLAN.md` 中被列为「必须真机验证」的第一优先级。

---

## 6. 复现命令汇总

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test
flutter build apk --release --target-platform android-arm64
bash scripts/check_16k_alignment.sh build/app/outputs/flutter-apk/app-release.apk
/d/DevTools/AndroidSdk/build-tools/36.0.0/apksigner.bat verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```
