import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import '../../models/bookmark_item.dart';
import '../../utils/bookmark_service.dart';
import '../../routes/app_pages.dart';

class BookmarkController extends BaseController
    with GetSingleTickerProviderStateMixin {
  final BookmarkService _bookmarkService = Get.find<BookmarkService>();

  // 当前选中的分类索引
  final selectedCategoryIndex = 0.obs;

  // 所有支持的分类
  final categories = <String>[].obs;

  // 当前分类的收藏项
  final bookmarkItems = <BookmarkItem>[].obs;

  // 页面控制器
  late PageController pageController;

  // 标签控制器
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();

    // 初始化分类列表
    categories.assignAll(_bookmarkService.bookmarksByCategory.keys.toList());

    pageController = PageController(initialPage: selectedCategoryIndex.value);
    tabController = TabController(
        length: categories.length,
        vsync: this,
        initialIndex: selectedCategoryIndex.value);

    // 标签控制器监听
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedCategoryIndex.value = tabController.index;
        if (pageController.page?.round() != tabController.index) {
          pageController.jumpToPage(tabController.index);
        }
      }
    });

    // 加载初始分类的收藏数据
    _loadBookmarksForCurrentCategory();
  }

  @override
  void onClose() {
    pageController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // 切换分类
  void switchCategory(int index) {
    if (index == selectedCategoryIndex.value) return;

    selectedCategoryIndex.value = index;

    // 同步两个控制器
    if (tabController.index != index) {
      tabController.animateTo(index);
    }

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // 加载当前分类的收藏数据
    _loadBookmarksForCurrentCategory();
  }

  // 页面改变时更新索引
  void onPageChanged(int index) {
    selectedCategoryIndex.value = index;

    if (tabController.index != index) {
      tabController.animateTo(index);
    }

    _loadBookmarksForCurrentCategory();
  }

  void _loadBookmarksForCurrentCategory() {
    if (categories.isEmpty) return;

    final currentCategory = categories[selectedCategoryIndex.value];
    final items = _bookmarkService.getBookmarksByCategory(currentCategory);

    // 按保存时间排序
    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));

    bookmarkItems.assignAll(items);
  }

  // 删除收藏
  Future<void> removeBookmark(BookmarkItem item) async {
    final currentCategory = categories[selectedCategoryIndex.value];
    final success =
        await _bookmarkService.removeBookmark(item.id, currentCategory);

    if (success) {
      bookmarkItems.removeWhere((bookmark) => bookmark.id == item.id);
      showSuccess('移除成功');
    }
  }

  // 跳转到主题详情
  void toTopicDetail(int topicId) {
    Get.toNamed(
      Routes.TOPIC_DETAIL,
      arguments: topicId,
    );
  }

  // 刷新数据
  void refreshBookmarks() {
    _loadBookmarksForCurrentCategory();
  }
}
