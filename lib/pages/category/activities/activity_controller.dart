import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/activity_stream.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/const/app_const.dart';

import '../../../routes/app_pages.dart';

/// 因为已经有一个Activite
class EventController extends BaseController {
  final ApiService _apiService = Get.find();

  // 数据相关
  final events = <ActivityEvent>[].obs;
  final selectedDate = DateTime.now().obs;
  final selectedEvents = <ActivityEvent>[].obs;
  final selectedRange = <DateTime>[].obs;

  final monthNames = [
    "一月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  // 获取活动列表
  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      clearError();

      final response = await _apiService.getEventStream();
      events.value = response.events;

      if (events.isNotEmpty) {
        selectedRange.value = [
          DateTime.parse(events.first.startsAt),
          DateTime.parse(events.first.endsAt),
        ];
        // 更新选中日期的活动
        updateSelectedEvents();
      }

      l.d('获取活动列表成功: ${events.length} 个活动');
    } catch (e, s) {
      l.e('获取活动列表失败: $e $s');
      setError(AppConst.activity.error);
    } finally {
      isLoading.value = false;
    }
  }

  // 更新选中日期的活动
  void updateSelectedEvents() {
    final selected = selectedDate.value;
    selectedEvents.value = events.where((event) {
      final startDate = DateTime.parse(event.startsAt);
      final endDate = DateTime.parse(event.endsAt);
      return selected.isAfter(startDate.subtract(const Duration(days: 1))) &&
          selected.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // 选择日期
  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    updateSelectedEvents();
  }

  onEventTap(ActivityEvent event) {
    Get.toNamed(Routes.TOPIC_DETAIL, arguments: event.post.topic.id);
  }
}
