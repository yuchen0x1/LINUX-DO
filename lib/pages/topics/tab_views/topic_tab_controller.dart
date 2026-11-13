import 'dart:math';

import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controller/base_controller.dart';
import '../../../models/topic_model.dart';
import '../../../net/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/log.dart';
import '../../../utils/mixins/toast_mixin.dart';
import '../../../utils/user_cache.dart';

class TopicTabController extends BaseController
    with GetSingleTickerProviderStateMixin {
  final String path;
  final ApiService apiService = Get.find();
  final _userCache = UserCache();
  late final RefreshController refreshController;
  final topics = <Topic>[].obs;
  final hasMore = true.obs;
  final currentPage = 0.obs;
  final globalController = Get.find<GlobalController>();

  // 加载状态
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;

  TopicTabController({required this.path}) {
    refreshController = RefreshController();
  }

  @override
  void onInit() {
    super.onInit();
    fetchTopics();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  // 获取话题列表
  Future<void> fetchTopics() async {
    try {
      isLoading.value = true;
      clearError();

      final response = await apiService.getTopics(path);

      // 更新用户缓存
      _userCache.updateUsers(response.users);

      topics.value = response.topicList?.topics ?? [];
      hasMore.value = response.topicList?.moreTopicsUrl != null;
      currentPage.value = 1;
      takeRandomSelected();
    } catch (e) {
      l.e('获取话题列表失败: $e');
      setError('获取话题列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  void takeRandomSelected() {
    if (globalController.topics.isEmpty) {
      final random = Random();
      final randomTopics = <Topic>[];
      final usedIndices = <int>{};
      while (randomTopics.length < 2 && usedIndices.length < topics.length) {
        final index = random.nextInt(topics.length);
        if (usedIndices.add(index)) {
          randomTopics.add(topics[index]);
        }
      }
      globalController.topics.assignAll(randomTopics);
    }
  }

  // 刷新数据
  Future<void> onRefresh() async {
    try {
      currentPage.value = 0;
      isRefreshing.value = true;
      clearError(); // 清除之前的错误
      refreshController.requestRefresh();
      final response = await apiService.getTopics(path);

      // 更新用户缓存
      _userCache.updateUsers(response.users);

      topics.value = response.topicList?.topics ?? [];
      hasMore.value = response.topicList?.moreTopicsUrl != null;
      currentPage.value = 1;
      refreshController.refreshCompleted();
      l.d('刷新数据成功');
    } catch (e) {
      refreshController.refreshFailed();
      setError('刷新失败');
    } finally {
      isRefreshing.value = false;
    }
  }

  // 加载更多
  Future<void> loadMore() async {
    if (!hasMore.value) {
      refreshController.loadNoData();
      return;
    }

    try {
      isLoadingMore.value = true;
      clearError();
      final nextPage = currentPage.value + 1;
      l.d('当前页码: $nextPage');
      final response = await apiService.getTopics(path, nextPage);

      // 更新用户缓存
      _userCache.updateUsers(response.users);

      // 获取新加载的话题
      final newTopics = response.topicList?.topics ?? [];

      // 去重：过滤掉已经存在的话题
      final existingIds = topics.map((topic) => topic.id).toSet();
      final uniqueNewTopics = newTopics
          .where((topic) => !existingIds.contains(topic.id))
          .toList();

      // 只添加不重复的话题
      topics.addAll(uniqueNewTopics);

      hasMore.value = response.topicList?.moreTopicsUrl != null;
      currentPage.value = nextPage;

      if (!hasMore.value) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
      //l.d('加载更多成功');
    } catch (e) {
      refreshController.loadFailed();
      setError('加载更多失败');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // 跳转到帖子详情
  void toTopicDetail(int id) {
    if (globalController.showHiddenContent) {
      Get.toNamed(Routes.WEB_POST_READ, arguments: id);
    } else {
      Get.toNamed(Routes.TOPIC_DETAIL, arguments: id);
    }
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
      final response = await apiService.setTopicMute(id.toString(), 0);
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
