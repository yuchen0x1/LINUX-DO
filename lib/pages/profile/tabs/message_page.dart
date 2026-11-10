import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/message.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/state_view.dart';
import '../../../routes/app_pages.dart';
import 'message_controller.dart';

class MessagePage extends GetView<MessageController> {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
          state: controller.getViewState(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return _MessageCard(message: message);
            },
          ),
        ));
  }
}

class _MessageCard extends StatelessWidget {
  final Topic message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.w),
        child: InkWell(
          onTap: () {
            if (message.id != null) {
              Get.toNamed(Routes.TOPIC_DETAIL, arguments: message.id);
            }
          },
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.vGap,
                      Row(
                        children: [
                          _buildStatusChip(
                            context,
                            (message.unreadPosts ?? 0) > 0
                                ? '${message.unreadPosts}条新消息'
                                : '无新消息',
                            (message.unreadPosts ?? 0) > 0
                                ? theme.primaryColor
                                : theme.disabledColor,
                          ),
                          4.hGap,
                          _buildStatusChip(
                            context,
                            '${message.replyCount}条回复',
                            theme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      6.vGap,
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock_fill,
                            size: 14.w,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          4.hGap,
                          Text(
                            _formatDate(message.lastPostedAt ?? ''),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: AppFontFamily.dinPro,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const Spacer(),
                          if (message.closed == true)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.w),
                              ),
                              child: Text(
                                '已关闭',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                16.hGap,
                _buildAvatar(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: CachedImage(
            imageUrl: message.avatarUrl,
            width: 40.w,
            circle: !message.isWebMaster(),
            borderRadius: BorderRadius.circular(4.w),
          ),
        ),
        if ((message.unreadPosts ?? 0) > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) {
      return '未知时间';
    }
    final date = DateTime.parse(dateStr);
    return date.friendlyDateTime;
  }
}
