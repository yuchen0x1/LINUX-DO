import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/follow.dart';
import 'package:linux_do/models/user_post.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/utils/tag.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:slide_switcher/slide_switcher.dart';

import 'follow_controller.dart';

class FollowPage extends GetView<FollowController> {
  const FollowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: MediaQuery.of(context).size.width - 180.w,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3).w,
          child: Obx(() {
            final currentIndex = controller.selectedIndex.value;
            return SlideSwitcher(
              containerHeight: 32.w,
              containerWight: MediaQuery.of(context).size.width - 180.w,
              initialIndex: currentIndex,
              containerColor: Theme.of(context).cardColor,
              slidersGradients: [
                LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.6),
                  ],
                ),
              ],
              onSelect: (index) => controller.switchTab(index),
              children: [
                _buildTabText(context, '动态', 0),
                _buildTabText(context, '关注', 1),
                _buildTabText(context, '关注者', 2),
              ],
            );
          }),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 标签切换

          // 内容区域
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildUserPostsPage(context),
                _buildFollowingPage(context),
                _buildFollowersPage(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建标签文本
  Widget _buildTabText(BuildContext context, String text, int index) {
    return Obx(
      () => Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: controller.selectedIndex.value == index
              ? Colors.white
              : Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 构建用户帖子页面
  Widget _buildUserPostsPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final userPosts = controller.userPosts;
      final isLoading = controller.isLoading.value;

      if (isLoading && userPosts.isEmpty) {
        return StateView.loading();
      }

      if (userPosts.isEmpty) {
        return StateView.empty(message: '暂无动态');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: controller.hasMorePosts.value,
        onRefresh: () async {
          await controller.refreshPosts();
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          await controller.loadMorePosts();
          refreshController.loadComplete();
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            final post = userPosts[index];
            return _buildUserPostCard(context, post);
          },
        ),
      );
    });
  }

  // 构建用户帖子卡片
  Widget _buildUserPostCard(BuildContext context, UserPost post) {
    final user = post.user;
    final avatarUrl = user.avatarUrl;
    final username = user.username ?? '';
    final displayName = user.name ?? '无名大佬';
    final createdDate = DateTime.parse(post.createdAt);
    final formattedTime = createdDate.friendlyDateTime;
    final category = CategoryManager().getCategory(post.categoryId);
    final logoUrl = category?.logo?.imageUrl;
    final slug = category?.slug;
    final c = category?.color;
    final tc = category?.textColor;
    final color = c != null
        ? Color(int.parse(c)).withValues(alpha: 0.6)
        : Theme.of(context).primaryColor.withValues(alpha: 0.6);
    final textColor = tc != null
        ? Color(int.parse(tc))
        : Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        controller.toTopicDetail(post.topicId, post.postNumber);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16).w,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4).w,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.w,
                ),
                leading: AvatarWidget(
                  avatarUrl: avatarUrl,
                  username: username,
                  size: 44,
                  circle: !(post.isWebMaster()),
                  borderColor: Theme.of(context).primaryColor,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: post.isWebMaster()
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.color,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@$username',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: AppFontFamily.dinPro,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: AppFontFamily.dinPro,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 帖子主题
                      Text(
                        post.topic.title ?? '无标题',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFontFamily.dinPro,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.vGap,
                      // 帖子内容
                      if (post.excerpt.isNotEmpty)
                        HtmlWidget(html: post.excerpt, fontSize: 11),
                    ],
                  ),
                ),
              ),

              // 底部操作区域
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 类别标签

                    if (category != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Row(
                          children: [
                            if (logoUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6).w,
                                child: CachedImage(
                                  imageUrl: logoUrl,
                                  width: 13.w,
                                  height: 13.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              10.hGap,
                            ],
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    if (slug != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3).w,
                        ),
                        child: Text(
                          slug,
                          style: TextStyle(
                            fontSize: 8.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: textColor,
                          ),
                        ),
                      ),

                    4.hGap,

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_text,
                            size: 12.w,
                            color: Theme.of(context).primaryColor,
                          ),
                          4.hGap,
                          Text(
                            '${post.postNumber}',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建关注页面
  Widget _buildFollowingPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final following = controller.following;
      final isLoading = controller.followingLoading.value;
      final hasMore = controller.hasMoreFollowing.value;

      if (isLoading && following.isEmpty) {
        return StateView.loading();
      }

      if (following.isEmpty && controller.followingLoaded.value) {
        return StateView.empty(message: '暂无关注');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: hasMore,
        onRefresh: () async {
          await controller.refreshFollowing();
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          await controller.loadMoreFollowing();
          refreshController.loadComplete();
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          itemCount: following.length,
          itemBuilder: (context, index) {
            final user = following[index];
            return _buildFollowUserCard(context, user, isFollowing: true);
          },
        ),
      );
    });
  }

  // 构建关注者页面
  Widget _buildFollowersPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final followers = controller.followers;
      final isLoading = controller.followersLoading.value;
      final hasMore = controller.hasMoreFollowers.value;

      if (isLoading && followers.isEmpty) {
        return StateView.loading();
      }

      if (followers.isEmpty && controller.followersLoaded.value) {
        return StateView.empty(message: '暂无关注者');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: hasMore,
        onRefresh: () async {
          await controller.refreshFollowers();
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          await controller.loadMoreFollowers();
          refreshController.loadComplete();
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return _buildFollowUserCard(context, user, isFollowing: false);
          },
        ),
      );
    });
  }

  // 构建关注/关注者用户卡片
  Widget _buildFollowUserCard(
    BuildContext context,
    Follow user, {
    required bool isFollowing,
  }) {
    final avatarUrl = user.avatarUrl;
    final username = user.username ?? '用户';
    final displayName = user.name == null || user.name!.isEmpty
        ? 'Anonymous Big Shot'
        : user.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 8).w,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4).w),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).cardColor, Theme.of(context).cardColor],
          ),
          borderRadius: BorderRadius.circular(4).w,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户信息
            Padding(
              padding: const EdgeInsets.all(12).w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像
                  AvatarWidget(
                    avatarUrl: avatarUrl,
                    username: username,
                    size: 50,
                    circle: !user.isWebMaster,
                    borderColor: Theme.of(context).primaryColor,
                  ),
                  12.hGap,

                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFontFamily.dinPro,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '@$username',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: AppFontFamily.dinPro,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            16.hGap,

                            // 关注按钮
                            SizedBox(
                              height: 30.w,
                              child: DisButton(
                                icon: isFollowing
                                    ? CupertinoIcons.checkmark
                                    : CupertinoIcons.add,
                                text: isFollowing ? '已关注' : '关注',
                                type: !isFollowing
                                    ? ButtonType.primary
                                    : ButtonType.outline,
                                onPressed: () {
                                  if (isFollowing) {
                                    controller.unfollowUser(user.username!);
                                  } else {
                                    controller.followUser(user.username!);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
