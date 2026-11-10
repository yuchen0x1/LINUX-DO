import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/summary.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/utils/user_cache.dart';

class PersonalController extends BaseController {
  final ApiService _apiService = Get.find();
  final summaryData = Rxn<SummaryResponse>();
  final _userCache = UserCache();

  final personalUserName = Get.arguments;

  final selectedTabIndex = 0.obs;

  // 别人的用户信息
  final _userInfo = Rxn<UserResponse>();

  UserResponse? get userInfo => _userInfo.value;

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
    fetchSummary();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await _apiService.getCurrentUser(personalUserName);
      _userInfo.value = response;
    } catch (e, stack) {
      l.e('获取用户信息失败: $e\n$stack');
    }
  }

  void fetchSummary() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getUserSummary(personalUserName);
      summaryData.value = data;
      _userCache.updateUsers(data.users ?? []);
    } catch (e) {
      l.e('获取用户信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}w';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // 跳转到帖子详情
  void toTopicDetail(int id) {
    Get.toNamed(Routes.TOPIC_DETAIL, arguments: id);
  }

  // 获取最新发帖人头像
  String? getLatestPosterAvatar(Topic topic) {
    final latestPosterId = topic.getOriginalPosterId();
    if (latestPosterId == null) return null;
    return _userCache.getAvatarUrl(latestPosterId);
  }

  // 获取昵称
  String? getNickName(Topic topic) {
    final latestPosterId = topic.getOriginalPosterId();
    if (latestPosterId == null) return null;
    return _userCache.getNickName(latestPosterId);
  }

  // 获取用户名
  String? getUserName(Topic topic) {
    final id = topic.getOriginalPosterId();
    if (id == null) return null;
    return _userCache.getUserName(id);
  }

  Future<void> doNotDisturb(int id) async {
    l.d('设置免打扰 id : $id');
    try {
      final response = await _apiService.setTopicMute(id.toString(), 0);
      l.d('设置免打扰响应: $response');

      // 检查响应是否成功
      final isSuccess = response is Map
          ? response['success'] == 'OK'
          : response.toString().contains('OK');

      if (isSuccess) {
        showSnackbar(
          title: AppConst.commonTip,
          message: AppConst.posts.disturbSuccess,
          type: SnackbarType.success,
        );
      } else {
        l.e('设置免打扰失败: 响应数据异常 $response');
        showSnackbar(
          title: AppConst.commonTip,
          message: AppConst.posts.error,
          type: SnackbarType.error,
        );
      }
    } catch (e, stackTrace) {
      l.e('设置免打扰失败: $e\n$stackTrace');
      showSnackbar(
        title: AppConst.commonTip,
        message: AppConst.posts.error,
        type: SnackbarType.error,
      );
    }
  }

  List<String> getAvatarUrls(Topic topic) {
    // 通过_userCache获取头像
    final avatarUrls = topic.getAvatarUrls();
    return avatarUrls
        .map((id) => _userCache.getAvatarUrl(id))
        .whereType<String>()
        .toList();
  }
}
