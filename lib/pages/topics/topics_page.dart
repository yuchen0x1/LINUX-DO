import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/banner_settings.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import '../../const/app_const.dart';
import '../../const/app_images.dart';
import '../../routes/app_pages.dart';
import '../../utils/tag.dart';
import 'topics_controller.dart';
import '../../utils/storage_manager.dart';
import 'package:linux_do/pages/topics/widgets/banner_picker_dialog.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({Key? key}) : super(key: key);

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage>
    with SingleTickerProviderStateMixin {
  final TopicsController controller = Get.find<TopicsController>();

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 44.w;
    final margin = 18.w;
    final menuWidth = 44.w; // 菜单按钮宽度
    final horizontalPadding = 16.w; // 水平内边距
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: controller.handleScrollNotification,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  minHeight: kToolbarHeight + appBarHeight, // AppBar高度 + 搜索框高度
                  maxHeight: 180.w,
                  child: Container(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final top = constraints.biggest.height;

                        // 计算折叠进度
                        final collapsedProgress = ((180.w - top) /
                                (180.w - kToolbarHeight - appBarHeight))
                            .clamp(0.0, 1.0);

                        return Stack(
                          children: [
                            // 搜索框（固定在AppBar下方）
                            _buildTopWidget(
                                appBarHeight,
                                collapsedProgress,
                                menuWidth,
                                context,
                                margin,
                                horizontalPadding),
                            // 背景图片（只在展开状态显示）
                            if (collapsedProgress < 1)
                              Positioned(
                                top: kToolbarHeight + appBarHeight,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    Get.put(BannerPickerController(controller.bannerSettings.value));
                                    final result = await Get.dialog<BannerSettings>(
                                      const BannerPickerDialog(),
                                    );
                                    Get.delete<BannerPickerController>();
                                    if (result != null) {
                                      await controller.saveBannerSettings(result);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: margin),
                                    padding: const EdgeInsets.only(bottom: 6).w,
                                    child: Opacity(
                                      opacity: 1 - collapsedProgress,
                                      child: Obx(() => controller.getBannerImage(context)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                pinned: true,
              ),

              // 标语
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.6)
                      ],
                    ),
                  ),
                  child: Text(
                    AppConst.slogan.replaceAll('\n', ''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.w,
                    ),
                  ),
                ),
              ),

              // Tab栏
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  minHeight: appBarHeight,
                  maxHeight: appBarHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: .1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: controller.tabController,
                      isScrollable: false,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).hintColor,
                      labelStyle: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.normal,
                      ),
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: controller.tabs,
                    ),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: controller.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: controller.tabViews,
          ),
        ),
      ),
    );
  }

  Positioned _buildTopWidget(
      double appBarHeight,
      double collapsedProgress,
      double menuWidth,
      BuildContext context,
      double margin,
      double horizontalPadding) {
        final logoWidth = 100.w;
    return Positioned(
      top: kToolbarHeight,
      left: 0,
      right: 0,
      height: appBarHeight,
      child: Row(
        children: [
         
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () {
                final delegate = TopicSearchDelegate(controller);
                showSearch(
                  context: context,
                  delegate: delegate,
                ).then((_) {
                  if (controller.lastSearchQuery.value.isNotEmpty) {
                    delegate.query = controller.lastSearchQuery.value;
                    delegate.showResults(context);
                  }
                });
              },
              child: Container(
                height: 32.w,
                margin: EdgeInsets.only(
                  top: 4.w,
                  bottom: 4.w,
                  left: margin,
                  right: margin,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(18.w),
                  border: Border.all(
                    color: Theme.of(context).hintColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18.w,
                      color: Theme.of(context).hintColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppConst.posts.searchTopic,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 右侧logo
          AnimatedOpacity(
            opacity: collapsedProgress,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: logoWidth * collapsedProgress,
              child: Container(
                padding: EdgeInsets.only(right: horizontalPadding),
                child: Image.asset(
                  AppImages.getLogo(context),
                  width: logoWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 添加 SliverPersistentHeaderDelegate 实现
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child));
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class TopicSearchDelegate extends SearchDelegate<String> {
  final TopicsController controller;
  final RxList<String> searchHistory = <String>[].obs;
  static const String searchHistoryKey = 'topic_search_history';

  TopicSearchDelegate(this.controller)
      : super(
          searchFieldLabel: AppConst.posts.searchTopic,
          searchFieldStyle: TextStyle(
            fontSize: 14.w,
            color: Get.theme.textTheme.bodyMedium?.color,
          ),
        ) {
    // 加载搜索历史
    _loadSearchHistory();
  }

  // 加载搜索历史
  void _loadSearchHistory() {
    final history = StorageManager.getStringList(searchHistoryKey) ?? [];
    searchHistory.value = history;
  }

  // 保存搜索历史
  void _saveSearchHistory(String query) {
    if (query.isEmpty) return;
    
    // 如果已存在，先删除旧的
    searchHistory.remove(query);
    // 添加到开头
    searchHistory.insert(0, query);
    // 限制历史记录数量
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }
    // 保存到本地存储
    StorageManager.setData(searchHistoryKey, searchHistory.toList());
  }

  // 清除搜索历史
  void _clearSearchHistory() {
    searchHistory.clear();
    StorageManager.remove(searchHistoryKey);
  }

  // 删除单个搜索历史
  void _removeSearchHistory(String query) {
    searchHistory.remove(query);
    StorageManager.setData(searchHistoryKey, searchHistory.toList());
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        hintStyle: TextStyle(
          fontSize: 14.w,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Obx(() {
        if (controller.isSearching.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: SizedBox(
                height: 16.w,
                child: DisRefreshLoading(fontSize: 8.w),
              ),
            ),
          );
        }
        return Row(
          children: [
            if (searchHistory.isNotEmpty && query.isEmpty)
              IconButton(
                icon: Icon(
                  CupertinoIcons.delete,
                  size: 18.w,
                  color: AppColors.error,
                ),
                onPressed: () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Container(
                        width: 0.8.sw,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.w),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.delete,
                                color: Theme.of(context).primaryColor,
                                size: 20.w,
                              ),
                            ),
                            16.vGap,
                            Text(
                              '清除搜索历史',
                              style: TextStyle(
                                fontSize: 16.w,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            12.vGap,
                            Text(
                              '确定要清除所有搜索历史吗？',
                              style: TextStyle(
                                fontSize: 14.w,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            24.vGap,
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20.w),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppConst.cancel,
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                12.hGap,
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _clearSearchHistory();
                                      Get.back();
                                    },
                                    child: Container(
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20.w),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppConst.confirm,
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    barrierColor: Theme.of(context).shadowColor.withValues(alpha: 0.4),
                  );
                },
              ),
            IconButton(
              icon: Icon(
                CupertinoIcons.clear,
                size: 18.w,
                color: Theme.of(context).hintColor,
              ),
              onPressed: () {
                if (query.isEmpty) {
                  close(context, '');
                } else {
                  query = '';
                  controller.clearSearch();
                }
              },
            ),
          ],
        );
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        CupertinoIcons.arrow_left_circle_fill,
        size: 24.w,
        color: Theme.of(context).hintColor,
      ),
      onPressed: () {
        controller.clearSearch();
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // 显示搜索历史
      return Obx(() {
        if (searchHistory.isEmpty) {
          return Center(
            child: Text(
              '暂无搜索历史',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14.w,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: searchHistory.length,
          itemBuilder: (context, index) {
            final historyItem = searchHistory[index];
            return ListTile(
              leading: Icon(
                CupertinoIcons.clock,
                size: 18.w,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                historyItem,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  CupertinoIcons.clear_circled,
                  size: 18.w,
                  color: Theme.of(context).hintColor,
                ),
                onPressed: () => _removeSearchHistory(historyItem),
              ),
              onTap: () {
                query = historyItem;
                _saveSearchHistory(historyItem);
                controller.lastSearchQuery.value = historyItem;
                showResults(context);
              },
            );
          },
        );
      });
    }

    return Obx(() {
      if (controller.topics.isEmpty) {
        return Center(
          child: Text(
            controller.searchError.value.isNotEmpty
                ? controller.searchError.value
                : '没有找到相关内容',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12.w,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        itemCount: controller.topics.length,
        itemBuilder: (context, index) {
          final topic = controller.topics[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                _saveSearchHistory(query);
                controller.lastSearchQuery.value = query;
                await Get.toNamed(Routes.TOPIC_DETAIL, arguments: topic.id, preventDuplicates: true);
              },
              borderRadius: BorderRadius.circular(4.w),
              splashColor: Theme.of(context).primaryColor.withValues(alpha: .1),
              highlightColor: Theme.of(context).primaryColor.withValues(alpha: .05),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 3.w, horizontal: 12.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.w,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topic.tags != null && topic.tags!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.w),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: topic.tags!.map((tag) {
                              final color = Tag.getTagColors(tag);
                              return Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.w),
                                decoration: BoxDecoration(
                                  color: color.backgroundColor,
                                  border: Border.all(
                                    color: color.backgroundColor,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 9.w,
                                    color: color.textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    4.vGap,
                    _buildHighlightedTitle(context, topic.title ?? ''),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildHighlightedTitle(BuildContext context, String title) {
    final keyword = query.trim();
    final baseStyle = TextStyle(
      fontSize: 14.w,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    if (keyword.isEmpty) {
      return Text(
        title,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerTitle = title.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final spans = <InlineSpan>[];
    var cursor = 0;
    while (cursor < title.length) {
      final matchIndex = lowerTitle.indexOf(lowerKeyword, cursor);
      if (matchIndex < 0) {
        spans.add(TextSpan(text: title.substring(cursor)));
        break;
      }
      if (matchIndex > cursor) {
        spans.add(TextSpan(text: title.substring(cursor, matchIndex)));
      }
      final matchEnd = matchIndex + keyword.length;
      spans.add(TextSpan(
        text: title.substring(matchIndex, matchEnd),
        style: baseStyle.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.16),
        ),
      ));
      cursor = matchEnd;
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    if (query.isNotEmpty) {
      _saveSearchHistory(query);
      controller.lastSearchQuery.value = query;
      controller.searchTopics(query);
    } else {
      controller.clearSearch();
    }
  }

  @override
  void showSuggestions(BuildContext context) {
    super.showSuggestions(context);
    if (query.isNotEmpty) {
      _saveSearchHistory(query);
      controller.lastSearchQuery.value = query;
      controller.searchTopics(query);
    } else {
      controller.clearSearch();
    }
  }
}
