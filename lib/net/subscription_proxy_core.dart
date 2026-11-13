import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

import 'proxy_subscription.dart';

abstract class SubscriptionProxyCore {
  int? get port;
  Future<void> start(Map<String, dynamic> configuration);
  Future<Map<String, int>> probe();
  Future<void> select(String nodeId);
  Future<String?> currentNode();
  Future<void> stop();
}

class AndroidSubscriptionProxyCore implements SubscriptionProxyCore {
  static const _channel = MethodChannel('com.linux.linuxdo/network_core');
  Dio? _controller;
  int? _port;
  @override
  int? get port => _port;

  @override
  Future<void> start(Map<String, dynamic> configuration) async {
    // Native side always replaces the bind address, ports and controller secret.
    Map<String, dynamic>? endpoint;
    try {
      endpoint = await _channel.invokeMapMethod<String, dynamic>('start', {
        'config': _encode(configuration),
      });
    } on MissingPluginException {
      throw const SubscriptionException('请重启应用后重新连接（NC-0：线路组件未就绪）');
    } on PlatformException catch (error) {
      final details = error.details;
      final stage = details is Map ? details['stage'] : null;
      final type = details is Map ? details['type'] : null;
      // Diagnostic values are internal enum/class names, never the exception text.
      final code = '$stage/$type'.replaceAll(RegExp(r'[^a-zA-Z0-9/_-]'), '');
      const diagnostics = bool.fromEnvironment('LINUXDO_PROXY_DIAGNOSTICS');
      final diagnostic = diagnostics && details is Map
          ? details['diagnostic'] ?? ''
          : '';
      throw SubscriptionException(
        '线路启动失败，请重试（NC-1：$code）${diagnostic == '' ? '' : '\n$diagnostic'}',
      );
    }
    if (endpoint == null) throw const SubscriptionException('代理核心未能启动');
    _port = endpoint['port'] as int;
    _controller?.close();
    _controller =
        Dio(
            BaseOptions(
              baseUrl: 'http://127.0.0.1:${endpoint['controllerPort']}',
              connectTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 8),
              headers: {'Authorization': 'Bearer ${endpoint['secret']}'},
            ),
          )
          ..httpClientAdapter = IOHttpClientAdapter(
            createHttpClient: () {
              return HttpClient()..findProxy = (_) => 'DIRECT';
            },
          );
  }

  @override
  Future<Map<String, int>> probe() async {
    Response<Map<String, dynamic>> response;
    try {
      response = await _controller!.get<Map<String, dynamic>>(
        '/group/${ProxySubscription.group}/delay',
        queryParameters: {
          'url': ProxySubscription.testUrl,
          'timeout': 4000,
          'expected': '200-499',
        },
      );
    } on DioException catch (error) {
      // The core explicitly reports HTTP 504 when every tested proxy times out.
      if (error.response?.statusCode == 504) return {};
      rethrow;
    }
    return {
      for (final entry in (response.data ?? {}).entries)
        if (entry.value is num && (entry.value as num) >= 0)
          entry.key: (entry.value as num).toInt(),
    };
  }

  @override
  Future<void> select(String nodeId) async {
    await _controller!.put<void>(
      '/proxies/${ProxySubscription.group}',
      data: {'name': nodeId},
    );
  }

  @override
  Future<String?> currentNode() async {
    final response = await _controller!.get<Map<String, dynamic>>(
      '/proxies/${ProxySubscription.group}',
    );
    return response.data?['now'] as String?;
  }

  @override
  Future<void> stop() async {
    _controller?.close(force: true);
    _controller = null;
    _port = null;
    await _channel.invokeMethod<void>('stop');
  }
}

// Keep JSON encoding here rather than crossing the method channel with YAML types.
String _encode(Map<String, dynamic> value) => jsonEncode(value);
