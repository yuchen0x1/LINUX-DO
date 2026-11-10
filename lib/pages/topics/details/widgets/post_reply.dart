import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';

class PostReply extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const PostReply({super.key, required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4).w,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12).w,
            bottomRight: const Radius.circular(12).w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.arrowshape_turn_up_left_fill,
              size: 12.w,
              color: Theme.of(context).primaryColor,
            ),
            4.hGap,
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '回复 ',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: '#${post.replyToPostNumber} ',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: () {
                      // 安全地获取引用的帖子
                      final posts = controller.topic.value?.postStream?.posts;
                      if (posts == null || posts.isEmpty) {
                        return '(加载中...)';
                      }

                      final replyToPost = posts.firstWhereOrNull(
                        (p) => p.postNumber == post.replyToPostNumber,
                      );

                      if (replyToPost == null) {
                        return '(加载中...)';
                      }

                      return '(${replyToPost.name?.isNotEmpty == true ? replyToPost.name : replyToPost.username ?? "未知用户"})';
                    }(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
