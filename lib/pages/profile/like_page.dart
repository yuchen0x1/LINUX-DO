import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_svg_icon.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'like_controller.dart';

class LikePage extends GetView<LikeController> {
  const LikePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: MediaQuery.of(context).size.width - 180.w,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.w),
          child: Obx(() => SlideSwitcher(
                containerHeight: 36.w,
                containerWight: MediaQuery.of(context).size.width - 180.w,
                initialIndex: controller.selectedIndex.value,
                containerColor: Theme.of(context).cardColor,
                slidersGradients: [
                  LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.6)
                  ])
                ],
                onSelect: (index) => controller.switchTab(index),
                children: [
                  _buildTabText(context, '最多赞', 0),
                  _buildTabText(context, '赞最多', 1),
                ],
              )),
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
                Obx(() => _buildMostLikedByUsersGrid(context)),
                Obx(() => _buildMostLikedUsersGrid(context)),
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
            fontSize: 13.w,
            color: controller.selectedIndex.value == index
                ? Colors.white
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ));
  }

  // 构建最多赞网格 - 展示用户收到的赞
  Widget _buildMostLikedByUsersGrid(BuildContext context) {
    final likedData =
        controller.summaryData.value?.userSummary?.mostLikedByUsers;

    if (likedData == null || likedData.isEmpty) {
      return Center(child: Text('暂无数据', style: TextStyle(fontSize: 14.sp)));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 12.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
        ),
        itemCount: likedData.length,
        itemBuilder: (context, index) {
          final item = likedData[index];
          return _buildLikeCard(
            context,
            item: item,
            isUser: true,
          );
        },
      ),
    );
  }

  // 构建赞最多网格 - 展示用户给出的赞
  Widget _buildMostLikedUsersGrid(BuildContext context) {
    final likedData = controller.summaryData.value?.userSummary?.mostLikedUsers;

    if (likedData == null || likedData.isEmpty) {
      return Center(child: Text('暂无数据', style: TextStyle(fontSize: 14.sp)));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 12.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
        ),
        itemCount: likedData.length,
        itemBuilder: (context, index) {
          final item = likedData[index];
          return _buildLikeCard(
            context,
            item: item,
            isUser: false,
          );
        },
      ),
    );
  }

  // 构建点赞卡片
  Widget _buildLikeCard(
    BuildContext context, {
    required User item,
    required bool isUser,
  }) {
    final avatarUrl = item.avatarUrl;
    final username = item.username ?? '用户';
    final count = item.count?.toString() ?? '0';
    final imageUrl = item.flairUrl;
    final displayName = item.name;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(8.w, 6.w, 8.w, 12.w),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像
              AvatarWidget(
                avatarUrl: avatarUrl,
                username: username,
                borderRadius: 4,
                circle: !(item.admin ?? false),
                backgroundColor: Theme.of(context).primaryColor,
                size: 50,
              ),

              12.vGap,

              // 用户名
              Text(
                '@$username',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                displayName == null || displayName.isEmpty
                    ? 'Anonymous Big Shot'
                    : displayName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              8.vGap,

              // 点赞信息
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16.w,
                      color: isUser ? Colors.redAccent : Colors.white,
                    ),
                    4.hGap,
                    Text(
                      isUser ? '收到 $count 个赞' : '点赞 $count 次',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: AppFontFamily.dinPro,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              16.vGap,

              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  isUser ? '被喜欢最多' : '喜欢最多',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0.w,
            top: 0.w,
            child: item.admin ?? false
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: DisSvgIcon(
                      iconName: AppImages.batteryQuarter,
                      size: 18.w,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : imageUrl != null && imageUrl.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(4.w),
                        child: CachedImage(
                          imageUrl: imageUrl,
                          width: 16,
                          height: 16,
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
