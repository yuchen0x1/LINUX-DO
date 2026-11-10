import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/widgets/cached_image.dart';

/// 用户头像组组件
/// 显示多个用户头像，并在末尾显示剩余头像数量
class UserAvatarGroup extends StatelessWidget {
  /// 用户头像URL列表
  final List<String> avatarUrls;

  /// 最大显示的头像数量
  final int maxDisplayed;

  /// 头像大小
  final double avatarSize;

  /// 头像间的重叠量
  final double overlap;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 圆角大小
  final double borderRadius;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  const UserAvatarGroup({
    super.key,
    required this.avatarUrls,
    this.maxDisplayed = 5,
    this.avatarSize = 22,
    this.overlap = 8,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = .5,
    this.borderRadius = 12,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? Colors.transparent;
    final border = borderColor != null
        ? Border.all(color: borderColor!, width: borderWidth)
        : null;

    // 计算需要显示的头像数量
    final displayCount =
        avatarUrls.length > maxDisplayed ? maxDisplayed : avatarUrls.length;

    // 计算组件宽度
    final double containerWidth = displayCount > 0
        ? avatarSize +
            (displayCount - 1) * (avatarSize - overlap) +
            (avatarUrls.length > maxDisplayed ? avatarSize : 0) +
            6.w
        : 0;

    return Container(
      width: containerWidth,
      height: avatarSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: displayCount > 0
                ? avatarSize + (displayCount - 1) * (avatarSize - overlap)
                : 0,
            height: avatarSize,
            child: Stack(
              children: List.generate(displayCount, (index) {
                return Positioned(
                  left: index * (avatarSize - overlap),
                  child: _buildAvatar(avatarUrls[index], context),
                );
              }),
            ),
          ),

          // 如果有更多头像，显示"+X"指示器
          if (avatarUrls.length > maxDisplayed)
            Container(
              width: avatarSize - 1.w,
              height: avatarSize - 1.w,
              margin: EdgeInsets.only(left: 2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor, width: 0.5),
              ),
              child: Center(
                child: Text(
                  '+${avatarUrls.length - maxDisplayed}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 6.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url, BuildContext context) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).cardColor,
          width: 1.2.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: CachedImage(
          imageUrl: url,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
