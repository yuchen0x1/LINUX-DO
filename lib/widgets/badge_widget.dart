import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';

import '../const/app_colors.dart';
import '../const/app_theme.dart';
import '../models/badge_detail.dart';
import '../utils/badge.dart';
import 'cached_image.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeDetail badge;
  final String? badgeTypeName;
  const BadgeWidget({super.key, required this.badge, this.badgeTypeName});

  @override
  Widget build(BuildContext context) {
    return _buildDadge();
  }

  Container _buildDadge() {
    final badgeColor = BadgeIconHelper.getColor(badge.name);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: badge.hasBadge
              ? [
                  badgeColor,
                  badgeColor.withValues(alpha: 0.5),
                ]
              : [
                  badgeColor.withValues(alpha: 0.01),
                  badgeColor.withValues(alpha: 0.01),
                ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w),
          topRight: Radius.circular(46.w),
          bottomLeft: Radius.circular(12.w),
          bottomRight: Radius.circular(12.w),
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: .2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 图标或图片
          if (badge.getImageUrl().isNotEmpty)
            Positioned(
                right: 10.w,
                bottom: 10.w,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CachedImage(
                      imageUrl: badge.getImageUrl(),
                      width: 24.w,
                      height: 24.w,
                      circle: true,
                    ),
                  ),
                ))
          else
            Positioned(
              right: 10.w,
              bottom: 10.w,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  BadgeIconHelper.getIcon(badge.name),
                  size: 18.w,
                  color: Colors.white,
                ),
              ),
            ),

          // 右下角装饰图案
          // Positioned(
          //   right: -30.w,
          //   bottom: -20.w,
          //   child: Container(
          //     width: 90.w,
          //     height: 90.w,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.1),
          //       borderRadius: BorderRadius.circular(60.w),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 2.vGap,
                // Flexible(
                //   child: LayoutBuilder(
                //     builder: (context, constraints) {
                //       return SizedBox(
                //           height: 32.w,
                //           child: HtmlWidget(
                //               html: badge.description, onLinkTap: (url) {}));
                //     },
                //   ),
                // ),
                6.vGap,
                Row(
                  children: [
                    Flexible(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.w),
                            color: AppColors.white.withValues(alpha: .5),
                          ),
                          child: Text(
                            badgeTypeName ?? '',
                            style: TextStyle(
                              fontFamily: AppFontFamily.dinPro,
                              fontSize: 11.sp,
                              color: badge.hasBadge
                                  ? badgeColor
                                  : badgeColor.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        4.vGap,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.w),
                          ),
                          child: Text(
                            '已授予 ${formatNumber(badge.grantCount)} 个',
                            style: TextStyle(
                              fontFamily: AppFontFamily.dinPro,
                              fontSize: 9.sp,
                              color: badge.hasBadge
                                  ? badgeColor
                                  : badgeColor.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )),
                    8.hGap,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
