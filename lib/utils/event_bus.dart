import 'package:get/get.dart';

/// 事件类型枚举
enum EventType {
  /// 刷新用户信息
  refreshUserInfo,
}

/// 事件总线
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  /// 事件流
  final _eventStream = RxMap<EventType, dynamic>();

  /// 发送事件
  void fire(EventType event, [dynamic data]) {
    _eventStream[event] = data ?? DateTime.now().millisecondsSinceEpoch;
  }

  /// 监听事件
  Worker listen(EventType event, Function(dynamic) callback) {
    return ever(_eventStream, (map) {
      if (_eventStream.containsKey(event)) {
        callback(_eventStream[event]);
      }
    });
  }

  /// 监听多个事件
  List<Worker> listenList(List<EventType> events, Function(dynamic) callback) {
    return events.map((event) => listen(event, callback)).toList();
  }
}
