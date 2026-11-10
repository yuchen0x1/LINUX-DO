import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/widgets/avatar_widget.dart';

/// 发帖人头像组件
class TopicPosterAvatar extends StatelessWidget {
  final String avatarUrl;
  final String nickName;
  final String username;
  final bool isOriginalPoster;
  final AvatarActions avatarActions;
  final bool? toPersonalPage;
  const TopicPosterAvatar({
    Key? key,
    required this.avatarUrl,
    required this.nickName,
    required this.username,
    this.isOriginalPoster = false,
    this.avatarActions = AvatarActions.noAction,
    this.toPersonalPage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 头像
          SizedBox(
            width: 42.w,
            height: 42.w,
            child: AvatarWidget(
              avatarUrl: avatarUrl,
              size: 42.w,
              circle: isOriginalPoster,
              borderRadius: 4.w,
              backgroundColor: Theme.of(context).cardColor,
              borderColor: Theme.of(context).primaryColor,
              username: username,
              avatarActions: avatarActions,
              toPersonalPage: toPersonalPage,
            ),
          ),
          SizedBox(height: 8.w),
          // 昵称
          SizedBox(
            width: 42.w,
            child: Text(
              (nickName).length > 8
                  ? '${(nickName).substring(0, 8)}...'
                  : (nickName),
              style: TextStyle(
                fontSize: 9.w,
                fontWeight: isOriginalPoster
                    ? FontWeight.w400
                    : FontWeight.w500,
                color: isOriginalPoster
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : AppColors.secondary2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
