import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/models/topic_model.dart';
import '../models/user.dart';
import '../net/api_service.dart';
import '../net/http_client.dart';
import '../net/message_bus_service.dart';
import '../utils/log.dart';
import '../utils/mixins/concatenated.dart';
import '../utils/storage_manager.dart';
import 'base_controller.dart';

/// 全局控制器

class GlobalController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();

  // 用户信息
  final _userInfo = Rxn<UserResponse>();

  // 生成唯一的client_id
  static String clientId = '';

  final _isLogin = false.obs;

  final _isAnonymousMode = false.obs;

  /// 获取是否登录
  bool get isLogin => _isLogin.value;

  /// 设置是否登录
  void setIsLogin(bool value) {
    _isLogin.value = value;
  }

  set userInfo(UserResponse? value) {
    _userInfo.value = value;
  }

  UserResponse? get userInfo => _userInfo.value;

  final topics = <Topic>[].obs;

  // 游客模式
  bool get isAnonymousMode => _isAnonymousMode.value;

  // 展示隐藏内容
  final _showHiddenContent = false.obs;

  bool get showHiddenContent => _showHiddenContent.value;

  void setShowHiddenContent(bool value) {
    _showHiddenContent.value = value;
  }

  void setIsAnonymousMode(bool value) {
    _isAnonymousMode.value = value;
  }

  @override
  void onInit() {
    super.onInit();

    _checkClientId();
  }

  void _checkClientId() {
    String? clientSaveId =
        StorageManager.getString(AppConst.identifier.clientId);
    if (clientSaveId != null && clientSaveId.isNotEmpty) {
      clientId = clientSaveId;
    } else {
      clientId = generateRandomMD5LikeString();
      StorageManager.setData(AppConst.identifier.clientId, clientId);
    }
  }

  String generateRandomMD5LikeString() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return md5.convert(bytes).toString();
  }

  Future<bool> checkLoginStatus() async {
    try {
      // 首先检查是否有有效的 cookies
      final hasValidCookies = await NetClient.getInstance().hasValidCookies();
      if (!hasValidCookies) {
        _isLogin.value = false;
        return false;
      }

      _isLogin.value = true;
      return true;

      // // 如果有有效的 cookies，再尝试请求接口验证

      // try {
      //   final response = await httpClient.get('unread.json');
      //   _isLogin.value = response.isSuccess;
      // } catch (e) {
      //   l.e('验证登录状态失败: $e');
      //   _isLogin.value = false;
      // }
    } catch (e) {
      l.e('检查登录状态失败: $e');
      _isLogin.value = false;
      return false;
    }
  }

  // 获取用户信息
  Future<void> fetchUserInfo() async {
    if (isUserEmpty()) return;

    try {
      final response = await _apiService.getCurrentUser(userName);
      _userInfo.value = response;
    } catch (e, stack) {
      l.e('获取用户信息失败: $e\n$stack');
    }
  }

  Future<void> initService() async {
    await _apiService.getTopics('latest');
    // 登录态就绪后启动 MessageBus 实时推送监听
    if (_isLogin.value && !_isAnonymousMode.value) {
      MessageBusService().start();
    }
  }
}
