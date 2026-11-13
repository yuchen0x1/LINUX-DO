import 'package:get/get.dart';
import 'package:linux_do/models/user_action.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controller/base_controller.dart';
import '../../../utils/log.dart';
import '../../../utils/mixins/concatenated.dart';
import '../../../utils/tag.dart';

class ActivityController extends BaseController with Concatenated {
  final RxList<UserAction> activities = <UserAction>[].obs;
  final ApiService _apiService = Get.find();
  late final RefreshController refreshController;

  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  @override
  void onInit() {
    super.onInit();
    CategoryManager().initialize();
    refreshController = RefreshController();
    _loadActivities();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> _loadActivities() async {
    if (isUserEmpty()) {
      return;
    }

    try {
      isLoading.value = _isFirstLoad;
      final data = await _apiService.getUserActions(
        userName,
        _currentPage * _pageSize,
        "4,5",
      );

      if (data.userActions.isNotEmpty) {
        activities.addAll(data.userActions);
        _currentPage++;
        _hasMore = data.userActions.length >= _pageSize;
        refreshController.loadComplete();
      } else {
        _hasMore = false;
        refreshController.loadNoData();
      }
      _isFirstLoad = false;
    } catch (e, stack) {
      l.e('加载活动数据失败: $e\n$stack');
      refreshController.loadFailed();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLoadMore() async {
    if (!_hasMore) {
      refreshController.loadNoData();
      return;
    }
    await _loadActivities();
  }

  Future<void> onRefresh() async {
    _currentPage = 0;
    _hasMore = true;
    activities.clear();
    await _loadActivities();
    refreshController.refreshCompleted();
  }
}
