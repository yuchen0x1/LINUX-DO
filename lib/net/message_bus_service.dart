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
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

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

  /// 启动长轮询监听
  Future<void> start() async {
    if (_isRunning) return;
    await init();
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
