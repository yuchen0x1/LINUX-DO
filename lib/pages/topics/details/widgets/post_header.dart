import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';

import '../../../../models/topic_detail.dart';
import '../../../../widgets/avatar_widget.dart';

/// 帖子头部组件
class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.post,
    this.title,
    Key? key,
  }) : super(key: key);

  final Post post;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UserAvatar(post: post, title: title),
        8.hGap,
        _UserInfo(post: post),
        const Spacer(),
        _PostTime(post: post),
      ],
    );
  }
}

/// 用户头像组件
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.post,
    this.title,
    Key? key,
  }) : super(key: key);

  final Post post;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      avatarUrl: post.avatarUrl,
      size: 32.w,
      circle: !post.isWebMaster(),
      borderRadius: 4.w,
      borderColor: Theme.of(context).primaryColor,
      username: post.username ?? '',
      post: post,
      title: title,
      avatarActions: AvatarActions.openCard,
      toPersonalPage: false,
    );
  }
}

/// 用户信息组件
class _UserInfo extends StatelessWidget {
  const _UserInfo({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final hasUserTitle = post.userTitle != null && post.userTitle!.isNotEmpty;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  post.name?.isNotEmpty == true
                      ? post.name!
                      : post.username ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.w,
                    fontFamily: AppFontFamily.dinPro,
                    fontWeight:
                        !post.isWebMaster() ? FontWeight.w500 : FontWeight.bold,
                    color: !post.isWebMaster()
                        ? Theme.of(context).textTheme.titleLarge?.color
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (hasUserTitle) ...[
                5.hGap,
                Text(
                  post.userTitle!,
                  style: TextStyle(
                    fontSize: 9.w,
                    fontFamily: AppFontFamily.dinPro,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  post.username ?? '',
                  style: TextStyle(
                    fontSize: 11.w,
                    fontFamily: AppFontFamily.dinPro,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (post.isWebMaster()) ...[
                5.hGap,
                Icon(
                  CupertinoIcons.shield_lefthalf_fill,
                  size: 12.w,
                  color: Theme.of(context).primaryColor,
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}

/// 发帖时间组件
class _PostTime extends StatelessWidget {
  const _PostTime({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Text(
      _getRelativeTime(),
      style: TextStyle(
        fontSize: 10.w,
        fontFamily: AppFontFamily.dinPro,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  String _getRelativeTime() {
    final time = post.createdAt;
    if (time == null) return '';
    return DateTime.parse(time).friendlyDateTime;
  }
}
