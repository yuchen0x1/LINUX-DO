import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/category.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/user_cache.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CategoryListController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  int? categoryId;
  String? tag;
  final RxList<Topic> topics = <Topic>[].obs;
  final refreshController = RefreshController();
  final _userCache = UserCache();
  int? page;

  @override
  void onInit() {
    super.onInit();
    _initializeArguments();
    fetchTopics();
  }

  void _initializeArguments() {
    if (Get.arguments is Category) {
      final category = Get.arguments as Category;
      categoryId = category.id;
      tag = null;
    } else if (Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      tag = args['tag'] as String?;
      categoryId = null;
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> fetchTopics() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      page = 1;
      final TopicListResponse result;
      if (tag != null) {
        result = await _apiService.getTopicsByTag(tag!);
      } else {
        result = await _apiService.getCategoriesTopics(categoryId!);
      }

      _userCache.updateUsers(result.users);
      if (result.topicList?.topics != null) {
        topics.assignAll(result.topicList!.topics);
      }
    } catch (e) {
      l.e('Error fetching topics: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      page = null;
      final TopicListResponse result;
      if (tag != null) {
        result = await _apiService.getTopicsByTag(tag!);
      } else {
        result = await _apiService.getCategoriesTopics(categoryId!);
      }
      _userCache.updateUsers(result.users);
      if (result.topicList?.topics != null) {
        topics.assignAll(result.topicList!.topics);
      }
      refreshController.refreshCompleted();
    } catch (e) {
      l.e('Error refreshing topics: $e');
      refreshController.refreshFailed();
    }
  }

  Future<void> loadMore() async {
    try {
      page = page! + 1;
      final TopicListResponse result;
      if (tag != null) {
        result = await _apiService.getTopicsByTag(tag!, page: page);
      } else {
        result = await _apiService.getCategoriesTopics(categoryId!, page: page);
      }
      _userCache.updateUsers(result.users);
      if (result.topicList?.topics == null ||
          result.topicList!.topics.isEmpty) {
        refreshController.loadNoData();
      } else {
        topics.addAll(result.topicList!.topics);
        refreshController.loadComplete();
      }
    } catch (e) {
      l.e('Error loading more topics: $e');
      refreshController.loadFailed();
    }
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
    try {
      final response = await _apiService.setTopicMute(id.toString(), 0);
      // 检查响应是否成功
      final isSuccess = response is Map
          ? response['success'] == 'OK'
          : response.toString().contains('OK');

      if (isSuccess) {
        showSuccess(AppConst.posts.disturbSuccess);
      } else {
        showError(AppConst.posts.error);
      }
    } catch (e) {
      showError(AppConst.posts.error);
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

  Future<void> deleteTopic(int id) async {
    try {
      final response = await _apiService.deleteTopic(id.toString());
      l.i('删除帖子: $response');
      if (response is Map) {
        showSuccess(AppConst.posts.deleteSuccess);
        topics.removeWhere((topic) => topic.id == id);
      } else {
        showError(AppConst.posts.error);
      }
    } catch (e) {
      showError(AppConst.posts.error);
    }
  }
}
