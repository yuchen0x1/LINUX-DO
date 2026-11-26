## 📢 版本概述

本次发布补充界面语言选择、校验后的应用内更新安装和宽屏导航布局，并整理源码仓库的生成文件边界。应用包版本为 1.2.0+24；更新使用与既有版本相同的正式发布流程，v1.1.0 至 v1.1.4 的客户端可从 GitHub 最新正式 Release 发现较新版本。

## ✨ 新增功能

- **界面语言**：可在设置中选择跟随系统、简体中文或 English；社区帖子和账号内容保持原文。
- **应用内更新安装**：按设备 ABI 选择 APK，下载完成后校验 SHA-256 和文件大小，再交由 Android 系统确认安装。

## 🔧 改进与优化

- **首页宽屏布局**：宽屏设备使用侧边导航，窄屏保留底部导航；切换布局时保持页面内容。
- **仓库维护**：统一研究输出到被忽略的 `dist/`，移除过时的固定调研快照，补全常见本机临时文件忽略及上传边界检查。
- **发布测试**：新增 release helper 回归测试，修正缺失测试目录会阻断标签发布的问题。
- **CI**：更新 GitHub Actions 到当前主版本。

## 🐛 问题修复

- **发布检查入口**：发布工作流原本调用不存在的 `scripts/tests` 目录；现已增加对应测试用例，避免在构建 APK 前因测试入口缺失而失败。
- **更新下载取消**：使用当前 Dio `CancelToken` 的取消状态和错误对象，修复静态分析中不存在的方法调用。取消时仍会清理未完成的 APK 临时文件。
- **更新地址测试**：将测试样例对齐到当前受信任的 GitHub 仓库、Release 标签及 SHA-256 校验要求。

## 🔒 安全与兼容性

- 更新 APK 仅接受本仓库 HTTPS Release 链接，并校验标签、架构、文件大小和 SHA-256；实际安装由 Android 系统确认，不进行静默安装。
- 保持应用 ID 与正式发布签名。覆盖升级仍要求相同签名和更高的设备实际 versionCode；本版源码基数为 `24`。

## 📦 下载与安装

| 文件名 | 平台 / 架构 | 说明 |
|---|---|---|
| `linux_do_android_release_1.2.0_arm64-v8a.apk` | Android / arm64-v8a | 现代 64 位 ARM 设备 |
| `linux_do_android_release_1.2.0_armeabi-v7a.apk` | Android / armeabi-v7a | 32 位 ARM 设备 |
| `linux_do_android_release_1.2.0_x86_64.apk` | Android / x86_64 | x86 Android 设备或模拟器 |

- 首次安装：从本次 Release 下载与设备 ABI 匹配的 APK，并按 Android 系统提示确认安装。
- 已安装用户：可使用应用内更新提示下载并安装；系统可能要求允许 LINUX DO 发起安装。也可从本次 Release 手动下载对应架构 APK。

## 🔄 升级与数据迁移

- **兼容性**：保持原应用 ID 和正式签名；覆盖安装要求签名一致且实际 versionCode 高于已安装包。
- **配置和数据**：正常覆盖安装通常保留应用数据；卸载后再安装可能清除本地数据，建议先备份。
- **回退方式**：Android 通常不允许直接覆盖安装更低 versionCode 的旧包；回退前备份数据，卸载再安装可能清除本地数据。

## 🧪 验证结果

- 仓库上传边界检查：通过，检查 2,323 个索引文件；已移除旧的生成调研快照。
- Git 忽略规则：通过，覆盖 Python 字节码、常见编辑器临时文件及 Windows 系统杂项，并确认 `pubspec.lock` 与生成源码仍不被忽略。
- Flutter/Dart 测试、静态分析、Android 构建与真机安装：本地环境未安装 Flutter/Dart，需以本次 GitHub Actions 发布工作流结果为准。

## ⚠️ 已知问题

- 真实账号、不同 Android 厂商的安装权限提示和设备行为未在本地真机验证。

---

**项目地址：** https://github.com/yuchen0x1/LINUX-DO

**问题反馈：** https://github.com/yuchen0x1/LINUX-DO/issues

**版本下载：** https://github.com/yuchen0x1/LINUX-DO/releases/tag/v1.2.0
