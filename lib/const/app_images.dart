import 'package:flutter/material.dart';

class AppImages {
  // 基础路径
  static const String _lightPath = 'assets/images/light';
  static const String _darkPath = 'assets/images/dark';
  static const String imagesPath = 'assets/images/';

  // 图片名称
  static const String _logoName = 'logo.webp';
  // 大图统一使用 WebP（体积约为原 PNG 的 5%），原图保留在 assets/design/source/
  static const String _bannerName = 'search-banner.webp';
  static const String _inputAccount = 'input-account.png';
  static const String _inputPassword = 'input-password.png';
  static const String _headerBackground = 'header-background.png';
  static const String profileHeaderBg = 'assets/images/profile-header-bg.webp';
  static const String logoCircle = 'assets/images/logo-circle.png';
  // 上游文件名把 background 拼成了 backgroud，这里沿用实际文件名
  static const String _chatListBg = 'chat-list-background.webp';
  static const String _chatBg = 'chat-backgroud.webp';
  static const String searchIcon = 'assets/images/search-icon.png';
  static const String leaderboardTop = 'assets/images/leaderboard-top.png';
  static const String crown = 'assets/images/crown.png';
  static const String lOther = 'assets/images/l-other.png';
  static const String lMe = 'assets/images/l-me.png';
  static const String batteryQuarter = 'battery-quarter';
  static const String robot = 'assets/images/robot.png';

  // 状态Icon
  static const String _netErrorName = 'state-net-error.png';
  static const String _empty = 'state-empty.png';

  // ICON 72x72 48x48 96x96 144x144 192x192
  static const String logoSmall =
      'https://linux.do/uploads/default/optimized/3X/9/d/9dd49731091ce8656e94433a26a3ef36062b3994_2_32x32.png';

  // 根据主题获取对应的图片路径
  static String getImagePath(BuildContext context, String imageName) {
    final basePath = Theme.of(context).brightness == Brightness.dark
        ? _darkPath
        : _lightPath;
    return '$basePath/$imageName';
  }

  // 获取logo
  static String getLogo(BuildContext context) {
    return getImagePath(context, _logoName);
  }

  // 获取banner
  static String getBanner(BuildContext context) {
    return getImagePath(context, _bannerName);
  }

  // 获取空状态
  static String getEmpty(BuildContext context) {
    return getImagePath(context, _empty);
  }

  // 网络错误
  static String getNetError(BuildContext context) {
    return getImagePath(context, _netErrorName);
  }

  // 获取输入框图标
  static String getInputAccount(BuildContext context) {
    return getImagePath(context, _inputAccount);
  }

  // 获取输入框图标
  static String getInputPassword(BuildContext context) {
    return getImagePath(context, _inputPassword);
  }

  // 获取头部背景
  static String getHeaderBackground(BuildContext context) {
    return getImagePath(context, _headerBackground);
  }

  // 获取聊天列表背景
  static String getChatListBg(BuildContext context) {
    return getImagePath(context, _chatListBg);
  }

  // 获取聊天背景
  static String getChatBg(BuildContext context) {
    return getImagePath(context, _chatBg);
  }
}
