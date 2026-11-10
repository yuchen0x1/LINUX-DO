import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/avatar_widget.dart';

import '../topic_detail_controller.dart';

const String pinnedGloballyEnabled = 'pinned_globally.enabled';

/// 帖子内容组件
class PostContentAction extends StatelessWidget {
  final TopicDetailController controller;
  final String? title;
  const PostContentAction({
    required this.post,
    this.isReply = false,
    required this.controller,
    this.title,
    Key? key,
  }) : super(key: key);

  final Post post;
  final bool isReply;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context),
        10.hGap,
        AvatarWidget(
          avatarUrl: post.avatarUrl,
          size: 22.w,
          circle: !post.isWebMaster(),
          borderRadius: 4.w,
          borderColor: Theme.of(context).primaryColor,
          username: post.username ?? '',
          post: post,
          title: title,
          avatarActions: AvatarActions.openCard,
          toPersonalPage: false,
        ),
        6.hGap,
        _buildContent(context),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    final actionType = post.actionCode;
    switch (actionType) {
      case pinnedGloballyEnabled:
        return Icon(
          CupertinoIcons.pin_fill,
          size: 16.w,
          color: Theme.of(context).primaryColor,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildContent(BuildContext context) {
    final actionType = post.actionCode;
    final updateAt = DateTime.parse(post.updatedAt ?? '');
    switch (actionType) {
      case pinnedGloballyEnabled:
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: updateAt.format('yyyy-MM-dd'),
                style: TextStyle(
                  fontSize: 12.w,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextSpan(
                text: ' 全站置顶',
                style: TextStyle(
                  fontSize: 12.w,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
