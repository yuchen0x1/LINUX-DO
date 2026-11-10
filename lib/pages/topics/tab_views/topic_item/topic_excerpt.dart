import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';

/// 话题摘要组件
class TopicExcerpt extends StatelessWidget {
  final String excerpt;
  final ListDensity? density;

  const TopicExcerpt({Key? key, required this.excerpt, this.density})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据密度设置不同的字体大小和边距
    final fontSize = density == ListDensity.compact
        ? 10.0
        : density == ListDensity.normal
        ? 13.0
        : 14.0;

    final topPadding = density == ListDensity.compact
        ? 4.0
        : density == ListDensity.normal
        ? 8.0
        : 12.0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding).w,
      child: Text(
        excerpt,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize.w,
          fontFamily: AppFontFamily.dinPro,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          height: 1.6,
        ),
      ),
    );
  }
}
