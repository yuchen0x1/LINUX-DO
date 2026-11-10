import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/deep_link_service.dart';
import 'package:linux_do/net/update_checker.dart';
import 'package:linux_do/utils/emoji_manager.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/widgets/dis_app_update.dart';

import '../../routes/app_pages.dart';
import '../topics/topics_controller.dart';

class HomeController extends BaseController {
  // ignore: unused_field
  late final ApiService _apiService;
  final globalController = Get.find<GlobalController>();

  final pageController = PageController();
  late final TopicsController topicsController;

  final RxMap<int, dynamic> _badgeCount = <int, dynamic>{}.obs;

  Map<int, dynamic> get badgeCount => _badgeCount;

  set badgeCount(Map<int, dynamic> value) => _badgeCount.assignAll(value);

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

    // 首页就绪后再接管深链，避免冷启动时路由表尚未准备好
    DeepLinkService().start();
    DeepLinkService().markConsumerReady();
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

  void checkAppVersion() async {
    try {
      final appVersion = await UpdateChecker.check();
      if (appVersion?.hasUpdate != true) return;

      // 只对可信域名的下载链接展示更新弹窗，避免把用户导向任意地址
      final url = appVersion!.downloadUrl;
      if (url != null && !UpdateChecker.isTrustedDownload(url)) {
        l.w('忽略非可信域名的更新地址: $url');
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        DisAppUpdate.showUpdateDialog(appVersion);
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
