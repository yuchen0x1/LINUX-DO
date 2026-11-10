import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/log.dart';
import 'deep_link_service.dart';

/// 接收系统「分享到」的文本。
///
/// Android 侧由 [MainActivity] 通过 MethodChannel 转发：
/// - 冷启动：Dart 主动调 `getInitialShare` 取一次
/// - 应用已在前台：原生侧主动 `invokeMethod('onShare')`
///
/// 处理策略：
/// - 文本里第一个链接是 linux.do 的，直接跳帖子/用户页
/// - 否则带着原文跳到发帖页，把内容预填进去
class ShareIntentService {
  static const MethodChannel _channel = MethodChannel(
    'com.linux.linuxdo/share',
  );

  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  bool _started = false;
  bool _consumerReady = false;
  String? _pending;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _channel.setMethodCallHandler(_onMethodCall);
    if (_consumerReady) await _flushPending();
  }

  /// 首页就绪后调用：消费冷启动时携带的分享内容。
  Future<void> markConsumerReady() async {
    _consumerReady = true;
    await consumeInitial();
    await _flushPending();
  }

  /// 主动向原生侧取一次初始分享内容（幂等：拿到后原生侧会清空）。
  Future<void> consumeInitial() async {
    try {
      final text = await _channel.invokeMethod<String>('getInitialShare');
      if (text == null || text.trim().isEmpty) return;
      _dispatch(text);
    } on MissingPluginException {
      // 非 Android 或未注册通道，静默跳过
    } catch (e) {
      l.d('读取初始分享内容失败: $e');
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method != 'onShare') return null;
    final text = call.arguments;
    if (text is! String || text.trim().isEmpty) return null;
    if (!_consumerReady) {
      _pending = text;
      return null;
    }
    _dispatch(text);
    return null;
  }

  Future<void> _flushPending() async {
    final text = _pending;
    if (text == null) return;
    _pending = null;
    _dispatch(text);
  }

  void _dispatch(String raw) {
    final target = classify(raw);
    if (target == null) return;

    if (target.topicId != null) {
      l.i('分享内容命中帖子 #${target.topicId}');
      Get.toNamed(DeepLinkService.routeTopicDetail, arguments: target.topicId);
      return;
    }

    l.i('分享内容转入发帖页');
    Get.toNamed('/topic/create', arguments: {'content': target.content});
  }

  /// 把一段分享文本解析成跳转目标。纯函数，便于单测。
  static SharedTarget? classify(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final url = _firstUrl(text);
    if (url != null) {
      final topicId = _topicIdFrom(url);
      if (topicId != null) {
        return SharedTarget(topicId: topicId, content: text);
      }
    }
    return SharedTarget(topicId: null, content: text);
  }

  /// 只匹配 ASCII 可打印的 URL 字符集，遇到中文、空格、引号、尖括号即停止。
  /// 不用 `[^\s]+` 是因为那样会把紧跟链接的全角逗号、中文一起吞进来。
  static final RegExp _urlPattern = RegExp(
    r'https?://[A-Za-z0-9\-._~:/?#\[\]@!$&()*+,;=%]+',
  );

  /// URL 末尾常粘上句读，需要裁掉，否则最后一段 path 解析不出 id。
  static const String _trailingPunct = '.,;:!?)]';

  static String? _firstUrl(String text) {
    final match = _urlPattern.firstMatch(text);
    if (match == null) return null;
    var url = match.group(0)!;
    while (url.isNotEmpty && _trailingPunct.contains(url[url.length - 1])) {
      url = url.substring(0, url.length - 1);
    }
    return url.isEmpty ? null : url;
  }

  /// 从 linux.do 链接里取出帖子 id；不是本站帖子链接则返回 null。
  static int? _topicIdFrom(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final target = DeepLinkService().resolve(uri);
    if (target == null) return null;
    if (target.name != DeepLinkService.routeTopicDetail) return null;
    final arg = target.argument;
    return arg is int ? arg : null;
  }
}

/// 分享内容的解析结果。
///
/// [topicId] 非空表示应直接打开帖子；为空表示应进发帖页，
/// 把 [content] 作为正文初始内容。
class SharedTarget {
  final int? topicId;
  final String content;

  const SharedTarget({required this.topicId, required this.content});
}
