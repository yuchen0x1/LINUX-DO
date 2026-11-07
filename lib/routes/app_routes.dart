part of 'app_pages.dart';

abstract class Routes {
  // 启动页
  static const STARTUP = '/startup';

  // 主页
  static const HOME = '/home';

  // 个人中心
  static const PROFILE = '/profile';

  // 设置页面
  static const SETTINGS = '/settings';

  // 登录页面
  static const LOGIN = '/login';

  // 主题详情页
  static const TOPIC_DETAIL = '/topic/detail';

  // 创建主题页面
  static const CREATE_TOPIC = '/topic/create';

  // 主题列表页面
  static const TOPICS = '/topics';

  // WebView页面
  static const WEBVIEW = '/webview';

  // 聊天详情页
  static const CHAT_DETAIL = '/chat/detail';

  // 机器人聊天页面
  static const ROBOT_CHAT = '/robot/chat';

  // 编辑资料页
  static const EDIT_PROFILE = '/profile/edit';

  // 安全设置页面
  static const SECURITY_SETTINGS = '/settings/security';

  // 个性资料页
  static const PROFILE_SETTINGS = '/settings/profile';

  // 电子邮件设置页
  static const EMAIL_SETTINGS = '/settings/email';

  // 通知设置页
  static const NOTIFICATION_SETTINGS = '/settings/notification';

  // 跟踪设置页
  static const TRACKING_SETTINGS = '/settings/tracking';

  // 免打扰设置页
  static const DO_NOT_DISTURB_SETTINGS = '/settings/do-not-disturb';

  // 字体设置页
  static const FONT_SIZE_SETTINGS = '/settings/font-size';

  // 网络与 DoH 设置页
  static const NETWORK_SETTINGS = '/settings/network';

  // 关于页
  static const ABOUT = '/about';

  // 分类列表
  static const CATEGORY = '/category';

  // 个人主页(TA)
  static const PERSONAL = '/personal';

  // 点赞页面
  static const LIKE_PAGE = '/like';

  // 关注页面
  static const FOLLOW_PAGE = '/follow';

  // 收藏页面
  static const COLLECT_PAGE = '/collect';

  // 热门页面
  static const POPULAR_PAGE = '/popular';

  // 书签页面
  static const BOOKMARKS = '/bookmarks';

  // 连接页面
  static const CONNECT = '/connect';

  // 帖子web阅读页
  static const WEB_POST_READ = '/web/post/read';
}
