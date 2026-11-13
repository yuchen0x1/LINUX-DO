# Android 仓库清理与上传边界

> 本文是 2026-11-13 清理阶段的验证快照。清理内容纳入后续 v1.1.1 发布工作；当前版本与构建环境以 README、pubspec.yaml 和对应 GitHub Release 为准，下文“未推送”等描述保留当时的执行边界。

整理日期：2026-11-13。应用版本保持 `1.1.0+12`。本轮没有提交、推送、修改 GitHub Release 正文、删除远程资产或改写 Git 历史。

## 版本记录

- 已从远端补全本地浅克隆的历史和标签，依据 14 个标签逐版本补齐 [更新日志](releases/release-notes.md)。
- v0.0.3 标签对应源码 `0.0.2+1`，v1.0.4 对应源码 `1.0.3+6`；保留历史事实，不重打标签。
- 当前 fork 只查到 v1.0.9、v1.1.0 两个 Release。其他标签记为上游历史，不等同于当前 fork 已发布对应安装包。
- 纠正旧描述：v1.0.9 有手动草稿，防抖自动保存属于 v1.1.0；DoH 配置出现与真正接入解析也分开记录。
- 中英文 README 统一为 Android 定位，移除 iOS/桌面/Web 构建指引和无依据的离线阅读宣传。

## 本地处理结果

永久删除命令两次被自动审批审查拒绝，返回 `blocked by policy`，未提供更具体原因。因此采用可恢复的本地隔离，**没有把“移走文件”计作磁盘空间释放**。

| 原位置 | 结果 | 恢复/保留方式 |
|---|---|---|
| `ios/`、`macos/`、`windows/`、`web/` | 从当前 Android 工作树移除 | `.local-archive/retired-platforms/` 保留完整目录；已跟踪内容也可从 v1.1.0 恢复 |
| `build_unsigned_ipa.sh`、iOS workflow | 移出当前构建入口 | `.local-archive/retired-files/` 保留，不再维护非安卓版构建 |
| `1.2.1` | 确认为依赖安装输出，不是应用版本文件 | 隔离到 `.local-archive/retired-files/` |
| `ui.xml`、3 张调试截图 | 不属于正式资源 | 隔离到 `.local-archive/retired-files/` |
| `android/build/reports/problems/problems-report.html` | 已跟踪的机器生成 Gradle 报告 | 隔离 `android/build/`，并新增忽略规则，准备从后续提交树移除 |
| `assets/design/source/` 的 8 张旧 PNG/JPG | 不在应用 assets 声明中，实际界面已使用 WebP | 隔离旧原图；保留现用 WebP 和全部表情等正式资源 |
| `scripts/optimize_assets.py` | 只面向旧 PNG 输入，当前输入已被替代 | 隔离旧的一次性转换脚本，避免误当当前构建步骤 |
| `.autonomous-upgrade/` 的 9 份过程报告 | 从产品仓库工作树移出 | `.local-archive/upgrade-2026-11-10/`，有用版本信息已整理进正式文档 |
| `build/`、Dart 编译/原生 hooks 缓存、Android `.gradle/` 与 `.kotlin/` | 隔离 42,150 个文件，约 5.801 GiB | `.local-archive/retired-cache/`；未永久删除，当前磁盘未因此回收该容量 |
| `.dart_tool/package_config.json` 等轻量元数据 | 保留 | 便于继续开发，仍被 Git 忽略 |

对已跟踪文件，Git 显示工作树删除，归档内容被忽略；这意味着清理已经准备成本地差异，**不意味着远端文件已消失**。当前共从应用工作树移除 156 个已跟踪文件。

### 保留的发布文件与诊断材料

以下均不上传到源码仓库：

- `dist/` 内 v1.1.0 的三种 Android APK，SHA-256 与远端 Release 资产逐一一致。
- 从构建目录复制并逐文件核验到 `dist/diagnostics-v1.1.0/` 的 Android 混淆映射、native-debug-symbols.zip 和 APK 输出元数据，避免清理构建缓存时丢失崩溃分析材料。
- 当前签名文件、`android/keystore/key.properties`、外层 `keystore_backup/`，未删除或修改签名密钥及口令。
- `pubspec.lock`、源码生成的 `.g.dart`、正式图片/表情/字体资源和 Android Gradle 配置。

