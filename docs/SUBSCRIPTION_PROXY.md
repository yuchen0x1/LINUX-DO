# Android 订阅与自动选线

自 Android v1.1.2 提供。登录页和网络设置共用同一入口。

粘贴 Clash / Mihomo YAML 订阅链接，点击“导入节点”，之后自动完成连接和选线。支持包含 `proxies` 的节点列表，最多 200 个节点、2 MB。支持 HTTP、SOCKS5、Shadowsocks、ShadowsocksR、VMess、VLESS、Trojan、Hysteria、Hysteria2、AnyTLS、TUIC；不支持的格式会明确提示。

通过访问 linux.do 的实际 HTTPS 请求检测可用性，优先选择低延迟节点。当前节点连接失败时尝试下一个未失败节点；读取请求会继续换线，直到成功或该轮所有节点均失败。全部失败后停止循环并提示“节点异常”，用户更新订阅或重新检测后开始新一轮。不会静默直连。原有主机与端口保留在折叠的手动选项内。只代理本应用的 Dio 和 Android WebView，不申请 VPN、不修改系统代理。发帖、回复等写操作不会因换线自动重放；切换不能恢复已中断的上传。

订阅内容、链接保存在 Android 加密存储，密钥库写入失败则中止导入。运行时配置只写应用私有目录，关闭代理后删除；不写入日志、源码。忽略订阅里的规则、监听器、DNS、代理提供者和控制接口，应用自行生成配置。更新失败保留之前的配置。

## 构建和许可

`android/network-core.lock.json` 固定上游 1.19.34、提交和三个 ABI 的官方压缩包 SHA-256。构建时通过 `scripts/prepare_network_core.py` 下载、校验并解压到忽略的 `build/app/network-core/`，不提交二进制。核心从 APK 的 nativeLibraryDir 作为独立进程执行；不从订阅下载可执行代码。64 位 ELF 的 LOAD 段为 16 KB 对齐，APK 仍需按发布流程检查。

代理和控制接口只绑定 127.0.0.1，控制接口每次启动生成随机口令。配置先校验再替换正在工作的核心。Dio 连接代理时不使用会绕过代理的直连 DoH socket factory。

核心来自 [mihomo 官方 Release v1.19.34](https://github.com/MetaCubeX/mihomo/releases/tag/v1.19.34)，准确提交 `0455d0d28c4526937380505153e65a843d8612e8`，[对应源码归档](https://github.com/MetaCubeX/mihomo/archive/0455d0d28c4526937380505153e65a843d8612e8.tar.gz)。

核心遵循 GPL-3.0，原应用源码维持既有 MIT 许可；分发二进制需保留对应核心源码获取方式及许可。完整 GPL 和 NOTICE 随 APK 打包，可从代理窗口的“开源许可”查看。v1.1.2 Release 同时附带 `mihomo-source-v1.19.34.tar.gz` 对应源码归档，归档内容来自上述固定提交。不能将全部第三方组件概括为 MIT。
