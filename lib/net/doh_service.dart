import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';

class DohServer {
  final String id;
  final String name;
  final String url;
  final String ip;
  int? pingMs;

  DohServer({
    required this.id,
    required this.name,
    required this.url,
    required this.ip,
    this.pingMs,
  });
}

class DohService {
  static final DohService _instance = DohService._internal();
  factory DohService() => _instance;
  DohService._internal();

  static const String keyDohEnabled = 'doh_enabled';
  static const String keyDohServerId = 'doh_server_id';

  final List<DohServer> servers = [
    DohServer(
      id: 'aliyun',
      name: '阿里 DNS (推荐·低延迟)',
      url: 'https://dns.alidns.com/resolve',
      ip: '223.5.5.5',
    ),
    DohServer(
      id: 'dnspod',
      name: '腾讯 DNSPod',
      url: 'https://doh.pub/dns-query',
      ip: '119.29.29.29',
    ),
    DohServer(
      id: 'cloudflare',
      name: 'Cloudflare (1.1.1.1)',
      url: 'https://cloudflare-dns.com/dns-query',
      ip: '1.1.1.1',
    ),
    DohServer(
      id: 'google',
      name: 'Google DNS (8.8.8.8)',
      url: 'https://dns.google/resolve',
      ip: '8.8.8.8',
    ),
  ];

  bool get isEnabled => StorageManager.getBool(keyDohEnabled) ?? true;
  set isEnabled(bool value) => StorageManager.setData(keyDohEnabled, value);

  String get currentServerId =>
      StorageManager.getString(keyDohServerId) ?? 'aliyun';
  set currentServerId(String id) => StorageManager.setData(keyDohServerId, id);

  DohServer get currentServer {
    return servers.firstWhere(
      (s) => s.id == currentServerId,
      orElse: () => servers.first,
    );
  }

  /// 测速所有 DoH 节点
  Future<void> pingAll() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 3500),
        receiveTimeout: const Duration(milliseconds: 3500),
      ),
    );

    for (var server in servers) {
      final sw = Stopwatch()..start();
      try {
        final resp = await dio.get(
          server.url,
          queryParameters: {'name': 'linux.do', 'type': 'A'},
          options: Options(headers: {'Accept': 'application/dns-json'}),
        );
        sw.stop();
        if (resp.statusCode == 200) {
          server.pingMs = sw.elapsedMilliseconds;
        } else {
          server.pingMs = -1;
        }
      } catch (e) {
        sw.stop();
        server.pingMs = -1;
      }
    }
  }

  /// 通过选定的 DoH 解析域名
  Future<List<String>> resolve(String domain) async {
    if (!isEnabled) {
      final list = await InternetAddress.lookup(domain);
      return list.map((a) => a.address).toList();
    }

    try {
      final server = currentServer;
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 4000),
          receiveTimeout: const Duration(milliseconds: 4000),
        ),
      );

      final resp = await dio.get(
        server.url,
        queryParameters: {'name': domain, 'type': 'A'},
        options: Options(headers: {'Accept': 'application/dns-json'}),
      );

      if (resp.statusCode == 200 && resp.data != null) {
        final data = resp.data is String ? json.decode(resp.data) : resp.data;
        final answers = data['Answer'] as List?;
        if (answers != null && answers.isNotEmpty) {
          final ips = <String>[];
          for (var item in answers) {
            if (item['data'] != null) {
              ips.add(item['data'].toString());
            }
          }
          if (ips.isNotEmpty) {
            l.d('DoH (${server.name}) 解析 $domain 成功 -> $ips');
            return ips;
          }
        }
      }
    } catch (e) {
      l.e('DoH 解析异常，回退系统 DNS: $e');
    }

    final fallback = await InternetAddress.lookup(domain);
    return fallback.map((a) => a.address).toList();
  }
}
