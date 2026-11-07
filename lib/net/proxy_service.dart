import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'cronet_adapter.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';

/// 应用级 HTTP 代理服务
///
/// 国内网络直连 linux.do 不通时的标准解决方案：
/// 手机上运行 Clash / v2rayNG 等代理 App（导入节点订阅），
/// 本 App 将 Dio 网络层与 WebView 同时指向其本地 HTTP 端口。
class ProxyService {
  static final ProxyService _instance = ProxyService._internal();
  factory ProxyService() => _instance;
  ProxyService._internal();

  static const String keyEnabled = 'http_proxy_enabled';
  static const String keyHost = 'http_proxy_host';
  static const String keyPort = 'http_proxy_port';

  bool get isEnabled => StorageManager.getBool(keyEnabled) ?? false;
  String get host => StorageManager.getString(keyHost) ?? '';
  String get port => StorageManager.getString(keyPort) ?? '';

  bool get hasValidRule =>
      isEnabled && host.trim().isNotEmpty && port.trim().isNotEmpty;

  /// Dio findProxy 使用的规则串，如 `PROXY 127.0.0.1:7890`
  String get dioRule => 'PROXY ${host.trim()}:${port.trim()}';

  /// 清理用户输入：去掉协议前缀、多余空格
  static String sanitizeHost(String raw) {
    var h = raw.trim();
    if (h.startsWith('http://')) h = h.substring(7);
    if (h.startsWith('https://')) h = h.substring(8);
    if (h.contains('/')) h = h.split('/').first;
    return h.trim();
  }

  /// 保存配置并立即生效（Dio + WebView）
  Future<void> save({
    required bool enabled,
    required String host,
    required String port,
  }) async {
    await StorageManager.setData(keyEnabled, enabled);
    await StorageManager.setData(keyHost, sanitizeHost(host));
    await StorageManager.setData(keyPort, port.trim());
    await applyToWebView();
  }

  /// 将代理应用到 Dio 网络层（重建 HttpClientAdapter）
  ///
  /// - 启用代理：Dart HttpClient + findProxy（可精确路由到 Clash 等本地端口，
  ///   但 TLS 指纹会被 Cloudflare 挑战，需配合过盾 Cookie）
  /// - 未启用代理：Cronet（Chromium 网络栈），浏览器级 TLS 指纹，天然过盾
  void applyToDio(Dio dio) {
    try {
      if (hasValidRule) {
        final rule = dioRule;
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.findProxy = (uri) => rule;
            return client;
          },
        );
        l.i('Dio 已启用 HTTP 代理: $rule');
      } else {
        dio.httpClientAdapter = CronetHttpClientAdapter();
        l.i('Dio 已切换到 Cronet 网络栈（Chromium TLS 指纹）');
      }
    } catch (e) {
      l.e('应用 Dio 适配器失败: $e');
    }
  }

  /// 将代理应用到全部 WebView（Android ProxyController，作用于之后创建的 WebView）
  Future<void> applyToWebView() async {
    try {
      final proxyController = ProxyController();
      if (hasValidRule) {
        await proxyController.setProxyOverride(
          settings: ProxySettings(
            proxyRules: [ProxyRule(url: '${host.trim()}:${port.trim()}')],
            bypassRules: ['localhost', '127.0.0.1'],
          ),
        );
        l.i('WebView 已启用代理: ${host.trim()}:${port.trim()}');
      } else {
        await proxyController.clearProxyOverride();
        l.i('WebView 代理已清除');
      }
    } catch (e) {
      l.e('应用 WebView 代理失败: $e');
    }
  }
}
