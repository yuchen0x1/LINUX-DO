import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/utils/expand/string_expand.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/emoji_text.dart';

class SimplifiedItem extends StatelessWidget with Concatenated {
  final Topic topic;
  final String? avatarUrl;
  final String? username;
  final String? nickName;
  final bool isOriginalPoster;
  final AvatarActions avatarActions;
  final bool toPersonalPage;
  final VoidCallback? onTap;

  const SimplifiedItem({
    super.key,
    required this.topic,
    this.avatarUrl,
    this.username,
    this.nickName,
    this.isOriginalPoster = false,
    this.avatarActions = AvatarActions.noAction,
    this.toPersonalPage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.w),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4).w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: AvatarWidget(
                      avatarUrl: avatarUrl ?? '',
                      size: 28.w,
                      circle: topic.getOriginalPosterId() != 1,
                      borderRadius: 4.w,
                      backgroundColor: Theme.of(context).cardColor,
                      borderColor: Theme.of(context).primaryColor,
                      username: username ?? '',
                      avatarActions: avatarActions,
                      toPersonalPage: toPersonalPage,
                    ),
                  ),
                  8.hGap,
                  // 昵称
                  SizedBox(
                    child: Text(
                      nickName != null && nickName!.isNotEmpty
                          ? nickName!
                          : username ?? '',
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: isOriginalPoster
                            ? FontWeight.w400
                            : FontWeight.w500,
                        color: topic.getOriginalPosterId() != 1
                            ? AppColors.logoColor3
                            : AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    CupertinoIcons.chat_bubble,
                    size: 12.w,
                    color: Colors.grey,
                  ),
                  2.hGap,
                  Text(
                    '${topic.postsCount}',
                    style: TextStyle(
                      fontSize: 13.w,
                      color: Colors.grey,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                  8.hGap,

                  Text(
                    topic.createdAt?.toDateTime()?.friendlyDateTime ?? '',
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Colors.grey,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                ],
              ),
              8.vGap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (topic.pinned ?? false)
                              Padding(
                                padding: EdgeInsets.only(right: 3.w),
                                child: Icon(
                                  CupertinoIcons.pin_fill,
                                  size: 10.w,
                                  color: AppColors.warning,
                                ),
                              ),
                            Expanded(
                              child: EmojiText(
                                '${topic.title} ',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.w,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFontFamily.dinPro,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
