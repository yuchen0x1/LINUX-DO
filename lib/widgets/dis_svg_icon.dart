import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用于FontAwesome样式SVG图标的组件
class DisSvgIcon extends StatelessWidget {
  /// 图标名称
  final String iconName;

  /// 图标尺寸
  final double? size;

  /// 图标颜色
  final Color? color;

  /// SVG内容，当需要直接使用SVG字符串时提供
  final String? svgContent;

  const DisSvgIcon({
    Key? key,
    this.iconName = '',
    this.size,
    this.color,
    this.svgContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatedSize = size ?? 16.w;
    final themeColor = Theme.of(context).primaryColor;
    final iconColor = color ?? themeColor;

    if (svgContent != null && svgContent!.isNotEmpty) {
      return SvgPicture.string(
        svgContent!,
        width: calculatedSize,
        height: calculatedSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    }

    if (iconName.isNotEmpty) {
      try {
        return SvgPicture.asset(
          'assets/icons/$iconName.svg',
          width: calculatedSize,
          height: calculatedSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      } catch (e) {
        return Icon(
          CupertinoIcons.exclamationmark_triangle,
          size: calculatedSize,
          color: iconColor,
        );
      }
    }

    return SizedBox(width: calculatedSize, height: calculatedSize);
  }

  factory DisSvgIcon.fromString(String svgContent,
      {double? size, Color? color}) {
    return DisSvgIcon(
      svgContent: svgContent,
      size: size,
      color: color,
    );
  }
}
