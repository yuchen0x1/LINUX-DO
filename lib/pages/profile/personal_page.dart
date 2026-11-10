import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/pages/profile/personal_controller.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_item.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/glowing_text_wweep.dart';
import 'package:slide_switcher/slide_switcher.dart';

class PersonalPage extends GetView<PersonalController> {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建一个 ValueNotifier 来跟踪滚动进度
    final scrollProgress = ValueNotifier<double>(0.0);

    return Scaffold(
      body: Obx(() {
        // 检查用户信息是否已加载
        final userInfo = controller.userInfo;
        final expandedHeight = userInfo?.user?.backgroundUrl != null
            ? 380.w
            : 280.w;
        // 如果用户信息为空，显示加载状态
        if (userInfo == null) {
          return Center(child: DisRefreshLoading());
        }

        final user = userInfo.user;
        if (user == null) {
          return const Center(child: Text('无法加载用户信息'));
        }

        return NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: expandedHeight,
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final top = constraints.biggest.height;
                  final shrinkOffset = expandedHeight - top;
                  final progress =
                      (shrinkOffset / (expandedHeight - kToolbarHeight)).clamp(
                        0.0,
                        1.0,
                      );

                  // 更新滚动进度
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollProgress.value = progress;
                  });

                  return Container(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: progress),
                    child: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 背景图片
                          if (progress < 1)
                            Opacity(
                              opacity: (1 - progress).clamp(0.0, 1.0),
                              child: user.backgroundUrl != null
                                  ? CachedImage(
                                      imageUrl: user.backgroundUrl ?? '',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppImages.profileHeaderBg,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          // 模糊效果
                          if (progress > 0)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: progress * 50,
                                sigmaY: progress * 50,
                              ),
                              child: Container(
                                color: Colors.black.withValues(
                                  alpha: progress * 0.7,
                                ),
                              ),
                            ),
                          // 渐变遮罩
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 6.w,
                            left: lerpDouble(-1.w, 56.w, progress) ?? -1.w,
                            right: 32.w,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 16.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.only(
                                  bottomRight: const Radius.circular(100).w,
                                  topRight: const Radius.circular(100).w,
                                ),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.0),
                                  width: .4.w,
                                ),
                              ),
                            ),
                          ),

                          // 用户信息
                          Positioned(
                            bottom: lerpDouble(10.w, 16.w, progress) ?? 10.w,
                            left: lerpDouble(8.w, 56.w, progress) ?? 8.w,
                            right: 0,
                            child: _buildProfile(user, progress, context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              title: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showTitle = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: showTitle ? 1.0 : 0.0,
                    child: showTitle
                        ? Text(
                            user.name ?? user.username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              leadingWidth: 80.w,
              leading: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showAvatar = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showAvatar ? 1.0 : 0.0,
                    child: showAvatar
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                            ).w,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(
                                    CupertinoIcons.chevron_left,
                                    size: 20,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 1.w,
                                    ),
                                    borderRadius: BorderRadius.circular(80.w),
                                  ),
                                  child: CachedImage(
                                    imageUrl: user.avatarUrl,
                                    circle: !user.isWebMaster(),
                                    width: 30.w,
                                    height: 30.w,
                                    borderRadius: BorderRadius.circular(80.w),
                                    showBorder: true,
                                    borderColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ),

            // 统计信息
            // SliverToBoxAdapter(
            //   child: Container(
            //     padding: EdgeInsets.symmetric(vertical: 10.w),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         _buildStatItem(context, '文章', "34" ?? '0'),
            //         _buildStatItem(context, '回复', "34" ?? '0'),
            //         _buildStatItem(context, '点赞', "34" ?? '0'),
            //         _buildStatItem(context, '收到点赞', "34" ?? '0'),
            //       ],
            //     ),
            //   ),
            // ),

            // Tab栏
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                height: 40.0.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(12.w),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).shadowColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SlideSwitcher(
                    containerHeight: 40.w,
                    containerWight: MediaQuery.of(context).size.width - 40.w,
                    initialIndex: 0,
                    containerColor: Theme.of(context).cardColor,
                    slidersGradients: [
                      LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ],
                    onSelect: (index) => controller.changeTab(index),
                    children: [
                      Text('热门话题', style: TextStyle(fontSize: 14.sp)),
                      Text('热门回复', style: TextStyle(fontSize: 14.sp)),
                      Text('热门链接', style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: _buildTabContent(context, controller.selectedTabIndex.value),
        );
      }),
    );
  }

  Widget _buildTabContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildActivityTab();
      case 1:
        return _buildTopicsTab();
      case 2:
        return _buildRepliesTab();
      case 3:
        return _buildFavoritesTab();
      default:
        return const Center(child: Text('内容不可用'));
    }
  }

  Widget _buildActivityTab() {
    return Obx(() {
      final topics = controller.summaryData.value?.topics;
      final user = controller.userInfo?.user;
      if (topics == null) {
        return const Center(child: Text('暂无数据'));
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return TopicItem(
            topic: topic,
            avatarUrl: user?.avatarUrl,
            nickName: user?.name,
            username: user?.username,
            avatarUrls: controller.getAvatarUrls(topic),
            avatarActions: AvatarActions.noAction,
            onTap: () {
              controller.toTopicDetail(topic.id);
            },
            onDoNotDisturb: (topic) {
              controller.doNotDisturb(topic.id);
            },
          );
        },
      );
    });
  }

  Widget _buildTopicsTab() {
    return const Center(child: Text('热门主题'));
  }

  Widget _buildRepliesTab() {
    return const Center(child: Text('热门回复'));
  }

  Widget _buildFavoritesTab() {
    return const Center(child: Text('热门链接'));
  }

  Widget _buildProfile(
    CurrentUser user,
    double progress,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2.w,
                ),
                borderRadius: BorderRadius.circular(45.w),
              ),
              child: CachedImage(
                imageUrl: user.avatarUrl,
                circle: true,
                width: 50.w,
                height: 50.w,
                showInnerBorder: true,
                innerBorderColor: Colors.white,
                innerBorderWidth: 2.w,
              ),
            ),
            6.hGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlowingTextSweep(
                    text: user.name != null && user.name!.isNotEmpty
                        ? user.name!
                        : user.username,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15.w,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    glowColor: Colors.white,
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: AppFontFamily.dinPro,
                      fontSize: 11.w,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 自定义StickyTabBarDelegate以避免布局错误
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabBarDelegate({required this.child, this.height = 40.0});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
