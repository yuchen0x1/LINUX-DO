# 安全报告与维护

目前维护 Android 最新正式版。请先升级到最新版本复现；历史安装包保留用于追溯，不代表仍在接收修复。

通过 [GitHub 私密漏洞报告](https://github.com/yuchen0x1/LINUX-DO/security/advisories/new) 报告漏洞。不要在公开 Issue 上传 Cookie、User API Key、订阅 URL、私钥或带账号信息的日志。维护者会尽力在七天内回复，修复时间视严重程度与复现条件而定。

正式更新从本仓库 GitHub Releases 的 HTTPS API 获取。APK 需匹配设备 ABI，下载后核对 GitHub 提供的 SHA-256 与大小，再由 Android 原生层核对包名、递增 versionCode 和当前安装证书。SHA-256 只验证完整性；发布者身份由 Android 签名连续性保护。新安装用户需从本仓库可信 Release 获取首个安装包。

密钥不进入仓库。正式发版必须提供已有发布密钥，禁止临时生成新证书替代。混淆符号仅私下留存。凭据存储、Cookie、WebView 会话及订阅配置仍属于敏感数据；开源和混淆都不能替代服务端权限检查。
