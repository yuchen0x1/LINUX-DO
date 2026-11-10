import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/widgets/html/html_widget.dart';

import '../topic_detail_controller.dart';

/// 帖子内容组件
class PostContent extends StatelessWidget {
  final TopicDetailController controller;
  const PostContent({
    required this.post,
    this.isReply = false,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final Post post;
  final bool isReply;
  @override
  Widget build(BuildContext context) {
    if (post.cooked == null) {
      return const SizedBox();
    }

    return RepaintBoundary(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(2).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // if (isReply)
                //   _ReplyQuote(post: node.post),
                _PostBody(post: post, isReply: isReply, controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 帖子主体内容组件
class _PostBody extends StatelessWidget {
  const _PostBody({
    required this.post,
    this.isReply = false,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final Post post;
  final bool isReply;
  final TopicDetailController controller;
  @override
  Widget build(BuildContext context) {
    if (post.polls != null && post.polls!.isNotEmpty) {
      for (var poll in post.polls!) {
        if (Get.isRegistered<PollController>(tag: 'poll_${poll.id}')) {
          continue;
        }
        poll.postId = post.id;
        poll.vote = post.polls_votes?.votes[poll.name ?? 'poll'];
        Get.put(PollController(poll), tag: 'poll_${poll.id}');
      }
    }
    return HtmlWidget(
      html: post.cooked ?? '',
      fontSize: isReply ? controller.replyFontSize : controller.fontSize,
      onLinkTap: (url) {
        controller.launchUrl(url);
      },
      polls: post.polls,
      topicDetailController: controller,
    );
  }
}
