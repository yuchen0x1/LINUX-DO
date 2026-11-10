import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/follow.dart';
import 'package:linux_do/models/summary.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/success_response.dart';
import 'package:linux_do/pages/profile/tabs/message_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import '../../const/app_const.dart';
import '../../controller/base_controller.dart';
import '../../controller/global_controller.dart';
import '../../utils/log.dart';
import '../../utils/mixins/concatenated.dart';
import '../../utils/storage_manager.dart';
import 'tabs/activity_controller.dart';
import 'tabs/badge_controller.dart';
import 'tabs/notification_controller.dart';
import 'tabs/summary_controller.dart';
import 'tabs/activity_page.dart';
import 'tabs/badge_page.dart';
import 'tabs/message_page.dart';
import 'tabs/notification_page.dart';
import 'tabs/summary_page.dart';

class ProfileController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();

  final _onlineMode = true.obs;
  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int index) => _selectedIndex.value = index;

  bool get onlineMode => _onlineMode.value;
  set onlineMode(bool b) => _onlineMode.value = b;

  final TextEditingController statusController = TextEditingController();
  final TextEditingController emojiController = TextEditingController();
  final RxBool showEmoji = false.obs;
  final RxList<Follow> following = <Follow>[].obs;
  final RxList<Follow> followers = <Follow>[].obs;
  final summaryData = Rxn<SummaryResponse>();

  final RxString emojiStatus = ''.obs;

  // 功能按钮当前页面索引
  final RxInt featurePageIndex = 0.obs;

  late final PageController featurePageController;

  // 表情选择器相关
  final RxBool isShowEmojiPicker = false.obs;
  final RxBool isHideKeyboard = false.obs;
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _getSummaryData();
    // 初始化PageController
    featurePageController = PageController(initialPage: 0);
    // 监听页面变化
    featurePageController.addListener(() {
      if (featurePageController.page != null) {
        final currentPage = featurePageController.page!.round();
        if (featurePageIndex.value != currentPage) {
          featurePageIndex.value = currentPage;
        }
      }
    });

    // 监听键盘可见性
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        isShowEmojiPicker.value = false;
        isHideKeyboard.value = false;
      }
    });

    // 初始化子控制器
    Get.lazyPut(() => SummaryController());
    Get.lazyPut(() => ActivityController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => MessageController());
    Get.lazyPut(() => BadgeController());
  }

  // 切换到下一页
  void nextPage() {
    if (featurePageIndex.value < 2) {
      featurePageController.animateToPage(
        featurePageIndex.value + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 切换到上一页
  void previousPage() {
    if (featurePageIndex.value > 0) {
      featurePageController.animateToPage(
        featurePageIndex.value - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget createCurrent() {
    switch (selectedIndex) {
      case 0:
        return const SummaryPage();
      case 1:
        return const ActivityPage();
      case 2:
        return const NotificationPage();
      case 3:
        return const MessagePage();
      case 4:
        return const BadgePage();
      default:
        return const SizedBox.shrink();
    }
  }

  // 编辑个人信息
  void editProfile() {}

  // 临时退出登录
  void logout() {
    Get.offAllNamed('/login');

    // 清除登录状态
    final globalController = Get.find<GlobalController>();
    StorageManager.remove(AppConst.identifier.csrfToken);
    globalController.setIsLogin(false);
  }

  // 去设置页面
  void toSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  // 更新在线状态
  void updatePresence(bool hidePresence) async {
    try {
      final response = await _apiService.updatePresence(userName, hidePresence);
      Get.find<GlobalController>().userInfo = response;
      showSuccess(AppConst.updateSuccess);
    } catch (e) {
      l.e('更新失败 $e');
      showError('更新失败');
    }
  }

  @override
  void onClose() {
    featurePageController.dispose();
    statusController.dispose();
    super.onClose();
  }

  // 更新状态
  void updateStatus() async {
    try {
      SuccessResponse<dynamic>? response;

      if (statusController.text.trim().isNotEmpty) {
        response = await _apiService.updateUserStatus(
          statusController.text.trim(),
          emoji: emojiStatus.value.replaceAll(':', ''),
        );
      } else {
        response = await _apiService.deleteUserStatus();
      }
      if (response.isSuccess) {
        showSuccess(AppConst.configSuccess);
        emojiStatus.value = '';
        statusController.clear();
        Get.find<GlobalController>().fetchUserInfo();
      } else {
        showError(AppConst.configFailed);
      }
    } catch (e, s) {
      l.e('更新失败 $e --- $s');
      showError('更新失败');
    }
  }

  void _getSummaryData() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getUserSummary(userName);
      summaryData.value = data;
      Get.find<SummaryController>().updateData(data);
    } catch (e, s) {
      l.e('获取统计数据失败 $e --- $s');
    } finally {
      isLoading.value = false;
    }
  }

  // 访问点赞信息页面
  void toLikePage() async {
    if (summaryData.value != null) {
      Get.toNamed(Routes.LIKE_PAGE, arguments: summaryData.value);
    } else {
      showError('获取数据失败');
    }
  }

  // 访问Follow页面
  void toFollowPage() async {
    Get.toNamed(Routes.FOLLOW_PAGE);
  }

  // 访问收藏页面
  void toCollectPage() {
    Get.toNamed(Routes.BOOKMARKS);
  }

  // 访问热门页面
  void toPopularPage() {
    if (summaryData.value != null) {
      Get.toNamed(Routes.POPULAR_PAGE, arguments: summaryData.value);
    } else {
      showError('获取数据失败');
    }
  }

  // 切换表情选择器
  void toggleEmojiPicker() {
    if (isShowEmojiPicker.value) {
      isShowEmojiPicker.value = false;
      isHideKeyboard.value = false;

      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(Get.context!).requestFocus(focusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        isShowEmojiPicker.value = true;
        isHideKeyboard.value = true;
      });
    }
  }
}
