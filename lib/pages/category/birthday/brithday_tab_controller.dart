import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controller/base_controller.dart';
import '../../../models/birthday.dart';
import '../../../net/api_service.dart';
import 'birthday_controller.dart';

class BrithdayTabController extends BaseController
    with GetTickerProviderStateMixin {
  final Filter filter;
  final ApiService _apiService = Get.find();

  final RxList<Birthday> birthdays = <Birthday>[].obs;

  /// 当前月份
  int currentMonth = DateTime.now().month;

  /// 当前页码
  int currentPage = 1;

  /// 每页数据量
  int pageSize = 20;

  /// 总数据量
  int totalRows = 0;

  /// 当前过滤条件
  String currentFilter = '';

  final refreshController = RefreshController();

  bool _isInitialized = false;

  BrithdayTabController(this.filter);

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await fetchBirthdays(isRefresh: true);
    }
  }

  Future<void> fetchBirthdays({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
      }

      // 判断是否还有更多数据
      if (!isRefresh && birthdays.length >= totalRows) {
        refreshController.loadNoData();
        return;
      }

      isLoading.value = currentPage == 1;
      hasError.value = false;

      final response = await _apiService.getBirthdays(
          filter == Filter.month ? null : filter.value,
          birthdays.length >= totalRows && filter != Filter.month
              ? null
              : currentPage,
          filter == Filter.month ? DateTime.now().month : null);

      if (isRefresh) {
        birthdays.clear();
      }

      totalRows = response.totalRowsBirthdays;
      birthdays.addAll(response.birthdays);

      // 更新刷新状态
      if (birthdays.length >= totalRows) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }

      if (isRefresh) {
        refreshController.refreshCompleted();
      }
    } catch (e) {
      hasError.value = true;
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onRefresh() async {
    await fetchBirthdays(isRefresh: true);
  }

  void onLoading() async {
    currentPage++;
    await fetchBirthdays();
  }

  void onBirthdayTap(Birthday birthday) {}

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
