import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/utils/expand/string_expand.dart';
import '../models/category_data.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final Map<int, int> stats;
  final bool isSelected;
  final Function(Category category, int? level) onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.stats,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = category.color?.fromHex() ?? Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主分类（总数）
        _buildCategoryItem(
          icon: category.getLogoUrl(),
          textColor: categoryColor,
          title: category.name ?? '',
          count: category.topicCount ?? 0,
          description: category.description,
          level: null,
          context: context,
        ),
        8.vGap,
        // Lv1
        _buildCategoryItem(
          icon: category.getLogoUrl(),
          textColor: categoryColor,
          title: category.name ?? '',
          count: stats[1] ?? 0,
          description: '此处为 1级用户 可见空间。',
          level: 1,
          context: context,
        ),
        8.vGap,
        // Lv2
        _buildCategoryItem(
          icon: category.getLogoUrl(),
          textColor: categoryColor,
          title: category.name ?? '',
          count: stats[2] ?? 0,
          description: '此处为 2级用户 可见空间。',
          level: 2,
          context: context,
        ),
        8.vGap,
        // Lv3
        _buildCategoryItem(
          icon: category.getLogoUrl(),
          textColor: categoryColor,
          title: category.name ?? '',
          count: stats[3] ?? 0,
          description: '此处为 3级用户 可见空间。',
          level: 3,
          context: context,
        ),
        8.vGap
      ],
    );
  }

  Widget _buildCategoryItem({
    required String icon,
    required Color textColor,
    required String title,
    required int count,
    String? description,
    int? level,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () => onTap(category, level),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4.w),
          // 浅色阴影
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Container(
                //   padding: const EdgeInsets.all(0),
                //   decoration: BoxDecoration(
                //     color: AppColors.white,
                //     borderRadius: BorderRadius.circular(4.w),
                //   ),
                //   child: CachedImage(
                //     imageUrl: icon,
                //     width: 24.w,
                //     height: 24.w,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // 8.hGap,
                // Icon(Icons.lock_outline, size: 14.w, color: textColor),
                // 4.hGap,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.w,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                4.hGap,
                if (level != null)
                  Text(
                    'Lv$level × $count',
                    style: TextStyle(
                      fontSize: 10.w,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.grey[300]!,
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (description != null)
              Padding(
                padding: EdgeInsets.only(top: 4.w),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11.w,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
