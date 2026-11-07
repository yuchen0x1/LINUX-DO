import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/notification.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/state_view.dart';
import '../../../const/app_theme.dart';
import '../../../routes/app_pages.dart';
import 'notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
          state: controller.getViewState(),
          child: DisSmartRefresher(
            controller: controller.refreshController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: controller.onLoadMore,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
              children: _buildGroupedChildren(context),
            ),
          ),
        ));
  }

  List<Widget> _buildGroupedChildren(BuildContext context) {
    final grouped = controller.buildGroupedList();
    if (grouped.isEmpty) return const [];

    final children = <Widget>[];
    for (final (header, items) in grouped) {
      children.add(_GroupHeader(title: header));
      children.addAll(items.map((n) => Padding(
            padding: EdgeInsets.only(bottom: 4.w),
            child: _NotificationItem(notification: n),
          )));
    }
    return children;
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (notification.topicId != null) {
          Get.toNamed(Routes.TOPIC_DETAIL, arguments: notification.topicId,parameters: {
            'postNumber': notification.postNumber.toString(),
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: notification.read
              ? theme.cardColor
              : theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: CachedImage(
                  imageUrl: notification.getAvatarUrl(),
                  width: 34.w,
                  height: 34.w,
                  borderRadius: BorderRadius.circular(4.w),
                  circle: !notification.isWebMaster(),
                )),
            12.hGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        notification.data.displayUsername,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        notification.formattedDate,
                        style: TextStyle(
                          fontSize: 12.w,
                          fontFamily: AppFontFamily.dinPro,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    notification.getTitle(),
                    style: TextStyle(
                      fontSize: 11.w,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;

  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 10.w, 4.w, 4.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          8.hGap,
          Expanded(
            child: Container(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