外层目录中旧 v1.0.8 APK、临时脚本及其旧源码备份也已转入外层 `.local-archive/`。
281 个旧脚本/源码备份文件另外生成 ZIP 并逐项校验完整性，原始文件也因删除受限而继续保留在隔离区。

## 远端核查

通过 Git SSH 和 GitHub API 只读核对 [yuchen0x1/LINUX-DO](https://github.com/yuchen0x1/LINUX-DO)：远端 `main` 为 `f707d4842aca1409694a443df03f640878fbb0ab`，与本轮起始本地 HEAD 一致。

因此可确认远端主分支中包含：

- 无用依赖输出 `1.2.1`；
- `android/build/reports/problems/problems-report.html`；
- 非 Android 平台工程及 iOS 构建脚本/工作流；
- 8 张已被替代的设计原图和 9 份过程报告。

当前远端主分支没有发现已跟踪的 APK/AAB/IPA、签名密钥、key.properties、local.properties 或 `.dart_tool`/Gradle 缓存。对 2,377 个起始跟踪文件做了常见 GitHub token/私钥标记检查，未发现匹配；这是有限规则扫描，不是完整保密性证明。

历史 v1.0.9 的 Android 构建脚本确实出现过字面量签名口令；当前树已移除该做法。本轮不打印口令，也不改写历史；删除当前分支文件不能抹掉旧提交中的内容。

外层 `yuchen0x1/linuxdoAndroid` 的 SSH 返回 Repository not found，GitHub API 返回 404。无法区分仓库不存在、已改名或当前无访问权限，因此没有把本地跟踪内容冒充远端实际内容。

## 防止再次上传

1. `.gitignore` 排除本地归档、工具/构建缓存、旧平台、APK/AAB/IPA、签名文件、密钥配置与真实环境配置。
2. 新增 `scripts/check_repository_hygiene.py`，检查索引中的现存文件，拒绝不应上传的路径和常见 token/私钥标记，只输出路径与规则名，不输出匹配内容。
3. 常规 CI 和手动 Android 构建流程都在获取依赖前运行该检查。
4. 平台目录限制只作用于仓库根目录，保留 `android/.../com/linux/...` 等合法 Android 包路径。
5. `.local-archive/` 不进入 Dart 分析和应用 assets。不要把本地归档、诊断材料或 APK 强制加入 Git。

本地检查：

```bash
python scripts/check_repository_hygiene.py
git diff --check
git status --short
```

在未提交的清理阶段，脚本跳过已从工作树移除的索引路径；提交后它们应当从索引中移除。它不会删除文件、自动暂存或推送代码。

## 验证与限制

| 检查 | 状态 | 结果 |
|---|---|---|
| `python scripts/check_repository_hygiene.py` | PASS | 当前现存索引文件通过 |
| 隔离索引负例 | PASS | 本地归档路径和私钥标记样本均被拒绝；没有更改真实 Git 索引 |
| `flutter test --no-pub --reporter compact` | PASS | 49 项通过，exit 0 |
| `flutter analyze --no-pub --no-fatal-infos` | FAIL | 分析服务初始化时出现 `FormatException: Unterminated string`，exit 255；不能当作静态检查通过 |
| 备用 `dart analyze` | PASS | exit 0，0 error / 0 warning，仍有 128 条 info；没有关闭实际源码规则规避问题 |
| 外层 `npm run verify` | PASS | 38 项工具回归通过，原有未提交工作保留 |
| Git diff 空白检查、版本覆盖和文档链接 | PASS | 最终复核，无新增空白/本地链接问题，14 个标签均有日志 |
| 永久删除与磁盘释放 | BLOCKED | 自动审批拒绝；已转本地隔离，实际释放量记为 0 |
| Android 重新构建/安装、真机功能 | 未执行 | 本轮为文档与仓库边界清理；现有发布包摘要保持一致，不把旧 APK 当成本轮新构建 |
| 远程清理、Release 正文与远程 CI | 未执行 | 未提交/推送/发布；远端仍保留起始内容 |

本机用的是已安装 SDK，CI 仍固定项目原有 Flutter 3.35.7。若需要释放隔离缓存占用的磁盘空间，需要在人工核对 `.local-archive/retired-cache/` 后由有权限的操作者删除；不要整删包含备份、历史记录的整个 `.local-archive/`。
