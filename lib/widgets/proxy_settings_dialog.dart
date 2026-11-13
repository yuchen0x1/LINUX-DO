import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../net/proxy_service.dart';
import '../net/proxy_subscription.dart';

Future<void> showProxySettingsDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const ProxySettingsDialog(),
);

class ProxySettingsDialog extends StatefulWidget {
  const ProxySettingsDialog({super.key});
  @override
  State<ProxySettingsDialog> createState() => _ProxySettingsDialogState();
}

class _ProxySettingsDialogState extends State<ProxySettingsDialog> {
  final _proxy = ProxyService();
  late final TextEditingController _url;
  late final TextEditingController _host;
  late final TextEditingController _port;
  String? _error;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: _proxy.subscriptionUrl);
    _host = TextEditingController(
      text: _proxy.isSubscription ? '' : _proxy.host,
    );
    _port = TextEditingController(
      text: _proxy.isSubscription ? '' : _proxy.port,
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() operation) async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    try {
      await operation();
    } on SubscriptionException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = '连接失败，请检查网络后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: AnimatedBuilder(
          animation: _proxy,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.globe, color: theme.primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '订阅与自动选线',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: _proxy.isBusy
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '粘贴 Clash / Mihomo 订阅链接，自动选择可用节点；当前节点失效时自动切换。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const ValueKey('subscription-url'),
                  controller: _url,
                  enabled: !_proxy.isBusy,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: '订阅链接',
                    hintText: 'https://…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('import-subscription'),
                    onPressed: _proxy.isBusy
                        ? null
                        : () =>
                              _run(() => _proxy.importSubscription(_url.text)),
                    icon: _proxy.isBusy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(CupertinoIcons.arrow_down_circle),
                    label: Text(_proxy.isBusy ? _proxy.progressLabel : '导入节点'),
                  ),
                ),
                if (_proxy.nodeCount > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    '已导入 ${_proxy.nodeCount} 个节点${_proxy.skippedCount > 0 ? "，跳过 ${_proxy.skippedCount} 个不支持或无效节点" : ""}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (_proxy.hasValidRule) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _proxy.statusLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_proxy.selectedDelay != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '延迟 ${_proxy.selectedDelay} ms · 自动检测并切换',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (_proxy.isSubscription && !_proxy.isBusy)
                          TextButton.icon(
                            onPressed: _proxy.isRecovering
                                ? null
                                : () => _run(() async {
                                    await _proxy.recheck();
                                  }),
                            icon: const Icon(
                              CupertinoIcons.speedometer,
                              size: 17,
                            ),
                            label: Text(
                              _proxy.isRecovering ? '检测中…' : '重新检测节点',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (_error != null || _proxy.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error ?? _proxy.errorMessage!,
                    key: const ValueKey('proxy-error'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('手动配置', style: theme.textTheme.bodyMedium),
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _host,
                      enabled: !_proxy.isBusy,
                      decoration: const InputDecoration(
                        labelText: '代理主机',
                        hintText: '127.0.0.1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _port,
                      enabled: !_proxy.isBusy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'HTTP 端口',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _proxy.isBusy
                              ? null
                              : () => _run(
                                  () => _proxy.save(
                                    enabled: true,
                                    host: _host.text,
                                    port: _port.text,
                                  ),
                                ),
                          child: const Text('使用手动代理'),
                        ),
                        TextButton(
                          onPressed: _proxy.isBusy
                              ? null
                              : () => _run(_proxy.disable),
                          child: const Text('恢复直连'),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'LINUX DO',
                  ),
                  child: const Text('开源许可'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared route entry: always reflects subscription import and automatic failover.
class ProxyEntryTile extends StatelessWidget {
  const ProxyEntryTile({super.key});
  @override
  Widget build(BuildContext context) {
    final proxy = ProxyService();
    return AnimatedBuilder(
      animation: proxy,
      builder: (context, _) => InkWell(
        borderRadius: BorderRadius.circular(10.w),
        onTap: () => showProxySettingsDialog(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.globe,
                size: 16.w,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 6.w),
              Text('网络线路与代理', style: TextStyle(fontSize: 13.sp)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  proxy.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: proxy.isConnected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(CupertinoIcons.chevron_right, size: 14.w),
            ],
          ),
        ),
      ),
    );
  }
}
