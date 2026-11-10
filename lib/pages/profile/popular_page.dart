import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/badge_detail.dart';
import 'package:linux_do/models/category_data.dart';
import 'package:linux_do/models/summary.dart';
import 'package:linux_do/pages/profile/popular_controller.dart';
import 'package:linux_do/utils/badge.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/utils/tag.dart';
import 'package:linux_do/widgets/badge_widget.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:linux_do/models/topic_model.dart' as t;

class PopularPage extends GetView<PopularController> {
  const PopularPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 30.w,
          width: MediaQuery.of(context).size.width - 100.w,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0).w,
          child: Obx(() {
            final currentIndex = controller.selectedIndex.value;
            return SlideSwitcher(
              containerHeight: 30.w,
              containerWight: MediaQuery.of(context).size.width - 120.w,
              initialIndex: currentIndex,
              containerColor: Theme.of(context).cardColor,
              slidersGradients: [
                LinearGradient(colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.6)
                ])
              ],
              onSelect: (index) => controller.switchTab(index),
              children: [
                _buildTabText(context, '话题', 0),
                _buildTabText(context, '链接', 1),
                _buildTabText(context, '回复', 2),
                _buildTabText(context, '类别', 3),
                _buildTabText(context, '徽章', 4),
              ],
            );
          }),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 内容区域
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTopicsPage(context),
                _buildLinksPage(context),
                _buildRepliesPage(context),
                _buildCategoriesPage(context),
                _buildBadgesPage(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建标签文本
  Widget _buildTabText(BuildContext context, String text, int index) {
    return Obx(() => Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: controller.selectedIndex.value == index
                ? Colors.white
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ));
  }

  // 构建话题页面
  Widget _buildTopicsPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final topics = controller.topics;
      final isLoading = controller.topicsLoading.value;

      if (isLoading && topics.isEmpty) {
        return StateView.loading();
      }

      if (topics.isEmpty && controller.topicsLoaded.value) {
        return StateView.empty(message: '暂无热门话题');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await controller.refreshData();
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12).w,
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return _buildTopicCard(context, topic);
          },
        ),
      );
    });
  }

  // 构建话题卡片
  Widget _buildTopicCard(BuildContext context, t.Topic topic) {
    final createdDate = DateTime.parse(topic.createdAt ?? '');
    final formattedTime = createdDate.friendlyDateTime;
    final category = CategoryManager().getCategory(topic.categoryId ?? 0);
    final logoUrl = category?.logo?.imageUrl;
    final c = category?.color;
    final tc = category?.textColor;
    final color = c != null
        ? Color(int.parse(c)).withValues(alpha: 0.6)
        : Theme.of(context).primaryColor.withValues(alpha: 0.6);
    final textColor =
        tc != null ? Color(int.parse(tc)) : Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        controller.toTopicDetail(topic.id, null);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8).w,
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
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 话题标题
                    Text(
                      topic.title ?? '无标题',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFontFamily.dinPro,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    8.vGap,

                    // 话题信息
                    Row(
                      children: [
                        if (category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.w),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Row(
                              children: [
                                if (logoUrl != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4).w,
                                    child: CachedImage(
                                      imageUrl: logoUrl,
                                      width: 12.w,
                                      height: 12.w,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  4.hGap,
                                ],
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: textColor,
                                    fontFamily: AppFontFamily.dinPro,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        6.hGap,

                        Expanded(
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: AppFontFamily.dinPro,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),

                        // 点赞量
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.heart_circle,
                              size: 14.w,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            4.hGap,
                            Text(
                              formatNumber((topic.likeCount ?? 0)),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: AppFontFamily.dinPro,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),

                        12.hGap,

                        // 回复数
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.chat_bubble_text,
                              size: 14.w,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            4.hGap,
                            Text(
                              '${topic.postsCount ?? 0}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: AppFontFamily.dinPro,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建链接页面
  Widget _buildLinksPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final links = controller.links;
      final isLoading = controller.isLoading.value;

      if (isLoading && links.isEmpty) {
        return StateView.loading();
      }

      if (links.isEmpty) {
        return StateView.empty(message: '暂无热门链接');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await controller.refreshData();
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12).w,
          itemCount: links.length,
          itemBuilder: (context, index) {
            final link = links[index];
            return _buildLinkCard(context, link);
          },
        ),
      );
    });
  }

  // 构建链接卡片
  Widget _buildLinkCard(BuildContext context, Link link) {
    final url = link.url;
    final title = link.title ?? '未知链接';
    final domain = Uri.tryParse(url)?.host ?? '';
    final clicks = link.clicks;

    return Card(
      margin: const EdgeInsets.only(bottom: 6).w,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4).w,
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (url.isNotEmpty) {
            controller.openLink(url);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              8.vGap,

              // 链接域名和点击数
              Row(
                children: [
                  Icon(
                    CupertinoIcons.link,
                    size: 14.w,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
                  6.hGap,
                  Text(
                    domain,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 3)
                            .w,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12).w,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.hand_point_right_fill,
                          size: 12.w,
                          color: Theme.of(context).primaryColor,
                        ),
                        4.hGap,
                        Text(
                          '$clicks',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建回复页面
  Widget _buildRepliesPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final replies = controller.replies;
      final isLoading = controller.isLoading.value;

      if (isLoading && replies.isEmpty) {
        return StateView.loading();
      }

      if (replies.isEmpty) {
        return StateView.empty(message: '暂无热门回复');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await controller.refreshData();
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12).w,
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            return _buildReplyCard(context, reply);
          },
        ),
      );
    });
  }

  // 构建回复卡片
  Widget _buildReplyCard(BuildContext context, t.Topic reply) {
    final topicId = reply.id;
    final topicTitle = reply.title ?? '未知话题';
    final excerpt = reply.excerpt ?? '';
    final likeCount = reply.likeCount ?? 0;
    final createdAt = reply.createdAt != null
        ? DateTime.parse(reply.createdAt!)
        : DateTime.now();
    final formattedTime = createdAt.friendlyDateTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 6).w,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4).w,
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 打开话题
          controller.toTopicDetail(topicId, reply.postNumber);
        },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 话题标题
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 8.w),
                child: Text(
                  topicTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 回复内容
              if (excerpt.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: HtmlWidget(
                    html: excerpt,
                    fontSize: 13,
                  ),
                ),

              // 底部信息栏
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 12.w),
                child: Row(
                  children: [
                    // 时间
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),

                    const Spacer(),

                    // 点赞数
                    if (likeCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12).w,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.heart_fill,
                              size: 12.w,
                              color: Colors.red,
                            ),
                            4.hGap,
                            Text(
                              formatNumber(likeCount),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
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

  // 构建类别页面
  Widget _buildCategoriesPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final categories = controller.categories;
      final isLoading = controller.isLoading.value;

      if (isLoading && categories.isEmpty) {
        return StateView.loading();
      }

      if (categories.isEmpty) {
        return StateView.empty(message: '暂无热门类别');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await controller.refreshData();
          refreshController.refreshCompleted();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12).w,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      );
    });
  }

  // 构建类别卡片
  Widget _buildCategoryCard(BuildContext context, Category category) {
    final name = category.name ?? '未知类别';
    final count = category.topicCount ?? 0;
    final replyCount = category.postCount ?? 0;
    final categoryItem = CategoryManager().getCategory(category.id);

    final logoUrl = categoryItem?.logo?.imageUrl;
    final tc = categoryItem?.textColor;
    final textColor =
        tc != null ? Color(int.parse(tc)) : Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12).w,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4).w,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          padding: const EdgeInsets.all(12).w,
          child: Row(
            children: [
              // 类别图标
              if (logoUrl != null)
                Container(
                  width: 20.w,
                  height: 20.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4).w,
                  ),
                  child: CachedImage(
                    imageUrl: logoUrl,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.contain,
                  ),
                ),

              // 类别信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    4.vGap,
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: AppFontFamily.dinPro,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              const Spacer(),

              // 回复数量
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Text(
                  '$replyCount 回复',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.white,
                    fontFamily: AppFontFamily.dinPro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              4.hGap,

              // 话题数量
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Text(
                  '$count 话题',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.white,
                    fontFamily: AppFontFamily.dinPro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建徽章页面
  Widget _buildBadgesPage(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Obx(() {
      final badges = controller.badges;
      final isLoading = controller.isLoading.value;

      if (isLoading && badges.isEmpty) {
        return StateView.loading();
      }

      if (badges.isEmpty) {
        return StateView.empty(message: '暂无徽章');
      }

      return DisSmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await controller.refreshData();
          refreshController.refreshCompleted();
        },
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12).w,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return GestureDetector(
              onTap: () => _showBadgeDetail(context, badge),
              child: BadgeWidget(
                badge: badge,
                badgeTypeName: controller.getBadgeTypeName(badge.badgeTypeId),
              ),
            );
          },
        ),
      );
    });
  }

  void _showBadgeDetail(BuildContext context, BadgeDetail badge) {
    final badgeColor = BadgeIconHelper.getColor(badge.name);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 0.8.sw,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部渐变背景区域
              Container(
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        badgeColor,
                        badgeColor.withValues(alpha: 0.6),
                      ]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.w),
                    topRight: Radius.circular(16.w),
                  ),
                ),
                child: Stack(
                  children: [
                    // 关闭按钮
                    Positioned(
                      right: 16.w,
                      top: 16.w,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                    ),
                    // 徽章图标
                    Center(
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: badge.getImageUrl().isNotEmpty
                            ? CachedImage(
                                imageUrl: badge.getImageUrl(),
                                width: 40.w,
                                height: 40.w,
                                circle: true,
                              )
                            : Icon(
                                BadgeIconHelper.getIcon(badge.name),
                                size: 30.w,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              // 徽章信息
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      badge.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    8.vGap,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Text(
                        badge.hasBadge ? '已获得' : '未获得',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: badgeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    12.vGap,
                    HtmlWidget(html: badge.description, onLinkTap: (url) {}),
                    if (badge.longDescription != null &&
                        badge.longDescription!.isNotEmpty) ...[
                      8.vGap,
                      HtmlWidget(
                          html: badge.longDescription!, onLinkTap: (url) {})
                    ],
                    16.vGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.w),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            controller.getBadgeTypeName(badge.badgeTypeId),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: badgeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        12.hGap,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.w),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '已授予 ${formatNumber(badge.grantCount)} 个',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: badgeColor,
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
        ),
      ),
      barrierDismissible: true,
    );
  }
}

/// 转换K单位
String formatNumber(int number) {
  if (number >= 1000) {
    double value = number / 1000;
    return '${value.toStringAsFixed(1)}k';
  }
  return number.toString();
}
