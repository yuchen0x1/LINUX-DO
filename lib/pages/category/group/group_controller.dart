import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/group.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/log.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GroupController extends BaseController {
  final ApiService _apiService = Get.find();
  late final RefreshController refreshController;

  // 数据相关
  final groups = <Group>[].obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;
  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController();
    fetchGroups();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  // 获取群组列表
  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      clearError();

      final response = await _apiService.getGroups();

      groups.value = response.groups;
      hasMore.value = response.loadMoreGroups != null;
      currentPage.value = 1;

      l.d('获取群组列表成功: ${groups.length} 个群组');
    } catch (e, s) {
      l.e('获取群组列表失败: $e  $s');
      setError(AppConst.group.error);
    } finally {
      isLoading.value = false;
    }
  }

  // 刷新数据
  Future<void> onRefresh() async {
    try {
      final response = await _apiService.getGroups();

      groups.value = response.groups;
      hasMore.value = response.loadMoreGroups != null;
      currentPage.value = 1;
      l.d('当前加入状态 : ${groups[0].id} ${groups[0].isGroupUser}');
      l.d('当前加入状态 : ${groups[1].id} ${groups[1].isGroupUser}');

      refreshController.refreshCompleted();
      l.d('刷新群组列表成功');
    } catch (e) {
      l.e('刷新群组列表失败: $e');
      refreshController.refreshFailed();
    }
  }

  // 加载更多
  Future<void> loadMore() async {
    if (!hasMore.value) {
      refreshController.loadNoData();
      return;
    }

    try {
      final nextPage = currentPage.value + 1;
      final response = await _apiService.getGroups();

      if (response.groups.isEmpty) {
        hasMore.value = false;
        refreshController.loadNoData();
        return;
      }

      groups.addAll(response.groups);
      hasMore.value = response.loadMoreGroups != null;
      currentPage.value = nextPage;

      refreshController.loadComplete();
      l.d('加载更多群组成功: 当前 ${groups.length} 个群组');
    } catch (e) {
      l.e('加载更多群组失败: $e');
      refreshController.loadFailed();
    }
  }

  // 加入群组
  Future<void> joinGroup(int groupId) async {
    try {
      await _apiService.joinGroup(groupId);
      showSuccess(AppConst.group.joinSuccess);
      // 刷新数据
      onRefresh();
    } catch (e) {
      l.e('加入群组失败: $e');
      showError(AppConst.group.joinFailed);
    }
  }

  // 退出群组
  Future<void> leaveGroup(int groupId) async {
    l.d('退出群组 : $groupId');
    try {
      await _apiService.leaveGroup(groupId);
      showSuccess(AppConst.group.leaveSuccess);
      // 刷新数据
      onRefresh();
    } catch (e) {
      l.e('退出群组失败: $e');
      showError(AppConst.group.leaveFailed);
    }
  }
}
