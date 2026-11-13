import 'package:linux_do/net/http_config.dart';

import '../models/topic_model.dart';

class UserCache {
  static final UserCache _instance = UserCache._internal();
  factory UserCache() => _instance;
  UserCache._internal();

  // 用户头像URL缓存
  final Map<int, String> _avatarUrls = {};

  // 用户信息缓存
  final Map<int, User> _users = {};

  // 清除所有缓存
  clear() {
    _avatarUrls.clear();
    _users.clear();
  }

  // 更新用户缓存
  void updateUsers(List<User>? users) {
    if (users == null) return;
    for (final user in users) {
      _users[user.id] = user;
      if (user.avatarTemplate!.startsWith('http://') ||
          user.avatarTemplate!.startsWith('https://')) {
        final url = user.avatarTemplate!;
        final protocol = url.startsWith('https://') ? 'https://' : 'http://';
        final path = url.substring(protocol.length);
        _avatarUrls[user.id] = protocol + path.replaceAll(RegExp(r'/+'), '/');
      } else {
        _avatarUrls[user.id] =
            '${HttpConfig.baseUrl}${user.avatarTemplate!.replaceAll("{size}", "62")}';
      }
    }
  }

  // 获取用户头像URL
  String? getAvatarUrl(int userId) => _avatarUrls[userId] ?? '';

  // 获取用户昵称
  String? getNickName(int userId) => _users[userId]?.name ?? '';

  // 获取用户用户名
  String? getUserName(int userId) => _users[userId]?.username ?? '';

  // 获取用户信息
  User? getUser(int userId) => _users[userId];

  // 获取缓存大小
  int get size => _avatarUrls.length;

  // 检查是否有缓存
  bool hasCache(int userId) => _avatarUrls.containsKey(userId);
}
