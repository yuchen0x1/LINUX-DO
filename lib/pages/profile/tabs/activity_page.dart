import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/user_action.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:linux_do/widgets/state_view.dart';
import '../../../models/category.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/tag.dart';
import 'activity_controller.dart';

class ActivityPage extends GetView<ActivityController> {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => StateView(
        state: controller.getViewState(),
        child: DisSmartRefresher(
          controller: controller.refreshController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: controller.onLoadMore,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
            itemCount: controller.activities.length,
            separatorBuilder: (context, index) => 4.vGap,
            itemBuilder: (context, index) {
              final action = controller.activities[index];
              return _ActivityItem(action: action);
            },
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final UserAction action;

  const _ActivityItem({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Category? category = CategoryManager().getCategory(action.categoryId);
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          if (action.topicId != null) {
            Get.toNamed(
              Routes.TOPIC_DETAIL,
              arguments: action.topicId,
              parameters: {'postNumber': action.postNumber.toString()},
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              Row(
                children: [
                  // 头像
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primaryColor),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: CachedImage(
                      imageUrl: action.getAvatarUrl(),
                      width: 40.w,
                      circle: !action.isWebMaster(),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                  12.hGap,
                  // 用户信息和标签
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        4.vGap,
                        Row(
                          children: [
                            category?.name.isNotEmpty ?? false
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.primaryColor,
                                        width: .5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.3.w,
                                    ),
                                    child: Row(
                                      children: [
                                        CachedImage(
                                          imageUrl: darkTheme
                                              ? category?.logoDark?.imageUrl
                                              : category?.logo?.imageUrl,
                                          width: 10.w,
                                        ),
                                        3.hGap,
                                        Text(
                                          category?.name ?? '',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const Spacer(),
                            Text(
                              action.formattedDate,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: AppFontFamily.dinPro,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (action.excerpt?.isNotEmpty ?? false) ...[
                12.vGap,
                Html(
                  data: action.excerpt,
                  style: {
                    "body": Style(
                      fontSize: FontSize(10.sp),
                      color: theme.textTheme.bodyMedium?.color,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      maxLines: 3,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    "img": Style(width: Width(16.w), height: Height(16.w)),
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
