import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../const/app_const.dart';
import '../controller/global_controller.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';
import 'http_client.dart';
import 'http_config.dart';

class MessageBusService {
  static final MessageBusService _instance = MessageBusService._internal();
  factory MessageBusService() => _instance;
  MessageBusService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isRunning = false;
  bool _isInitialized = false;
  String _clientId = '';
  final Map<String, int> _channels = {};
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  bool _pausedByLifecycle = false;

  Future<void> init() async {
    if (_isInitialized) return;
    // 初始化本地通知
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ 需要运行时授权，否则通知会被系统静默丢弃
    await _ensureNotificationPermission();

    // 复用全局 client_id
    _clientId = GlobalController.clientId;
    if (_clientId.isEmpty) {
      _clientId = StorageManager.getString(AppConst.identifier.clientId) ?? '';
    }
    if (_clientId.isEmpty) {
      _clientId = 'ld_client_${DateTime.now().millisecondsSinceEpoch}';
      StorageManager.setData(AppConst.identifier.clientId, _clientId);
    }
    _isInitialized = true;
  }

  /// 申请通知权限。仅在 Android 13+ 需要；失败不阻断推送监听启动，
  /// 只是通知不可见（用户后续可在系统设置中开启）。
  Future<void> _ensureNotificationPermission() async {
    try {
      final android =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;
      final granted = await android.areNotificationsEnabled() ?? false;
      if (granted) return;
      final result = await android.requestNotificationsPermission();
      if (result == false) {
        l.w('用户拒绝了通知权限，社区提醒将无法显示');
      }
    } catch (e) {
      l.e('申请通知权限失败: $e');
    }
  }

  /// 启动长轮询监听
  Future<void> start() async {
    if (_isRunning) return;
    await init();
    // 缺少 userId 时先补身份，否则 notification/unread 频道订阅不到
    await syncUserIdentity();
    _isRunning = true;
    _setupChannels();
    _poll();
    l.i('MessageBus 实时推送监听已启动, ClientId: $_clientId');
  }

  /// 停止监听
  void stop() {
    _isRunning = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    l.i('MessageBus 实时推送监听已停止');
  }

  void _setupChannels() {
    final userId = StorageManager.getString(AppConst.identifier.userId);
    if (userId != null && userId.isNotEmpty) {
      _channels['/notification/$userId'] = -1;
      _channels['/unread/$userId'] = -1;
      _channels['/queue'] = -1;
    }
    _channels['/latest'] = -1;
  }

  /// 拉取当前登录用户，把 username / userId 落到本地存储。
  ///
  /// MessageBus 的 `/notification/{userId}` 与 `/unread/{userId}` 频道必须带
  /// userId 才能订阅，而 User API Key 授权流程本身不返回用户身份，所以只要
  /// 缺 userId 就要主动补一次。返回是否成功拿到身份。
  Future<bool> syncUserIdentity() async {
    final existing = StorageManager.getString(AppConst.identifier.userId);
    if (existing != null && existing.isNotEmpty) return true;

    try {
      final dio = NetClient.getInstance().dio;
      final response =
          await dio.get('${HttpConfig.baseUrl}session/current.json');
      final data = response.data;
      if (data is! Map) return false;

      final currentUser = data['current_user'];
      if (currentUser is! Map) return false;

      final id = currentUser['id'];
      final username = currentUser['username'];
      if (id == null || username == null) return false;

      await StorageManager.setData(AppConst.identifier.userId, id.toString());
      await StorageManager.setData(
          AppConst.identifier.username, username.toString());
      final displayName = currentUser['name'];
      if (displayName is String && displayName.isNotEmpty) {
        await StorageManager.setData(AppConst.identifier.name, displayName);
      }
      l.i('已同步登录身份: $username (#$id)');
      return true;
    } catch (e) {
      l.e('同步登录身份失败: $e');
      return false;
    }
  }

