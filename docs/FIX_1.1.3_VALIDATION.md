# v1.1.3 本地修复与验证

日期：2026-11-14（Asia/Shanghai）。源码版本 `1.1.3+22`，基于本地 `main` / `cc17179`。本文记录发布前的验收快照；发布状态以 [GitHub Release](https://github.com/yuchen0x1/LINUX-DO/releases/tag/v1.1.3) 为准。

## 修复范围

- 原有帖子 Dio 接口已应用登录代理。本次补齐默认 Dart 图片、缓存图片、图片下载及默认浏览器入口的代理覆盖。
- 图片下载使用独立线路客户端，不携带论坛的 Cookie、User API Key 或 CSRF Token 到外部图片站。代理关闭后恢复直连，订阅核心启动失败时保留代理路由。
- 工具网页加载前等待 Android WebView 代理生效；仅 HTTP(S) GET 主页面可因连接或网关错误自动换线。表单不重放，换线期间新打开的页面不会被旧请求覆盖。
- 接口异常 HTML、验证页、错误文本和空读取响应在模型转换前返回明确错误；合法的文本 JSON 仍可解析。验证成功后更新正在使用的 CookieJar，并清理轮询。
- 底栏取消固定高度及裁切滚动容器，按实际按钮高度布局；使用系统安全区，并另加 `8.w` 底部间距，保留隐藏动画。

## 本地证据

| 检查 | 结果 |
|---|---|
| `flutter test --no-pub --reporter expanded` | PASS，108 项；日志 `build/regression-v1.1.3.log` |
| 底栏 widget 布局与渲染 | PASS，0/24/48 底部 inset、键盘和隐藏恢复；预览 `build/home-bottom-bar-preview.png`，不是手机截图 |
| 真实本地 HTTP socket | PASS，默认图片客户端切换直连/代理、订阅启动失败不直连、Dio 图片下载代理及凭据边界；不等同 Android HTTPS/公网代理验收 |
| 工具网页恢复 | PASS，使用假 WebView/代理验证 GET 恢复、POST 不重放、导航竞态和 502 恢复；不等同 Android WebView 真机验收 |
| `dart analyze lib test`（实际中文工程路径） | PASS，0 error、0 warning、143 info，exit 0；日志 `build/dart-analyze-v1.1.3.log` |
| `dart format --output=none --set-exit-if-changed lib test` | PASS，307 文件，无需更改 |
| `python scripts/check_repository_hygiene.py` | PASS，2293 个索引文件；新增文件另经 diff/人工审查 |
| `git -c core.autocrlf=false diff --check` | PASS |
| `flutter analyze --no-pub --no-fatal-infos lib test` | BLOCKED，实际路径触发分析服务 LSP JSON `FormatException`，exit 255；S: 别名另产生生成代码误报。没有将此命令记为通过，使用独立 Dart 分析补充证据 |
| 最终 Android release 构建 | PASS，arm64-v8a、armeabi-v7a、x86_64 三包，exit 0 |
| `apksigner verify --print-certs` | PASS，三包签名有效，并与本地 v1.1.2 APK 证书 SHA-256 一致 |
| APK 版本及架构 | PASS，版本 1.1.3；versionCode 分别 2022、1022、4022，均高于对应旧包 |
| `zipalign -c -P 16 4` | PASS，三包全部通过 |
| NDK `llvm-readelf -lW` | PASS，每包 8 个原生库，64 位 LOAD 段均满足 16KB；详细数据 `build/elf-check-v1.1.3/results.json` |

## 安装包与边界

使用临时 ASCII 盘符映射同一工程，执行 `flutter build apk --release --split-per-abi --no-pub --obfuscate --split-debug-info=dist/dart-symbols/v1.1.3`。产物、符号和校验日志仅保存在本机，不随源码上传。

可安装文件为 `dist/linux_do_android_release_1.1.3_arm64-v8a.apk`、`dist/linux_do_android_release_1.1.3_armeabi-v7a.apk`、`dist/linux_do_android_release_1.1.3_x86_64.apk`；摘要清单为 `dist/SHA256SUMS-v1.1.3.txt`。没有覆盖旧安装包。

手机未连接（`adb devices` 无设备），没有访问真实账号或订阅验证。截图中的类型转换触发路径已覆盖；其上游究竟是 Cloudflare、网关错误还是其他异常响应，仍不能仅凭截图确定。代理 API 仍使用原有 Dart IO 传输，不能以错误提示修复或本地测试宣称真实论坛已连通。

用户明确选择系统浏览器时使用系统浏览器网络设置；原生视频播放器不属于本次图片/网页代理修复。默认图片客户端的已建立 HTTPS 隧道可能在订阅换线后短暂复用，不宣称图片具备与 Dio 相同的自动重放保证。
