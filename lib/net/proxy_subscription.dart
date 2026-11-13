import 'dart:convert';

import 'package:yaml/yaml.dart';

class SubscriptionException implements Exception {
  const SubscriptionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SubscriptionNode {
  const SubscriptionNode({
    required this.id,
    required this.name,
    required this.type,
    required this.configuration,
  });
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> configuration;
}

/// Import nodes only. Remote DNS, rules, providers, listeners and API settings
/// cannot override the application's loopback-only configuration.
class ProxySubscription {
  const ProxySubscription(this.nodes, {this.skipped = 0});
  final List<SubscriptionNode> nodes;
  final int skipped;
  static const maxBytes = 2 * 1024 * 1024;
  static const maxNodes = 200;
  static const group = 'LINUX_DO_AUTO';
  static const testUrl = 'https://linux.do/robots.txt';
  static const supportedTypes = {
    'http',
    'socks5',
    'ss',
    'ssr',
    'vmess',
    'vless',
    'trojan',
    'hysteria',
    'hysteria2',
    'anytls',
    'tuic',
  };
  static const _nodeFields = {
    'type',
    'server',
    'port',
    'username',
    'password',
    'cipher',
    'uuid',
    'alterId',
    'security',
    'tls',
    'skip-cert-verify',
    'servername',
    'sni',
    'alpn',
    'client-fingerprint',
    'fingerprint',
    'flow',
    'network',
    'ws-opts',
    'http-opts',
    'h2-opts',
    'grpc-opts',
    'reality-opts',
    'packet-encoding',
    'udp',
    'xudp',
    'tfo',
    'ip-version',
    'obfs',
    'obfs-password',
    'obfs-param',
    'protocol',
    'protocol-param',
    'plugin',
    'plugin-opts',
    'up',
    'down',
    'up-speed',
    'down-speed',
    'ports',
    'mport',
    'auth',
    'auth-str',
    'recv-window',
    'recv-window-conn',
    'disable-mtu-discovery',
    'fast-open',
    'heartbeat-interval',
    'congestion-controller',
    'token',
    'reduce-rtt',
    'udp-relay-mode',
    'idle-session-check-interval',
    'idle-session-timeout',
    'min-idle-session',
  };

  static Uri parseUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        !{'https', 'http'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw const SubscriptionException('请填写有效的 HTTP 或 HTTPS 订阅链接');
    }
    return uri;
  }

  static ProxySubscription parse(String text) {
    if (utf8.encode(text).length > maxBytes) {
      throw const SubscriptionException('订阅超过 2 MB，请使用较小的节点订阅');
    }
    dynamic document;
    try {
      document = loadYaml(text);
    } catch (_) {
      throw const SubscriptionException('订阅格式无法识别，请使用 Clash / Mihomo YAML 订阅');
    }
    final rawNodes = document is Map ? document['proxies'] : document;
    if (rawNodes is! List || rawNodes.isEmpty) {
      throw const SubscriptionException('订阅中没有节点，请使用包含 proxies 的 YAML 订阅');
    }
    if (rawNodes.length > maxNodes) {
      throw const SubscriptionException('订阅节点超过 200 个，请先精简订阅');
    }
    final nodes = <SubscriptionNode>[];
    var skipped = 0;
    for (final raw in rawNodes) {
      if (raw is! Map || !supportedTypes.contains(raw['type'])) {
        skipped++;
        continue;
      }
      final host = raw['server'];
      final port = int.tryParse('${raw['port']}');
      if (host is! String ||
          host.trim().isEmpty ||
          RegExp(r'[\s/\\]').hasMatch(host) ||
          port == null ||
          port < 1 ||
          port > 65535) {
        skipped++;
        continue;
      }
      final id = 'node_${nodes.length + 1}';
      final config = <String, dynamic>{'name': id};
      final budget = [0];
      try {
        for (final key in _nodeFields) {
          if (raw.containsKey(key)) config[key] = _plain(raw[key], 0, budget);
        }
      } on SubscriptionException {
        skipped++;
        continue;
      }
      config['port'] = port;
      config['server'] = host.trim();
      var name = raw['name'] is String ? (raw['name'] as String).trim() : '';
      name = name.replaceAll(RegExp(r'[\x00-\x1f]'), ' ');
      if (name.isEmpty) name = '节点 ${nodes.length + 1}';
      if (name.length > 100) name = name.substring(0, 100);
      nodes.add(
        SubscriptionNode(
          id: id,
          name: name,
          type: raw['type'] as String,
          configuration: config,
        ),
      );
    }
    if (nodes.isEmpty) {
      throw const SubscriptionException('订阅中没有可用的受支持节点，请检查订阅内容');
    }
    return ProxySubscription(List.unmodifiable(nodes), skipped: skipped);
  }

  static dynamic _plain(dynamic value, int depth, List<int> budget) {
    if (++budget[0] > 4096) throw const SubscriptionException('节点配置过大');
    if (depth > 12) throw const SubscriptionException('节点配置嵌套过深');
    if (value is Map) {
      if (value.length > 100) throw const SubscriptionException('节点配置过大');
      return {
        for (final entry in value.entries)
          if (entry.key is String)
            entry.key as String: _plain(entry.value, depth + 1, budget),
      };
    }
    if (value is List) {
      if (value.length > 100) throw const SubscriptionException('节点配置过大');
      return value.map((item) => _plain(item, depth + 1, budget)).toList();
    }
    if (value == null || value is String || value is num || value is bool)
      return value;
    throw const SubscriptionException('节点配置包含不支持的数据');
  }

  Map<String, dynamic> coreConfiguration() => {
    'mode': 'rule',
    'log-level': 'silent',
    'ipv6': false,
    'allow-lan': false,
    'bind-address': '127.0.0.1',
    'find-process-mode': 'off',
    'geo-auto-update': false,
    'profile': {'store-selected': false, 'store-fake-ip': false},
    'dns': {'enable': false},
    'proxies': nodes.map((node) => node.configuration).toList(),
    'proxy-groups': [
      {
        'name': group,
        'type': 'select',
        'proxies': ['REJECT', ...nodes.map((node) => node.id)],
      },
    ],
    'rules': ['MATCH,$group'],
  };
}
