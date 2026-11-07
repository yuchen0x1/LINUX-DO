import 'package:get/get.dart';
import 'package:linux_do/controller/share_controller.dart';
import 'package:linux_do/pages/category/category_list_controller.dart';
import 'package:linux_do/pages/chat/chat_robot_controller.dart';
import 'package:linux_do/pages/chat/chat_robot_page.dart';
import 'package:linux_do/pages/profile/connect_controller.dart';
import 'package:linux_do/pages/profile/connect_page.dart';
import 'package:linux_do/pages/profile/edit_profile_controller.dart';
import 'package:linux_do/pages/profile/edit_profile_page.dart';
import 'package:linux_do/pages/profile/follow_controller.dart';
import 'package:linux_do/pages/profile/follow_page.dart';
import 'package:linux_do/pages/profile/like_controller.dart';
import 'package:linux_do/pages/profile/like_page.dart';
import 'package:linux_do/pages/profile/personal_controller.dart';
import 'package:linux_do/pages/profile/personal_page.dart';
import 'package:linux_do/pages/profile/popular_controller.dart';
import 'package:linux_do/pages/profile/popular_page.dart';
import 'package:linux_do/pages/settings/about_controller.dart';
import 'package:linux_do/pages/settings/about_page.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/pages/settings/font_size_page.dart';
import 'package:linux_do/pages/settings/profile_settings_controller.dart';
import 'package:linux_do/pages/settings/profile_settings_page.dart';
import 'package:linux_do/pages/settings/security_settings_controller.dart';
import 'package:linux_do/pages/settings/security_settings_page.dart';
import 'package:linux_do/pages/settings/network_settings_page.dart';
import 'package:linux_do/pages/topics/details/web_post_read_controller.dart';
import 'package:linux_do/pages/topics/details/web_post_read_page.dart';
import 'package:linux_do/utils/bookmark_service.dart';
import 'package:linux_do/widgets/cloudflare_timings_service.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import '../pages/chat/chat_detail_controller.dart';
import '../pages/chat/chat_detail_page.dart';
import '../pages/create/create_post_controller.dart';
import '../pages/chat/chat_list_controller.dart';
import '../pages/topics/details/topic_detail_controller.dart';
import '../pages/topics/details/topic_detail_page.dart';
import '../pages/settings/settings_controller.dart';
import '../pages/home/home_controller.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/login/login_controller.dart';
import '../pages/profile/profile_controller.dart';
import '../pages/settings/settings_page.dart';
import '../pages/startup/startup_controller.dart';
import '../pages/startup/startup_page.dart';
import '../pages/category/category_topics_controller.dart';
import '../pages/topics/topics_controller.dart';
import '../pages/common/webview_page.dart';
import '../pages/common/webview_controller.dart';
import '../pages/create/create_post_page.dart';
import '../pages/settings/email_settings_controller.dart';
import '../pages/settings/email_settings_page.dart';
import '../pages/settings/notification_settings_controller.dart';
import '../pages/settings/notification_settings_page.dart';
import '../pages/settings/tracking_settings_controller.dart';
import '../pages/settings/tracking_settings_page.dart';
import '../pages/settings/do_not_disturb_controller.dart';
import '../pages/settings/do_not_disturb_page.dart';
import '../pages/category/category_page.dart';
import '../pages/profile/bookmark_page.dart';
import '../pages/profile/bookmark_controller.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.STARTUP;
  static final routes = <GetPage>[
    /// 启动页
    GetPage(
      name: Routes.STARTUP,
      page: () => const StartupPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StartupController());
      }),
    ),

    /// 主页
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => TopicsController());
        Get.lazyPut(() => CategoryTopicsController());
        Get.lazyPut(() => ChatListController());
        Get.lazyPut(() => ProfileController());
        Get.lazyPut(() => BookmarkService());
        Get.put(FontSizeController(), permanent: true);
      }),
    ),

    /// 登录页
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController());
      }),
    ),

    /// 设置页
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
    ),

    /// 网络与 DoH 设置页
    GetPage(
      name: Routes.NETWORK_SETTINGS,
      page: () => const NetworkSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NetworkSettingsController());
      }),
    ),

    /// 帖子详情页
    GetPage(
      name: Routes.TOPIC_DETAIL,
      page: () => const TopicDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TopicDetailController());
        Get.lazyPut(() => HtmlController());
        Get.lazyPut(() => ShareController());
      }),
    ),

    /// WebView页面
    GetPage(
      name: Routes.WEBVIEW,
      page: () => const WebViewPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WebViewController());
      }),
    ),

    /// 创建帖子页
    GetPage(
      name: Routes.CREATE_TOPIC,
      page: () => const CreatePostPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CreatePostController());
      }),
    ),

    /// 聊天详情页
    GetPage(
      name: Routes.CHAT_DETAIL,
      page: () => const ChatDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatDetailController());
      }),
    ),

    /// 编辑资料页
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileController());
      }),
    ),

    /// 安全设置页
    GetPage(
      name: Routes.SECURITY_SETTINGS,
      page: () => const SecuritySettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SecuritySettingsController());
      }),
    ),

    /// 个性资料页
    GetPage(
      name: Routes.PROFILE_SETTINGS,
      page: () => const ProfileSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileSettingsController());
      }),
    ),

    /// 电子邮件设置页
    GetPage(
      name: Routes.EMAIL_SETTINGS,
      page: () => const EmailSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmailSettingsController());
      }),
    ),

    /// 通知设置页
    GetPage(
      name: Routes.NOTIFICATION_SETTINGS,
      page: () => const NotificationSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationSettingsController());
      }),
    ),

    /// 跟踪设置页
    GetPage(
      name: Routes.TRACKING_SETTINGS,
      page: () => const TrackingSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TrackingSettingsController());
      }),
    ),

    /// 免打扰设置页
    GetPage(
      name: Routes.DO_NOT_DISTURB_SETTINGS,
      page: () => const DoNotDisturbPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DoNotDisturbController());
      }),
    ),

    /// 关于页
    GetPage(
      name: Routes.ABOUT,
      page: () => const AboutPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AboutController());
      }),
    ),

    /// 字体设置页
    GetPage(name: Routes.FONT_SIZE_SETTINGS, page: () => const FontSizePage()),

    /// 分类页
    GetPage(
      name: Routes.CATEGORY,
      page: () => const CategoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CategoryListController());
      }),
    ),

    /// 个人主页(TA的)
    GetPage(
      name: Routes.PERSONAL,
      page: () => const PersonalPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PersonalController());
      }),
    ),

    /// 点赞信息页
    GetPage(
      name: Routes.LIKE_PAGE,
      page: () => const LikePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LikeController>(() => LikeController());
      }),
    ),

    /// 关注信息页
    GetPage(
      name: Routes.FOLLOW_PAGE,
      page: () => const FollowPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FollowController>(() => FollowController());
      }),
    ),

    /// 热门页
    GetPage(
      name: Routes.POPULAR_PAGE,
      page: () => const PopularPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PopularController>(() => PopularController());
      }),
    ),

    /// 书签页
    GetPage(
      name: Routes.BOOKMARKS,
      page: () => const BookmarkPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BookmarkController());
      }),
    ),

    /// 机器人聊天页
    GetPage(
      name: Routes.ROBOT_CHAT,
      page: () => const ChatRobotPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatRobotController());
      }),
    ),

    /// 连接页
    GetPage(
      name: Routes.CONNECT,
      page: () => const ConnectPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ConnectController());
      }),
    ),

    /// 帖子web阅读页
    GetPage(
      name: Routes.WEB_POST_READ,
      page: () => const WebPostReadPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WebPostReadController());
        Get.lazyPut(() => CloudflareController());
      }),
    ),
  ];
}
