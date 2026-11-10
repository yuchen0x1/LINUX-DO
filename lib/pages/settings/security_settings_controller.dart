import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/user_auth_token.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';

class SecuritySettingsController extends BaseController
    with ToastMixin, Concatenated {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  final devices = <UserAuthToken>[].obs;

  final isEmailSent = false.obs;
  final isSendingEmail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      isLoading.value = true;
      final userInfo = _globalController.userInfo;
      if (userInfo != null) {
        final deviceList = userInfo.user?.userAuthTokens ?? [];
        // Sort devices by seenAt time in descending order
        deviceList.sort((a, b) {
          final aTime = a.seenAt != null
              ? DateTime.parse(a.seenAt!)
              : DateTime(1970);
          final bTime = b.seenAt != null
              ? DateTime.parse(b.seenAt!)
              : DateTime(1970);
          return bTime.compareTo(aTime); // Descending order (most recent first)
        });
        devices.value = deviceList;
      }
    } catch (e) {
      l.e('加载设备列表失败: $e');
      showError('加载设备列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutDevice(int tokenId) async {
    try {
      await _apiService.revokeAuthToken(userName, tokenId);
      await _globalController.fetchUserInfo();
      await _loadDevices();
      showSuccess('退出成功');
    } catch (e) {
      l.e('退出设备失败: $e');
      showError('退出设备失败');
    }
  }

  Future<void> logoutAllDevices() async {
    try {
      await _apiService.revokeAllAuthTokens();
      Get.back();
      showSuccess('退出所有设备成功');
    } catch (e) {
      l.e('退出所有设备失败: $e');
      showError('退出所有设备失败');
    }
  }

  // 发送忘记密码的电子邮件
  Future<void> sendEmail() async {
    try {
      final email = _globalController.userInfo?.user?.email ?? '';

      if (email.isEmpty) {
        showError('请先设置邮箱');
        return;
      }

      isSendingEmail.value = true;
      await _apiService.sendResetPasswordEmail(email);
      isEmailSent.value = true;
    } catch (e) {
      l.e('发送邮件失败: $e');
      showError('发送邮件失败');
    } finally {
      isSendingEmail.value = false;
    }
  }
}
