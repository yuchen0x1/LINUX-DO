import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/net/message_bus_service.dart';
import 'package:linux_do/net/user_api_key_auth_service.dart';
import 'package:linux_do/net/success_response.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/trust_level_badge.dart';

import '../../net/http_config.dart';
import '../../utils/log.dart';
import '../../widgets/dis_color_picker.dart';
import '../web_page.dart';

class SettingsController extends BaseController {
  final ApiService _apiService = Get.find();
  final isAnonymousMode = false.obs;
  final isDoNotDisturb = false.obs;
  final isTrackingEnabled = false.obs;
  final themeMode = ThemeMode.system.obs;
  final isAmoled = false.obs;
  final browserTips = false.obs;
  final isAnimatedEmojiEnabled = true.obs;
  final isPushEnabled = false.obs;

  List<String> get themeModeOptions => [
    AppConst.settings.themeSystem,
    AppConst.settings.themeLight,
    AppConst.settings.themeDark,
    AppConst.settings.themeAmoled,
  ];

  String get selectedThemeMode {
    if (isAmoled.value) return AppConst.settings.themeAmoled;
    switch (themeMode.value) {
      case ThemeMode.system:
        return AppConst.settings.themeSystem;
      case ThemeMode.light:
        return AppConst.settings.themeLight;
      case ThemeMode.dark:
        return AppConst.settings.themeDark;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    ever(themeMode, (ThemeMode mode) {
      Get.changeThemeMode(mode);
    });
  }

  void _loadSettings() {
    final savedThemeMode = StorageManager.getString(AppConst.identifier.theme);
    isAmoled.value = savedThemeMode == 'amoled';
    themeMode.value = _parseThemeMode(savedThemeMode);

    final savedBrowserTips = StorageManager.getBool(AppConst.identifier.browserTips) ?? false;
    browserTips.value = savedBrowserTips;

    final savedEmoji = StorageManager.getBool('animated_emoji_enabled') ?? true;
    isAnimatedEmojiEnabled.value = savedEmoji;

    final savedPush = StorageManager.getBool('push_notification_enabled') ?? false;
    isPushEnabled.value = savedPush;
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
      case 'amoled':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(String? value) {
    if (value == null) return;

    final isSelectedAmoled = value == AppConst.settings.themeAmoled;
    final ThemeMode newMode;
    final String themeValue;

    if (value == AppConst.settings.themeSystem) {
      newMode = ThemeMode.system;
      themeValue = 'system';
    } else if (value == AppConst.settings.themeLight) {
      newMode = ThemeMode.light;
      themeValue = 'light';
    } else {
      newMode = ThemeMode.dark;
      themeValue = isSelectedAmoled ? 'amoled' : 'dark';
    }

    isAmoled.value = isSelectedAmoled;
    themeMode.value = newMode;
    StorageManager.setData(AppConst.identifier.theme, themeValue);

    if (isSelectedAmoled) {
      Get.changeTheme(AppTheme.amoledTheme);
    } else if (newMode == ThemeMode.dark) {
      Get.changeTheme(AppTheme.darkTheme);
    } else if (newMode == ThemeMode.light) {
      Get.changeTheme(AppTheme.lightTheme);
    } else {
      Get.changeTheme(AppTheme.lightTheme);
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  void updateAnimatedEmoji(bool value) {
    isAnimatedEmojiEnabled.value = value;
    StorageManager.setData('animated_emoji_enabled', value);
  }

  void updatePushNotification(bool value) {
    isPushEnabled.value = value;
    StorageManager.setData('push_notification_enabled', value);
    if (value && Get.find<GlobalController>().isLogin) {
      MessageBusService().start();
    } else {
      MessageBusService().stop();
    }
  }

  /// 展示 Trust Level 等级特权面板
  void showTrustLevelPrivileges() {
    final user = Get.find<GlobalController>().userInfo?.user;
    final level = user?.trustLevel ?? 0;
    final title = TrustLevelHelper.getTitle(level);
    final color = TrustLevelHelper.getColor(level);
    final privileges = TrustLevelHelper.getPrivileges(level);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TrustLevelBadge(level: level, showTitle: false, fontSize: 12.sp),
                  8.hGap,
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              12.vGap,
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: privileges
                        .map((p) => Padding(
                              padding: EdgeInsets.only(bottom: 8.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 14.w,
                                    color: color,
                                  ),
                                  6.hGap,
                                  Expanded(
                                    child: Text(
                                      p,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Theme.of(Get.context!)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> logout() async {
    await WebPage.clearCache();
    await NetClient.getInstance().clearCookies();
    MessageBusService().stop();
    await UserApiKeyAuthService().clearApiKey();
    await StorageManager.remove(AppConst.identifier.csrfToken);
    await StorageManager.remove(AppConst.identifier.token);
    await StorageManager.remove(AppConst.identifier.cfClearance);
    await StorageManager.remove(AppConst.identifier.username);
    await StorageManager.remove(AppConst.identifier.name);
    Get.find<GlobalController>().setIsLogin(false);
    Get.find<GlobalController>().setIsAnonymousMode(false);
    StorageManager.setData(AppConst.identifier.isAnonymousMode, false);
    Get.offAllNamed(Routes.LOGIN);
  }


  void showColorPicker() {
    DisColorPicker.show(
      selectedColor: primaryMaterial,
      onColorSelected: (color) {
        changeTheme(color);   
      },  
    );
  }

  void changeTheme(Color color) {
    try {
      ThemeData lightTheme = ThemeData(
        primaryColor: color,
        brightness: Brightness.light,
      );

      ThemeData darkTheme = ThemeData(
        primaryColor: color,
        brightness: Brightness.dark,
      );

      // 根据当前主题模式切换
      if (Get.isDarkMode) {
        Get.changeTheme(darkTheme);
      } else {
        Get.changeTheme(lightTheme);
      }

      // 返回上一页
      Get.back();

      final colorHex = color.value & 0xFFFFFF;
      StorageManager.setData(AppConst.identifier.themeColor, colorHex);
    } catch (e, s) {
      l.e('changeTheme error: $e, $s');
    }
  }


  /// 关于页面
  void toAbout() {
    Get.toNamed(Routes.ABOUT);
  }

  /// 常见问题页面
  void toFaq() {
    Get.toNamed(Routes.WEBVIEW, arguments: '${HttpConfig.baseUrl}${AppConst.faq}');
  }

  /// 更新浏览器提示  
  void updateBrowserTips(bool value) {
    StorageManager.setData(AppConst.identifier.browserTips, value);
    browserTips.value = value;
  }

  /// 安全设置页
  void toSecuritySettings() {
    Get.toNamed(Routes.SECURITY_SETTINGS);
  }

  /// 个性资料页
  void toProfileSettings() {
    //Get.toNamed(Routes.PROFILE_SETTINGS);
    showWarning('开发中');
  }

  /// 电子邮件设置页
  void toEmailSettings() {
    Get.toNamed(Routes.EMAIL_SETTINGS);
  }

  /// 通知设置页
  void toNotificationSettings() {
    Get.toNamed(Routes.NOTIFICATION_SETTINGS);
  }

  /// 跟踪设置页
  void toTrackingSettings() {
    Get.toNamed(Routes.TRACKING_SETTINGS);
  }

  /// 免打扰设置页
  void toDoNotDisturbSettings() {
    Get.toNamed(Routes.DO_NOT_DISTURB_SETTINGS);
  }

  /// 导出数据
  void exportData() async{
    try{
      SuccessResponse data = await _apiService.requestDataExport();
      if (data.isSuccess) {
        showSuccess(AppConst.settings.dataExportSuccess);
      }
    } catch (e, s) {
      showError(AppConst.settings.dataExportFailed);
      l.e('exportData error: $e, $s');
    }
  }

  /// 用户协议
  void toTerms() async{
    final htmlContent = await rootBundle.loadString(AppConst.terms);
    Get.toNamed(Routes.WEBVIEW, arguments: htmlContent);
  }

  /// 隐私政策
  void toPrivacy() async{
    final htmlContent = await rootBundle.loadString(AppConst.privacy);
    Get.toNamed(Routes.WEBVIEW, arguments: htmlContent);
  }

  /// 字体大小设置
  void toFontSizeSettings() {
    Get.toNamed(Routes.FONT_SIZE_SETTINGS);
  }

  /// 网络与 DoH 设置
  void toNetworkSettings() {
    Get.toNamed(Routes.NETWORK_SETTINGS);
  }
} 