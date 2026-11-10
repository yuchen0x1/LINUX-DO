import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/widgets/emoji_text.dart';

/// 话题标题组件
class TopicHeader extends StatelessWidget {
  final String title;
  final bool isPinned;
  final ListDensity? density;

  const TopicHeader({
    Key? key,
    required this.title,
    required this.isPinned,
    this.density,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据密度设置不同的字体大小
    final fontSize = density == ListDensity.compact
        ? 12.0
        : density == ListDensity.normal
            ? 14.0
            : 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 置顶标签
        if (isPinned)
          Container(
            margin: const EdgeInsets.only(right: 8).w,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2).w,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4).w,
            ),
            child: Text(
              '置顶',
              style: TextStyle(
                fontSize: 10.w,
                color: AppColors.white,
              ),
            ),
          ),

        // 标题
        Expanded(
          child: EmojiText(
            title,
            style: TextStyle(
              fontSize: fontSize.w,
              fontFamily: AppFontFamily.dinPro,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
