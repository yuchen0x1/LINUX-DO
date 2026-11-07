import 'dart:convert';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controller/base_controller.dart';
import '../../../models/notification.dart';
import '../../../net/api_service.dart';
import '../../../utils/log.dart';
import '../../../utils/mixins/concatenated.dart';

class NotificationController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();
  final notifications = <NotificationItem>[].obs;
  late final RefreshController refreshController;
  
  static const int _pageSize = 60;
  bool _hasMore = true;
  bool _isFirstLoad = true;
  
  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController();
    _loadNotifications();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> _loadNotifications() async {
    if (isUserEmpty()) return;
   
    try {
      isLoading.value = _isFirstLoad;
      final response = await _apiService.getNotifications(
        userName,
        _pageSize,
        'all',
      );
      l.i('加载通知数据: ${jsonEncode(response)}');
      
      if (response.notifications.isNotEmpty) {
        notifications.addAll(response.notifications);
        _hasMore = response.notifications.length >= _pageSize;
        refreshController.loadComplete();
      } else {
        _hasMore = false;
        refreshController.loadNoData();
      }
      _isFirstLoad = false;
    } catch (e, stack) {
      l.e('加载通知数据失败: $e\n$stack');
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
    await _loadNotifications();
  }

  /// 将通知按 今天/昨天/更早 分组，返回 (组标题, 通知列表) 有序列表
  List<(String, List<NotificationItem>)> buildGroupedList() {
    if (notifications.isEmpty) return const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <NotificationItem>[];
    final yesterdayList = <NotificationItem>[];
    final earlierList = <NotificationItem>[];

    for (final n in notifications) {
      final date = DateTime.tryParse(n.createdAt);
      if (date == null) {
        earlierList.add(n);
        continue;
      }
      final day = DateTime(date.year, date.month, date.day);
      if (day.isAtSameMomentAs(today)) {
        todayList.add(n);
      } else if (day.isAtSameMomentAs(yesterday)) {
        yesterdayList.add(n);
      } else {
        earlierList.add(n);
      }
    }

    final result = <(String, List<NotificationItem>)>[];
    if (todayList.isNotEmpty) result.add(('今天', todayList));
    if (yesterdayList.isNotEmpty) result.add(('昨天', yesterdayList));
    if (earlierList.isNotEmpty) result.add(('更早', earlierList));
    return result;
  }
} 