  Future<void> _poll() async {
    if (!_isRunning) return;

    var gotMessages = false;
    try {
      final dio = NetClient.getInstance().dio;
      // 长轮询：服务端在有新消息或超时后才返回。30s 略小于 receiveTimeout，
      // 让「无消息」成为常态而不是靠客户端高频建连。
      final response = await dio.post(
        '${HttpConfig.baseUrl}message-bus/$_clientId/poll',
        data: _channels,
        queryParameters: {'timeout': 25},
        options: Options(
          sendTimeout: const Duration(seconds: 35),
          receiveTimeout: const Duration(seconds: 35),
          headers: {
            'X-SILENCE-LOGGER': 'true',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final messages = response.data as List;
        gotMessages = messages.isNotEmpty;
        for (final msg in messages) {
          if (msg is! Map) continue;
          final channel = msg['channel'] as String?;
          final messageId = msg['message_id'];
          final data = msg['data'];

          if (channel != null && messageId is int) {
            _channels[channel] = messageId;
          }
          _handleIncomingMessage(channel, data);
        }
      }
      _consecutiveFailures = 0;
    } catch (e) {
      _consecutiveFailures++;
      l.d('MessageBus 轮询失败 ($_consecutiveFailures): $e');
    }

    if (!_isRunning) return;

    if (gotMessages) {
      // 有消息时立刻继续拉，避免积压
      _schedulePoll(Duration.zero);
    } else if (_consecutiveFailures > 0) {
      // 失败退避：2s → 4s → 8s … 上限 60s，避免断网时疯狂重连
      final backoff = Duration(
        seconds: (1 << _consecutiveFailures).clamp(2, 60),
      );
      _schedulePoll(backoff);
    } else {
      // 长轮询正常返回（服务端超时）后立即续拉
      _schedulePoll(Duration.zero);
    }
  }

  void _schedulePoll(Duration delay) {
    _pollTimer?.cancel();
    if (!_isRunning) return;
    _pollTimer = Timer(delay, _poll);
  }

  /// 点击通知：payload 存 topicId，直接打开对应帖子
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final topicId = int.tryParse(payload);
    if (topicId == null) return;

    // 避免在网络层直接依赖路由表：这里用延迟 import 的值字面量
    try {
      Get.toNamed('/topic/detail', arguments: topicId);
    } catch (e) {
      l.e('通知点击跳转失败: $e');
    }
  }

  /// 应用退到后台时暂停轮询，回到前台恢复。返回是否发生了状态切换。
  bool handleLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isRunning && _pausedByLifecycle) {
          _pausedByLifecycle = false;
          _schedulePoll(Duration.zero);
          return true;
        }
        return false;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_isRunning && !_pausedByLifecycle) {
          _pausedByLifecycle = true;
          _pollTimer?.cancel();
          _pollTimer = null;
          return true;
        }
        return false;
      case AppLifecycleState.inactive:
        return false;
    }
  }

  void _handleIncomingMessage(String? channel, dynamic data) {
    if (channel == null) return;

    if (channel.startsWith('/notification/')) {
      final parsed = _parseNotification(data);
      _showNotification(
        id: parsed.topicId ?? 1001,
        title: parsed.title,
        body: parsed.body,
        topicId: parsed.topicId,
      );
    } else if (channel.startsWith('/unread/')) {
      _showNotification(
        id: 1002,
        title: '收到新的站内私信',
        body: '您有一条新的未读消息。',
      );
    }
  }

  /// 解析 Discourse 通知 payload，尽量给出「谁 + 在哪个帖子里 + 做了什么」。
  /// 字段缺失时退化为通用文案，不抛异常。
  _ParsedNotification _parseNotification(dynamic data) {
    if (data is! Map) {
      return const _ParsedNotification(title: 'LINUX DO 社区互动提醒', body: '你有一条新提醒');
    }

    final username = (data['username'] ?? data['display_username'] ?? '有人')
        .toString();
    final title = (data['topic_title'] ?? data['title'] ?? '').toString();
    final excerpt = (data['excerpt'] ?? data['post_excerpt'] ?? '').toString();
    final topicIdRaw = data['topic_id'];
    final topicId = topicIdRaw is int
        ? topicIdRaw
        : int.tryParse(topicIdRaw?.toString() ?? '');

    final String action;
    switch (data['notification_type']) {
      case 1:
        action = '提到了你';
        break;
      case 2:
        action = '回复了你的帖子';
        break;
      case 3:
        action = '引用了你';
        break;
      case 5:
        action = '赞了你的帖子';
        break;
      case 9:
        action = '关注了你';
        break;
      case 12:
        action = '邀请你参与';
        break;
      default:
        action = '与你互动';
    }

    final body = excerpt.isNotEmpty
        ? excerpt
        : (title.isNotEmpty ? title : '点击查看详情');

    return _ParsedNotification(
      title: '$username $action',
      body: _truncate(body, 120),
      topicId: topicId,
    );
  }

  static String _truncate(String s, int max) {
    final flat = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= max) return flat;
    return '${flat.substring(0, max)}…';
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    int? topicId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'linux_do_community',
      'Linux DO 社区通知',
      channelDescription: '接收 Linux DO 帖文回复、点赞、私信等实时提醒',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: topicId?.toString(),
    );
  }
}

/// 已解析的通知内容
class _ParsedNotification {
  final String title;
  final String body;
  final int? topicId;

  const _ParsedNotification({
    required this.title,
    required this.body,
    this.topicId,
  });
}
