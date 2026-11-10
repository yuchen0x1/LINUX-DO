import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../controller/base_controller.dart';
import '../../../const/app_const.dart';
import '../../../models/leaderboard.dart';
import '../../../net/api_service.dart';
import '../../../utils/log.dart';

class LeaderboardController extends BaseController {
  final ApiService apiService = Get.find();
  late final RefreshController refreshController;

  // 数据相关
  final leaderboardData = <LeaderboardUser>[].obs;
  final meData = Rxn<LeaderboardInfo>();
  final personalRank = Rxn<PersonalRank>();
  final topListData = <LeaderboardUser>[].obs;

  // 分页相关
  final hasMore = true.obs;
  final currentPage = 1.obs;
  static const int pageSize = 100;

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController();
    fetchLeaderboard();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      clearError();

      final response = await apiService.getLeaderboard();

      // 更新数据 从第三个开始
      leaderboardData.value = response.users.sublist(3);
      personalRank.value = response.personal;
      topListData.value = response.users
          .take(response.users.length >= 3 ? 3 : response.users.length)
          .toList();
      // 判断是否还有更多数据
      hasMore.value = response.users.length >= pageSize;
      currentPage.value = 1;

      l.d('获取排行榜数据成功: ${leaderboardData.length} 条数据');
    } catch (e, s) {
      l.e('获取排行榜数据失败: $e - $s');
      setError(AppConst.leaderboard.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value) {
      refreshController.loadNoData();
      return;
    }

    try {
      final nextPage = currentPage.value + 1;
      final response = await apiService.getLeaderboard(
        categoryId: '/1',
        period: 'all',
        page: nextPage,
      );

      if (response.users.isEmpty) {
        hasMore.value = false;
        refreshController.loadNoData();
        return;
      }

      // 添加新数据
      leaderboardData.addAll(response.users);

      // 更新分页状态
      hasMore.value = response.users.length >= pageSize;
      currentPage.value = nextPage;

      refreshController.loadComplete();
      l.d('加载更多成功: 当前 ${leaderboardData.length} 条数据');
    } catch (e) {
      l.e('加载更多失败: $e');
      refreshController.loadFailed();
      setError(AppConst.leaderboard.error);
    }
  }
}
