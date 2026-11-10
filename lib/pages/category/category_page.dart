import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_sizes.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/category.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'category_list_view.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = '';
    String? englishTitle;
    String? logoUrl;
    String? slug;
    Color? color;
    Color? textColor;
    if (Get.arguments is Category) {
      title = Get.arguments.name;
      englishTitle = Get.arguments.englishName;
      logoUrl = Theme.of(context).brightness == Brightness.dark
          ? Get.arguments.logoDark?.imageUrl
          : Get.arguments.logo?.imageUrl;
      slug = Get.arguments.slug;
      color = Get.arguments.color != null
          ? Color(int.parse(Get.arguments.color!)).withValues(alpha: 0.1)
          : Theme.of(context).primaryColor.withValues(alpha: 0.1);
      textColor = Get.arguments.color != null
          ? Color(int.parse(Get.arguments.color!))
          : Theme.of(context).primaryColor;
    } else if (Get.arguments is Map<String, dynamic>) {
      title = Get.arguments['tag'] ?? 'Tag';
      englishTitle = null;
      logoUrl = null;
      slug = null;
      color = null;
      textColor = null;
    }
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(CupertinoIcons.chevron_left_circle),
            ),
            title: Row(
              children: [
                if (logoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6).w,
                    child: CachedImage(
                      imageUrl: logoUrl,
                      width: 30.w,
                      height: 30.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  10.hGap,
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppSizes.fontNormal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    englishTitle != null
                        ? Text(
                            englishTitle,
                            style: TextStyle(
                              fontSize: AppSizes.fontTiny,
                              fontFamily: AppFontFamily.dinPro,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              if (slug != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6).w,
                  ),
                  child: Text(
                    slug,
                    style: TextStyle(
                      fontSize: 8.w,
                      fontFamily: AppFontFamily.dinPro,
                      color: textColor,
                    ),
                  ),
                ),
              16.hGap,
            ],
          ),
          body: const CategoryListView(),
        ),
      ],
    );
  }
}
