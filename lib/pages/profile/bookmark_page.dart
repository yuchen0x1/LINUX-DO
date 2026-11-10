import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/bookmark_item.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'bookmark_controller.dart';

class BookmarkPage extends GetView<BookmarkController> {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '收藏',
          style: TextStyle(
              fontSize: 15.w,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontFamily.dinPro),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: Icon(CupertinoIcons.question_circle_fill,
                size: 20, color: Theme.of(context).primaryColor),
          )
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.categories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(top: 6, bottom: 16).w,
              height: 44.w,
              decoration: BoxDecoration(
                // 确保底部没有任何线条
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  tabBarTheme: const TabBarThemeData(
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  controller: controller.tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
                  indicator: const BoxDecoration(),
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 13.w,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 13.w,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16).w,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6).w,
                  onTap: controller.switchCategory,
                  tabs: controller.categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isSelected =
                        controller.selectedCategoryIndex.value == index;

                    final hue = (category.hashCode % 12) * 30.0;
                    final categoryColor =
                        HSLColor.fromAHSL(1.0, hue, 0.6, 0.8).toColor();

                    return Tab(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8)
                            .w,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    categoryColor,
                                    categoryColor.withValues(alpha: 0.5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color:
                              isSelected ? null : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: categoryColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                          border: !isSelected
                              ? Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          // 内容区域
          Expanded(
            child: Obx(() {
              if (controller.categories.isEmpty) {
                return StateView.empty(message: '暂无收藏分类');
              }

              return PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  return _buildBookmarkList(context, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 构建收藏列表
  Widget _buildBookmarkList(BuildContext context, int categoryIndex) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final items = controller.bookmarkItems;

      if (items.isEmpty) {
        return StateView.empty(message: '暂无收藏内容');
      }

      // 获取当前分类
      final currentCategory = controller.categories[categoryIndex];
      // 计算当前分类的颜色
      final hue = (currentCategory.hashCode % 12) * 30.0;
      final categoryColor = HSLColor.fromAHSL(1.0, hue, 0.6, 0.8).toColor();

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          controller.refreshBookmarks();
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12).w,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildBookmarkCard(context, item, categoryColor);
          },
        ),
      );
    });
  }

  Widget _buildBookmarkCard(
      BuildContext context, BookmarkItem item, Color categoryColor) {
    final formattedTime = item.savedAt.friendlyDateTime;
    return GestureDetector(
      onTap: () => controller.toTopicDetail(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6).w,
        child: Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                onPressed: (_) => controller.removeBookmark(item),
                backgroundColor: AppColors.l2,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(4).w,
                    bottomRight: const Radius.circular(4).w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.delete,
                        size: 17.w, color: AppColors.white),
                    SizedBox(height: 4.w),
                    Text(
                      '移除',
                      style: TextStyle(fontSize: 12.w, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4).w,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12).w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.avatarUrl.isNotEmpty)
                        AvatarWidget(
                          avatarUrl: item.avatarUrl,
                          size: 40,
                          circle: item.userId != 1,
                          username: item.username,
                          borderColor: Theme.of(context).primaryColor,
                        ),
                      if (item.avatarUrl.isNotEmpty) 12.hGap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFontFamily.dinPro,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            4.vGap,
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.clock,
                                  size: 12.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                4.hGap,
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 10.w,
                                    fontFamily: AppFontFamily.dinPro,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),

                                const Spacer(),

                                // 分类标签
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4)
                                      .w,
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4).w,
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 10.w,
                                      fontFamily: AppFontFamily.dinPro,
                                      color: categoryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (item.tags.isNotEmpty) ...[
                    6.vGap,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)
                              .w,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12).w,
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 9.w,
                              fontFamily: AppFontFamily.dinPro,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 显示提示弹窗
  void _showInfoDialog(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20).w,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 320.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).cardColor.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20, left: 24, right: 24).w,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle_fill,
                        color: primaryColor,
                        size: 20.w,
                      ),
                      12.hGap,
                      Text(
                        '关于本地收藏',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // 分割线
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24)
                          .w,
                  child: Divider(
                    height: 1.h,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),

                // 内容
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24).w,
                  child: Container(
                    padding: const EdgeInsets.all(16).w,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12).w,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      '请注意，本地收藏的数据会在清空App或者卸载后丢失。',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24).w,
                  width: double.infinity,
                  child: DisButton(
                    text: '我知道了',
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      // 自定义从上向下的转场动画
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }
}
