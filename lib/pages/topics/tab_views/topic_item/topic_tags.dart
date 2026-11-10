import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/utils/expand/string_expand.dart';
import 'package:linux_do/utils/tag.dart';

/// 话题标签组件（含分类徽章，对齐网页 /latest 的分类+标签行）
class TopicTags extends StatelessWidget {
  final List<String> tags;
  final ListDensity? density;
  final int? categoryId;

  const TopicTags({Key? key, required this.tags, this.density, this.categoryId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据密度设置不同的字体大小和间距
    final fontSize = density == ListDensity.compact
        ? 8.0
        : density == ListDensity.normal
        ? 9.0
        : 10.0;

    final margin = density == ListDensity.compact
        ? 4.0
        : density == ListDensity.normal
        ? 6.0
        : 8.0;

    final padding = density == ListDensity.compact
        ? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0)
        : density == ListDensity.normal
        ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0);

    return Padding(
      padding: const EdgeInsets.only(top: 4).w,
      child: Wrap(
        spacing: margin.w,
        runSpacing: (margin / 2).w,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 分类徽章（对齐网页：分类色块 + 分类名）
          _CategoryBadge(categoryId: categoryId, fontSize: fontSize),
          ...tags.map((tag) {
            final color = Tag.getTagColors(tag);
            return Container(
              padding: padding.w,
              decoration: BoxDecoration(
                color: color.backgroundColor,
                borderRadius: BorderRadius.circular(4).w,
              ),
              child: Text(
                tag,
                style: TextStyle(fontSize: fontSize.w, color: color.textColor),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// 分类徽章：分类色块 + 分类名（数据来自本地 categories.json 缓存）
class _CategoryBadge extends StatelessWidget {
  final int? categoryId;
  final double fontSize;

  const _CategoryBadge({required this.categoryId, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    CategoryManager().initialize();
    final category = CategoryManager().getCategory(categoryId);
    if (category == null) return const SizedBox.shrink();

    final color = category.color?.fromHex() ?? Theme.of(context).primaryColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: fontSize + 3,
          height: fontSize + 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2).w,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          category.name,
          style: TextStyle(
            fontSize: fontSize.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
