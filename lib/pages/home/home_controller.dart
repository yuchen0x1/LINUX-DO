import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/app_version.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/emoji_manager.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/widgets/dis_app_update.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../const/app_images.dart';
import '../../const/app_const.dart';
import '../../routes/app_pages.dart';
import '../topics/topics_controller.dart';

class HomeController extends BaseController {
  // ignore: unused_field
  late final ApiService _apiService;
  final globalController = Get.find<GlobalController>();

  final pageController = PageController();
  late final TopicsController topicsController;

  final RxMap<int, dynamic> _badgeCount = <int, dynamic>{}.obs;

  Map<int, dynamic> get badgeCount => _badgeCount.value;

  set badgeCount(Map<int, dynamic> value) => _badgeCount.value = value;

  // 当前选中的tab索引
  final RxInt currentTab = 0.obs;

  final isRefreshing = false.obs;

  HomeController() {
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      showError('ApiService not initialized');
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    topicsController = Get.find<TopicsController>();

    // 模拟请求的数据
    // badgeCount = {0: '12'};

    initEmoji();
    checkAppVersion();
    Get.find<GlobalController>().fetchUserInfo();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 切换tab
  void switchTab(int index) {

    if (globalController.isAnonymousMode) {
      if (index == 1 || index == 2 || index == 3) {
        showWarning('当前为游客模式,无法查看该内容');
        return;
      }
    }

    if (index == 2) {
      // 直接跳转到创建帖子页面
      Get.toNamed(Routes.CREATE_TOPIC);
      return;
    }

    currentTab.value = index;
  }

  void _showHintDialog() {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图片占位
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Center(
                    child: Image.asset(
                  AppImages.logoCircle,
                  width: 80.w,
                  height: 80.w,
                )),
              ),
              16.vGap,
              // 标题
              Text(
                AppConst.createPost.dialogTitle,
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              8.vGap,
              // 内容
              Text(
                //AppConst.createPost.dialogContent,
                '更新了发布功能，优化了发布的流程, 现在可以更方便的发布帖子了',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                  fontFamily: AppFontFamily.dinPro,
                ),
              ),
              24.vGap,
              // 按钮
              Row(
                children: [
                  // 关闭按钮
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 20.w,
                      ),
                    ),
                  ),
                  12.hGap,
                  // 确认按钮
                  Expanded(
                    child: SizedBox(
                      height: 48.w,
                      child: DisButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(Routes.CREATE_TOPIC);
                        },
                        text: '去创建',
                        borderRadius: 6.w,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void checkAppVersion() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      int currentVersionCode = int.parse(packageInfo.buildNumber);

      final response = await dio.get(
        '${HttpConfig.otherUrl}/api/version/check/${Platform.isAndroid ? 'Android' : 'iOS'}',
        queryParameters: {
          'current_version': currentVersion,
          'current_version_code': currentVersionCode,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['has_update'] == false) return;

        final appVersion = AppVersion.fromJson(response.data);

        if (appVersion.hasUpdate == true) {
          if (Platform.isAndroid) {
            DisAppUpdate.showUpdateDialog(appVersion);
          } else if (Platform.isIOS) {
            DisAppUpdate.showUpdateDialog(appVersion);
          }
        }
      }
    } catch (e, s) {
      l.e('检查更新失败: $e\n$s');
    }
  }

  void initEmoji() async {
    await EmojiManager().init('assets/json/emoji.json');
    EmojiManager().precacheImages(Get.context!);
  }
}
