# Android 仓库清理与上传边界

本仓库只维护 Android 客户端。清理以当前构建输入和实际引用为依据；历史版本可从 Git 标签恢复，不把旧平台模板、一次性报告或本机缓存作为当前源码保留。

## 应当保留的文件

- `lib/`、`assets/`、`android/` 中的应用源码、正式资源和构建配置。
- `pubspec.yaml` 与 `pubspec.lock`：本项目是应用，锁文件是可复现构建的输入。
- `lib/**/*.g.dart`：当前构建使用的模型和接口生成代码。
- `third_party/` 中的兼容补丁、许可证和声明文件，以及 `assets/licenses/` 中的许可信息。
- `test/`、`scripts/`、`.github/` 和面向使用者、维护者的文档。

不能仅凭“生成文件”、文件名重复或暂时未找到直接引用就删除构建输入、Android 不同密度资源、表情、字体或许可证。

## 不进入源码仓库的文件

| 内容 | 位置或示例 | 处理方式 |
|---|---|---|
| 可重新生成的工具和构建缓存 | `build/`、`.dart_tool/`、`android/.gradle/`、`android/.kotlin/`、`__pycache__/` | 已忽略；构建结束后可按需清理 |
| 本地安装包与调试符号 | `dist/`、APK/AAB/IPA | 已忽略；发布包上传到 GitHub Release，符号按诊断需要单独保留 |
| 调研输出与 API 缓存 | `dist/research/`、`dist/research-api/` | 调研脚本与维护工作流统一输出到 `dist/` |
| 编辑器临时文件与系统杂项 | `*.swp`、`*.swo`、`*~`、`*.tmp`、`*.bak`、`*.orig`、`*.rej`、`.DS_Store`、`Thumbs.db`、`Desktop.ini` | 已忽略，上传边界检查也会拒绝 |
| 签名、凭据和本机配置 | keystore、`key.properties`、`local.properties`、真实 `.env` | 已忽略；清理缓存时不得连同签名或配置删除 |
| 历史隔离文件 | `.local-archive/`、`.autonomous-upgrade/` | 已忽略；如本机存在，逐项确认后处理，不整目录删除备份 |
| 非 Android 平台模板 | 根目录 `ios/`、`macos/`、`windows/`、`web/`、`linux/` | 当前分支不维护，不提交 |

`dist/` 和本地归档不能加入 `pubspec.yaml` 的 assets。`scripts/research_ecosystem.py` 默认输出 `dist/research/latest.json`；旧的固定研究快照无需入库。

## 上传前检查

```bash
python3 scripts/check_repository_hygiene.py
python3 -m unittest discover -s scripts/tests -v
git diff --check
git status --short
```

Windows 可使用 `python` 替换 `python3`。常规 CI、手动 Android 构建及标签发布工作流都会运行上传边界检查。

检查脚本读取 Git 索引中的现存文件，拒绝本地缓存、安装包、签名材料、临时文件、不维护的平台路径和常见 GitHub token/私钥标记。平台限制只作用于仓库根目录，`android/.../com/linux/...` 等合法包路径不受影响。检查只输出路径和规则名，不打印凭据内容，也不会自动删除、暂存或推送文件。

工作树中已删除的索引文件会跳过；提交前仍应核对 `git diff --stat`，确保删除进入提交。忽略规则不能使已经跟踪的文件自动退出 Git；删除当前文件也不会抹掉 Git 历史中的内容。凭据扫描是有限规则检查，不能替代专门的保密性审查。

## 发布与旧版更新

源码版本与构建号来自 `pubspec.yaml`。标签发布工作流校验版本、原签名证书、三种 ABI APK、SHA-256 清单及更新元数据后发布正式 Release。每版正文保存在 `docs/releases/release-notes-vX.Y.Z.md`，按更新模板填写；历史汇总见 [更新日志](releases/release-notes.md)。

v1.1.0 起的客户端使用本仓库的 GitHub 最新正式 Release 检查更新，因此发布时必须保留对应 APK 附件及兼容的命名，并设置为最新正式版。覆盖安装还要求相同签名和递增的实际 versionCode；发现更新不等于已经完成真机安装验证。
