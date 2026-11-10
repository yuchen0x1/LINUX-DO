import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';
import '../const/app_const.dart';
import '../controller/global_controller.dart';
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

  Future<void> init() async {
    if (_isInitialized) return;
    // 初始化本地通知
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

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

    try {
      final dio = NetClient.getInstance().dio;
      final response = await dio.post(
        '${HttpConfig.baseUrl}message-bus/$_clientId/poll',
        data: _channels,
        options: Options(
          sendTimeout: const Duration(seconds: 35),
          receiveTimeout: const Duration(seconds: 35),
          headers: {
            'X-SILENCE-LOGGER': 'true',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final messages = response.data is List ? response.data as List : [];
        for (var msg in messages) {
          if (msg is Map) {
            final channel = msg['channel'] as String?;
            final messageId = msg['message_id'] as int?;
            final data = msg['data'];

            if (channel != null && messageId != null) {
              _channels[channel] = messageId;
            }

            _handleIncomingMessage(channel, data);
          }
        }
      }
    } catch (e) {
      // 容错重试
    }

    if (_isRunning) {
      _pollTimer = Timer(const Duration(seconds: 3), _poll);
    }
  }

  void _handleIncomingMessage(String? channel, dynamic data) {
    if (channel == null) return;

    if (channel.startsWith('/notification/')) {
      _showNotification(
        id: 1001,
        title: 'LINUX DO 社区互动提醒',
        body: '有人回复了你的话题或提到了你，快去看看吧！',
      );
    } else if (channel.startsWith('/unread/')) {
      _showNotification(
        id: 1002,
        title: '收到新的站内私信',
        body: '您有一条新的未读消息。',
      );
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
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
    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }
}
