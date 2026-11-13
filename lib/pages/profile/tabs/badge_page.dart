import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/badge_detail.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../../../const/app_colors.dart';
import '../../../widgets/badge_widget.dart';
import '../../../widgets/html/html_widget.dart';
import 'badge_controller.dart';

import 'package:linux_do/utils/badge.dart';

class BadgePage extends GetView<BadgeController> {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final viewState = controller.getViewState();
      return StateView(
        state: viewState,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
          itemCount: controller.badgeGroupings.length,
          itemBuilder: (context, index) {
            final grouping = controller.badgeGroupings[index];
            return Obx(() {
              final groupBadges = controller.getFilteredBadges(grouping.id);
              if (groupBadges.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  index == 0
                      ? Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 12.w),
                              child: Text(
                                grouping.getDisplayName(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.only(bottom: 12.w),
                              width: 100.w,
                              child: SlideSwitcher(
                                containerHeight: 20.w,
                                containerWight: 100.w,
                                initialIndex: controller.selectedIndex.value,
                                containerColor: AppColors.transparent,
                                containerBorder: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: .4.w,
                                ),
                                slidersColors: [Theme.of(context).cardColor],
                                isAllContainerTap: true,
                                onSelect: (index) =>
                                    controller.switchBadgeType(index),
                                children: [
                                  Text(
                                    '全部',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: controller.selectedIndex.value == 0
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                    ),
                                  ),
                                  Text(
                                    '已获得',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: controller.selectedIndex.value == 1
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding: EdgeInsets.only(bottom: 12.w),
                          child: Text(
                            grouping.getDisplayName(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.w),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor
                              .withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.w,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: groupBadges.length,
                      itemBuilder: (context, index) {
                        final badge = groupBadges[index];
                        return BadgeCard(badge: badge);
                      },
                    ),
                  ),
                  12.vGap,
                ],
              );
            });
          },
        ),
      );
    });
  }
}

class BadgeCard extends GetView<BadgeController> {
  final BadgeDetail badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final badgeColor = BadgeIconHelper.getColor(badge.name);
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badgeColor),
      child: BadgeWidget(
        badge: badge,
        badgeTypeName: controller.getBadgeTypeName(badge.badgeTypeId),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Color badgeColor) {
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
                    colors: [badgeColor, badgeColor.withValues(alpha: 0.6)],
                  ),
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
                        html: badge.longDescription!,
                        onLinkTap: (url) {},
                      ),
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

  /// 转换K单位
  String formatNumber(int number) {
    if (number >= 1000) {
      double value = number / 1000;
      return '${value.toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
