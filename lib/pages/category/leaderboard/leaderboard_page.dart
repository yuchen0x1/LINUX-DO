import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import '../../../const/app_colors.dart';
import '../../../const/app_const.dart';
import '../../../const/app_images.dart';
import '../../../models/leaderboard.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/state_view.dart';
import '../../../widgets/sticky_tab_delegate.dart';
import 'leaderboard_controller.dart';

class LeaderboardPage extends GetView<LeaderboardController> {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final crownSize = 60.w;
    final bidSize = 80.w;
    final labelSize = 30.w;
    final avatarSize = 180.w;
    final smallSize = 60.w;
    final margin = 16.w;
    final smallTop = 90.w;
    final nameSize = 36.w;
    final screenWidth = MediaQuery.of(context).size.width;
    final nameWidth = screenWidth.w / 3 - 16.w / 3;

    final contentView = Obx(
      () => DisSmartRefresher(
        enablePullDown: false,
        enablePullUp: controller.hasMore.value,
        onLoading: controller.loadMore,
        controller: controller.refreshController,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              sliver: SliverToBoxAdapter(
                child: _buildTopItem(
                  bidSize,
                  crownSize,
                  avatarSize,
                  labelSize,
                  screenWidth,
                  context,
                  nameWidth,
                  nameSize,
                  smallTop,
                  smallSize,
                  margin,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(margin),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  height: 60.w,
                  child: _buildMeItem(labelSize, context),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              sliver: _buildListView(labelSize),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.logoColor1,
      appBar: AppBar(
        backgroundColor: AppColors.logoColor1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
          ),
        ),
        title: Text(
          AppConst.leaderboard.title,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showTips,
            icon: const Icon(
              CupertinoIcons.question_circle_fill,
              color: AppColors.white,
            ),
          ),
          8.hGap,
        ],
      ),
      body: Obx(() => StateView(state: _getViewState(), child: contentView)),
    );
  }

  void _showTips() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary2, AppColors.secondary2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    color: AppColors.white,
                    size: 24.w,
                  ),
                  12.hGap,
                  Text(
                    AppConst.leaderboard.tipsTitle,
                    style: TextStyle(
                      fontSize: 18.w,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: AppColors.white, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              Text(
                AppConst.leaderboard.tips,
                style: TextStyle(
                  fontSize: 14.w,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
              20.vGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                    ),
                    child: Text(
                      AppConst.leaderboard.tipsKnow,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  SizedBox _buildTopItem(
    double bidSize,
    double crownSize,
    double avatarSize,
    double labelSize,
    double screenWidth,
    BuildContext context,
    double nameWidth,
    double nameSize,
    double smallTop,
    double smallSize,
    double margin,
  ) {
    // 检查是否有足够的数据
    if (controller.topListData.length < 3) {
      return const SizedBox.shrink();
    }

    final top1 = controller.topListData[0];
    final top2 = controller.topListData[1];
    final top3 = controller.topListData[2];
    return SizedBox(
      width: double.infinity,
      height: 240.w,
      child: Stack(
        children: [
          Positioned(
            top: bidSize / 1.5 + crownSize / 2,
            left: 0,
            right: 0,
            child: Image.asset(AppImages.leaderboardTop),
          ),
          SizedBox(
            width: double.infinity,
            height: avatarSize + labelSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  left: screenWidth / 2 - crownSize * 1.35,
                  child: Image.asset(
                    AppImages.crown,
                    width: crownSize,
                    height: crownSize,
                  ),
                ),

                Positioned(
                  top: crownSize / 1.35,
                  child: Container(
                    width: bidSize,
                    height: bidSize,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.l1, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.l1.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CachedImage(
                      imageUrl: top1.avatarUrl,
                      width: bidSize,
                      height: bidSize,
                      circle: true,
                      borderRadius: BorderRadius.circular(4.w),
                      showBorder: true,
                      backgroundColor: Theme.of(context).cardColor,
                      borderColor: AppColors.white,
                    ),
                  ),
                ),

                Positioned(
                  top: bidSize + labelSize - 4.w,
                  child: SizedBox(
                    width: labelSize,
                    height: labelSize,
                    child: getLabel(context, 1, labelSize),
                  ),
                ),

                Positioned(
                  bottom: labelSize,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: nameWidth,
                    height: nameSize,
                    child: getName(
                      context,
                      top1.displayName,
                      top1.formattedScore,
                      nameSize,
                    ),
                  ),
                ),

                // 第三名
                Positioned(
                  top: smallTop,
                  left: screenWidth / 4 - smallSize / 1.35 - margin * 2,
                  child: Container(
                    width: smallSize,
                    height: smallSize,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.l3, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.l3.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CachedImage(
                      imageUrl: top3.avatarUrl,
                      width: smallSize,
                      height: smallSize,
                      circle: true,
                      borderRadius: BorderRadius.circular(4.w),
                      showBorder: true,
                      backgroundColor: Theme.of(context).cardColor,
                      borderColor: AppColors.white,
                    ),
                  ),
                ),

                Positioned(
                  top: smallTop + smallSize - labelSize / 2 - 4.w,
                  left: screenWidth / 4 - smallSize / 2 - margin * 2,
                  child: SizedBox(
                    width: labelSize,
                    height: labelSize,
                    child: getLabel(context, 3, labelSize),
                  ),
                ),

                // 第三名的名称数据
                Positioned(
                  bottom: 0,
                  left: screenWidth / 3 - nameWidth - margin / 2,
                  child: SizedBox(
                    width: nameWidth,
                    height: nameSize,
                    child: getName(
                      context,
                      top3.displayName,
                      top3.formattedScore,
                      nameSize,
                    ),
                  ),
                ),

                // 第二名
                Positioned(
                  top: smallTop,
                  right: screenWidth / 4 - smallSize / 1.35 - margin * 2,
                  child: Container(
                    width: smallSize,
                    height: smallSize,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.l2, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.l2.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CachedImage(
                      imageUrl: top2.avatarUrl,
                      width: smallSize,
                      height: smallSize,
                      circle: true,
                      borderRadius: BorderRadius.circular(4.w),
                      showBorder: true,
                      backgroundColor: Theme.of(context).cardColor,
                      borderColor: AppColors.white,
                    ),
                  ),
                ),

                Positioned(
                  top: smallTop + smallSize - labelSize / 2 - 4.w,
                  right: screenWidth / 4 - smallSize / 2 - margin * 2,
                  child: SizedBox(
                    width: labelSize,
                    height: labelSize,
                    child: getLabel(context, 2, labelSize),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: screenWidth / 3 - nameWidth - margin / 2,
                  child: SizedBox(
                    width: nameWidth,
                    height: nameSize,
                    child: getName(
                      context,
                      top2.displayName,
                      top2.formattedScore,
                      nameSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildListView(double labelSize) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = controller.leaderboardData[index];
        return _buildLeaderboardItem(context, item, index, labelSize);
      }, childCount: controller.leaderboardData.length),
    );
  }

  Container _buildMeItem(double labelSize, BuildContext context) {
    final me = controller.personalRank.value;
    return Container(
      height: 60.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary2],
        ),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (me?.position ?? 0) < 100
              ? SizedBox(
                  width: labelSize,
                  height: labelSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AppImages.lMe,
                        width: labelSize,
                        height: labelSize,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            me.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.w,
                                  fontFamily: AppFontFamily.dinPro,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  me?.position.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFontFamily.dinPro,
                    fontSize: 26.w,
                    color: AppColors.white,
                  ),
                ),
          14.hGap,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我 (${me?.user.displayName ?? ''})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.white),
              ),
              Text(
                me?.user.formattedScore ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 12.w,
                  fontFamily: AppFontFamily.dinPro,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 42.w,
            height: 42.w,
            child: CachedImage(
              imageUrl: me?.user.avatarUrl ?? '',
              width: 42.w,
              height: 42.w,
              circle: true,
              borderRadius: BorderRadius.circular(4.w),
              showBorder: true,
              backgroundColor: Theme.of(context).cardColor,
              borderColor: AppColors.white,
            ),
          ),
          6.hGap,
        ],
      ),
    );
  }

  Widget getName(
    BuildContext context,
    String name,
    String points,
    double size,
  ) {
    return SizedBox(
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 10.w,
              fontFamily: AppFontFamily.dinPro,
              color: Colors.white,
            ),
          ),
          Text(
            points,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14.w,
              fontFamily: AppFontFamily.dinPro,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget getLabel(BuildContext context, int rank, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            '${AppImages.imagesPath}l-$rank.png',
            width: size,
            height: size,
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                rank.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardUser item,
    int index,
    double labelSize,
  ) {
    final finalIndex = index + 4;
    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          finalIndex < 100
              ? _buildRankBadge(context, finalIndex, labelSize)
              : Container(
                  margin: EdgeInsets.only(left: 10.w),
                  child: Text(
                    finalIndex.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFontFamily.dinPro,
                      fontSize: 12.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          16.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                4.vGap,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${AppConst.leaderboard.points}: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.w,
                          color: AppColors.white,
                          fontFamily: AppFontFamily.dinPro,
                        ),
                      ),
                      TextSpan(
                        text: '${item.formattedScore} ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.w,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFontFamily.dinPro,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 42.w,
            height: 42.w,
            child: CachedImage(
              imageUrl: item.avatarUrl,
              width: 42.w,
              height: 42.w,
              circle: true,
              borderRadius: BorderRadius.circular(4.w),
              showBorder: true,
              backgroundColor: Theme.of(context).cardColor,
            ),
          ),
          6.hGap,
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank, double labelSize) {
    return SizedBox(
      width: labelSize,
      height: labelSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(AppImages.lOther, width: labelSize, height: labelSize),
          Positioned.fill(
            child: Center(
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    if (controller.leaderboardData.isEmpty) {
      return ViewState.empty;
    }
    return ViewState.content;
  }
}
