import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';

class EmailSettingsController extends BaseController {
  // 个人消息
  final personalMessageOption = 1.obs;
  // 提及和回复
  final mentionsOption = 1.obs;
  // 关注的类别
  final watchingOption = 1.obs;
  // 策略审核
  final policyOption = 1.obs;
  // 活动总结
  final summaryOption = 1.obs;
  // 包含以前的回复
  final includeReplies = false.obs;
  // 发送热门话题和回复
  final summary = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEmailSettings();
  }

  Future<void> _loadEmailSettings() async {
    try {
      isLoading.value = true;
    } catch (e) {
      showError('加载设置失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveEmailSettings() async {
    try {
      isLoading.value = true;
      // 模拟保存
      await Future.delayed(const Duration(seconds: 1));
      showSuccess('保存成功');
      Get.back();
    } catch (e) {
      showError('保存失败');
    } finally {
      isLoading.value = false;
    }
  }
}
