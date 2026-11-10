import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../utils/log.dart';

/// 深链处理：把外部 URL 转换成 App 内部路由。
///
/// 支持三类入口：
/// - `linuxdo://`            授权回调（由 WebPage 自己处理，这里忽略）与内部跳转
/// - `https://linux.do/t/...` 帖子详情
/// - `https://linux.do/u/...` 用户主页
///
/// 只在 App 已启动、路由表就绪后挂载；冷启动场景由 [_pendingInitial] 暂存，
/// 等首页加载完成后再消费。
class DeepLinkService {
  // 路由常量与 routes/app_routes.dart 保持一致。此处不 import 路由表，
  // 避免网络层反向依赖 pages（会产生循环 import）。
  static const String routeTopicDetail = '/topic/detail';
  static const String routePersonal = '/personal';
  static const String routeCategory = '/category';

  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Uri? _pendingInitial;
  bool _consumerReady = false;

  /// 开始监听。重复调用安全。
  Future<void> start() async {
    if (_sub != null) return;

    try {
      _pendingInitial = await _appLinks.getInitialLink();
    } catch (e) {
      l.d('读取初始深链失败: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      _onUri,
      onError: (Object e) => l.d('深链流错误: $e'),
    );

    if (_consumerReady) _flushPending();
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  /// 首页就绪后调用，消费冷启动时缓存的链接。
  void markConsumerReady() {
    _consumerReady = true;
    _flushPending();
  }

  void _flushPending() {
    final uri = _pendingInitial;
    if (uri == null) return;
    _pendingInitial = null;
    _onUri(uri);
  }

  void _onUri(Uri uri) {
    final route = resolve(uri);
    if (route == null) return;
    l.i('深链跳转: $uri -> ${route.name}');
    Get.toNamed(route.name, arguments: route.argument);
  }

  /// 把 URL 解析成内部路由。无法识别时返回 null（不跳转，避免抢占）。
  DeepLinkTarget? resolve(Uri uri) {
    if (uri.scheme == 'linuxdo') {
      // 授权回调由 WebPage 的 shouldOverrideUrlLoading 处理
      if (uri.host == 'auth') return null;

      // linuxdo://topic/123
      if (uri.host == 'topic') {
        final id = int.tryParse(uri.pathSegments.firstOrNull ?? '');
        if (id != null) {
          return DeepLinkTarget(routeTopicDetail, id);
        }
      }
      return null;
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (uri.host != 'linux.do' && uri.host != 'www.linux.do') return null;

    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      // /t/<slug>/<id> 或 /t/<id>
      if (segments[0] == 't') {
        for (final seg in segments.skip(1)) {
          final id = int.tryParse(seg);
          if (id != null) return DeepLinkTarget(routeTopicDetail, id);
        }
      }
      // /u/<username>
      if (segments[0] == 'u' && segments[1].isNotEmpty) {
        return DeepLinkTarget(routePersonal, segments[1]);
      }
      // /c/<slug>/<id> 分类
      if (segments[0] == 'c') {
        final id = int.tryParse(segments.last);
        if (id != null) return DeepLinkTarget(routeCategory, id);
      }
    }
    return null;
  }
}

/// 解析结果：路由名 + 参数
class DeepLinkTarget {
  final String name;
  final Object? argument;

  const DeepLinkTarget(this.name, this.argument);
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}