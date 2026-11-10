import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';
import 'package:linux_do/pages/topics/details/widgets/post_content.dart';
import 'package:linux_do/pages/topics/details/widgets/post_header.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/expandable.dart';
import 'package:linux_do/widgets/html/html_widget.dart';

class ReplayList extends StatelessWidget {
  final TopicDetailController controller;
  final Post post;
  const ReplayList({super.key, required this.controller, required this.post});

  @override
  Widget build(BuildContext context) {
    // Use PageStorage with custom bucket to prevent scroll position restoration issues
    return PageStorage(
      bucket: CustomPageStorageBucket(),
      child: ExpandableNotifier(
        child: ScrollOnExpand(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4).w,
            ),
            margin: const EdgeInsets.all(0),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Obx(() {
                  // 获取回复加载状态和数据
                  final isLoading = controller.loadingReplies.contains(
                    post.id ?? 0,
                  );
                  final replies = controller.postReplies[post.id ?? 0] ?? [];

                  return ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToExpand: true,
                      tapBodyToCollapse: true,
                      hasIcon: false,
                    ),
                    onExpanded: (expanded) {
                      if (expanded &&
                          post.replyCount != null &&
                          post.replyCount! > 0) {
                        if (!isLoading && replies.isEmpty) {
                          controller.loadReplies(post.id ?? 0);
                        }
                      }
                    },
                    header: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ).w,
                        child: Row(
                          children: [
                            const ExpandableIcon(
                              theme: ExpandableThemeData(
                                expandIcon:
                                    CupertinoIcons.arrow_down_circle_fill,
                                collapseIcon:
                                    CupertinoIcons.arrow_up_circle_fill,
                                iconColor: Colors.white,
                                iconSize: 18,
                                iconRotationAngle: pi / 2,
                                iconPadding: EdgeInsets.only(right: 5),
                                hasIcon: false,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${post.replyCount} 条回复",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.w,
                                  fontFamily: AppFontFamily.dinPro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    collapsed: Container(),
                    expanded: isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16).w,
                              child: DisRefreshLoading(fontSize: 12),
                            ),
                          )
                        : _buildReplyList(context, replies),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建回复列表
  Widget _buildReplyList(BuildContext context, List<Post> replies) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
          width: 1,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(4).w,
          bottomRight: const Radius.circular(4).w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: replies
            .map((reply) => _buildReplyItem(context, reply))
            .toList(),
      ),
    );
  }

  // 构建单个回复项
  Widget _buildReplyItem(BuildContext context, Post reply) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          6.vGap,
          PostHeader(post: reply, title: controller.topic.value?.title),
          2.vGap,
          PostContent(post: reply, isReply: true, controller: controller),

          // 跳转到该贴
          GestureDetector(
            onTap: () {
              controller.jumpToPost(reply.postNumber ?? 0);
            },
            child: Row(
              children: [
                const Spacer(),
                Icon(
                  CupertinoIcons.arrow_up_arrow_down_circle_fill,
                  size: 16.w,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ),
                2.hGap,
                Text(
                  "跳转帖子",
                  style: TextStyle(
                    fontSize: 11.w,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
              ],
            ),
          ),
          4.vGap,
          Divider(height: 1.h, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
