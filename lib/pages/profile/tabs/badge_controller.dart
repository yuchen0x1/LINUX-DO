import 'package:get/get.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import '../../../controller/base_controller.dart';
import '../../../models/badge_detail.dart';

class BadgeController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();
  final RxList<BadgeDetail> badges = <BadgeDetail>[].obs;
  final RxList<BadgeType> badgeTypes = <BadgeType>[].obs;
  final RxList<BadgeGrouping> badgeGroupings = <BadgeGrouping>[].obs;
  final RxInt selectedIndex = 0.obs;
  final RxMap<int, List<BadgeDetail>> filteredBadgesMap =
      <int, List<BadgeDetail>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedIndex, (_) => _updateFilteredBadges());
    fetchBadges();
  }

  Future<void> fetchBadges() async {
    if (isUserEmpty()) return;
    isLoading.value = true;
    try {
      final response = await _apiService.getBadges();
      badges.value = response.badges ?? [];
      badgeTypes.value = response.badgeTypes ?? [];
      badgeGroupings.value = response.badgeGroupings ?? [];
      _updateFilteredBadges();
    } catch (e) {
      errorMessage.value = '获取徽章失败';
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateFilteredBadges() {
    final newMap = <int, List<BadgeDetail>>{};
    for (var grouping in badgeGroupings) {
      var groupBadges = badges
          .where((b) => b.badgeGroupingId == grouping.id)
          .toList();
      if (selectedIndex.value == 1) {
        groupBadges = groupBadges.where((b) => b.hasBadge).toList();
      }
      newMap[grouping.id] = groupBadges;
    }
    filteredBadgesMap.value = newMap;
  }

  // 获取徽章类型名称
  String getBadgeTypeName(int typeId) {
    final type = badgeTypes.firstWhereOrNull((type) => type.id == typeId);
    return type?.name ?? '';
  }

  // 获取徽章图标
  String getBadgeIcon(BadgeDetail badge) {
    if (badge.imageUrl != null && badge.imageUrl!.isNotEmpty) {
      return badge.imageUrl!;
    }
    return badge.icon ?? '';
  }

  // 切换徽章显示类型（全部/已获得）
  void switchBadgeType(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }

  // 获取过滤后的徽章列表
  List<BadgeDetail> getFilteredBadges(int groupingId) {
    return filteredBadgesMap[groupingId] ?? [];
  }
}
