# LINUX DO Android

使用 Flutter 开发的 LINUX DO 社区安卓客户端。本分支仅维护 Android；历史上游中的其他平台模板和构建流程已移出当前工作树，不代表现有产品版本。

## 最新更新

### v1.1.3 · 2026-11-14

- 帖子图片、图片下载和应用内工具网页沿用登录页的代理；启用代理时，默认网页入口使用应用内浏览器。
- 网页加载前等待代理生效，线路故障时自动尝试剩余节点；接口返回验证页时显示明确提示，避免数据类型转换报错。
- 底部导航改为按内容高度布局，并避开手机手势或三键导航区域，防止按钮被裁切遮挡。

本地验证和真机验收边界见 [修复验证记录](docs/FIX_1.1.3_VALIDATION.md)。

完整更新记录见 [更新日志](docs/releases/release-notes.md)，目录整理见 [仓库清理说明](docs/REPOSITORY_HYGIENE.md)。

## 下载与安装

前往 [GitHub Releases](https://github.com/yuchen0x1/LINUX-DO/releases) 获取 APK：

| 架构 | 选择建议 |
|---|---|
| arm64-v8a | 大多数现代 Android 手机 |
| armeabi-v7a | 较旧的 32 位 Android 设备 |
| x86_64 | Android 模拟器或 x86 Android 设备；不是 Windows 版本 |

当前源码版本为 `1.1.3+22`。构建号是基数，按架构拆包后的 APK versionCode 带架构前缀。
实际兼容性以安装包和设备为准，不能仅根据构建成功推断真机全部功能可用。

## 已实现的主要能力

- 话题列表、分类、搜索、帖子详情、发帖和回复。
- 用户资料、社区互动、私信、通知和书签等页面。
- Cookie / User API Key 登录、网络代理、Cronet 与 DoH 设置。
- 图片/媒体内容显示、分享入站、深链、草稿保存和主题设置。
- 本地崩溃记录，默认不上传日志。

以上描述依据当前源码；本项目不宣称离线阅读、完整多平台支持、静默升级或所有账号/网络场景都已验证。
系统密钥库不可用时凭据存储存在降级路径，请参阅源码和具体安全评估，不将“优先系统密钥库”宣传为无条件加密。

## 本地开发

| 组件 | 要求 |
|---|---|
| Flutter | CI 固定 3.47.1 stable |
| Dart | >=3.13.0 <4.0.0 |
| JDK | 17 或符合当前 Android 工具链要求的版本 |
| Android SDK | 当前发布 APK 使用 compileSdk 36、targetSdk 35、minSdk 24 |
| Gradle | 8.14.3 |
| NDK | 16KB 对齐检查需要 llvm-readelf；CI 使用 r28 |

以 `pubspec.yaml`、`pubspec.lock` 与 Android 构建配置为准。依赖锁文件属于应用构建输入，必须入库。

```bash
git clone https://github.com/yuchen0x1/LINUX-DO.git
cd LINUX-DO
flutter pub get
flutter devices
flutter run -d <Android设备ID>
```

模型/接口定义变动后，按需要重新生成代码：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 签名配置

release 签名从 `android/keystore/key.properties` 读取。密钥、口令、备份均只保存在本地，禁止提交。
以下仅为模板；`storeFile` 相对于 Android 工程根目录：

```properties
storeFile=app/release-key.jks
storePassword=<本地口令>
keyAlias=<本地别名>
keyPassword=<本地口令>
```

缺少配置或字段时当前 Gradle 会警告并产出未签名包；未签名包不能当作已验证的安装/发布包。
保留原签名密钥，覆盖安装取决于相同证书和合适的 versionCode，不能仅根据版本名称保证。

### 构建与检查

```bash
python3 scripts/check_repository_hygiene.py
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
flutter build apk --release --split-per-abi
bash scripts/check_16k_alignment.sh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Windows 使用已安装的 Python 命令替换 `python3`，并在支持 bash 的终端运行对齐检查。
Windows 路径含中文时，当前 Dart AOT 编译器可能无法读取 `app.dill`；可将同一目录临时映射到一个空闲 ASCII 盘符后构建。无需复制源码，结束后只撤销盘符映射：

```powershell
# S: 仅为示例；已占用时停止，不覆盖已有映射。
if (Get-PSDrive S -ErrorAction SilentlyContinue) { throw '请改用空闲盘符' }
subst S: "$PWD"
if ($LASTEXITCODE -ne 0) { throw '盘符映射失败' }
Push-Location S:\
try {
  flutter build apk --release --split-per-abi --obfuscate --split-debug-info=dist/dart-symbols
} finally {
  Pop-Location
  subst S: /D
}
```

CI 只产出 APK/符号等 artifacts，不自动创建 Release；发布需要独立显式操作。
本机验证与远程 CI 结果分开记录，详见清理说明。

## 目录与上传边界

| 路径 | 作用 | Git 跟踪 |
|---|---|---|
| `lib/`、`assets/`、`android/` | 当前应用源码、运行资源和 Android 工程 | 是 |
| `test/`、`scripts/`、`docs/` | 回归检查、开发脚本与文档 | 是 |
| `pubspec.yaml`、`pubspec.lock` | 依赖声明与可复现版本 | 是 |
| `build/`、`.dart_tool/`、`android/.gradle/` | 可再生成的构建/工具缓存 | 否 |
| `dist/` | 本地 APK 与发布诊断文件 | 否 |
| `.local-archive/` | 隔离的旧平台、历史记录、备份与缓存 | 否 |
| 签名文件、`key.properties`、真实 `.env` | 本地凭据和配置 | 否 |

不要把 `dist/` 或 `.local-archive/` 加入 `pubspec.yaml` 的 assets 列表。
当前开发流程和约定见 [贡献指南](CONTRIBUTING.md)；英文说明见 [README.en.md](README.en.md)。

## 来源与许可证

本项目基于 [R-lz/LINUX-DO](https://github.com/R-lz/LINUX-DO) 的历史继续维护。
采用 MIT 许可证，保留 [LICENSE](LICENSE) 中的版权与许可声明。
