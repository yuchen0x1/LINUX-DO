import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_footer.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_header.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_poster_avatar.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_tags.dart';
import 'package:linux_do/widgets/avatar_widget.dart';

/// 话题内容组件 - 包含主要内容部分
class TopicContent extends StatelessWidget {
  final Topic topic;
  final String? avatarUrl;
  final String? nickName;
  final String? username;
  final List<String>? avatarUrls;
  final AvatarActions avatarActions;
  final bool? toPersonalPage;

  const TopicContent({
    Key? key,
    required this.topic,
    this.avatarUrl,
    this.nickName,
    this.username,
    this.avatarUrls,
    this.avatarActions = AvatarActions.noAction,
    this.toPersonalPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取布局密度设置
    final fontSizeController = Get.find<FontSizeController>();
    final density = fontSizeController.listDensity.value;

    // 根据密度设置不同的间距
    final spacing = density == ListDensity.compact
        ? 2.0
        : density == ListDensity.normal
        ? 4.0
        : 8.0;

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发帖人头像
            TopicPosterAvatar(
              avatarUrl: avatarUrl ?? '',
              nickName: nickName ?? '',
              username: username ?? '',
              isOriginalPoster: topic.getOriginalPosterId() != 1,
              avatarActions: avatarActions,
              toPersonalPage: toPersonalPage,
            ),

            // 间距
            SizedBox(width: spacing.w),

            // 主要内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题部分
                  TopicHeader(
                    title: topic.title ?? '',
                    isPinned: topic.pinned ?? false,
                    density: density,
                  ),

                  // 标题和摘要之间的间距
                  SizedBox(height: (spacing / 2).w),

                  // 摘要与标签
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 话题摘要
                      // if (topic.excerpt != null && topic.excerpt!.isNotEmpty)
                      //   TopicExcerpt(
                      //     excerpt: topic.excerpt!,
                      //     density: density,
                      //   ),

                      // 话题标签（含分类徽章，对齐网页 /latest 布局）
                      if ((topic.tags != null && topic.tags!.isNotEmpty) ||
                          topic.categoryId != null)
                        Padding(
                          padding: EdgeInsets.only(top: (spacing / 2).w),
                          child: TopicTags(
                            tags: topic.tags ?? [],
                            density: density,
                            categoryId: topic.categoryId,
                          ),
                        ),
                    ],
                  ),

                  // 标签和底部信息之间的间距
                  if ((topic.tags != null && topic.tags!.isNotEmpty) ||
                      topic.categoryId != null)
                    SizedBox(height: (spacing / 2).w),

                  // 底部信息
                  TopicFooter(
                    topic: topic,
                    avatarUrls: avatarUrls ?? [],
                    density: density,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
