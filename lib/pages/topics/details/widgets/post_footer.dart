import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/widgets/dis_button.dart';
import '../topic_detail_controller.dart';

/// 帖子底部组件
class PostFooter extends StatelessWidget {
  const PostFooter({required this.post, required this.controller, Key? key})
    : super(key: key);

  final Post post;
  final TopicDetailController controller;
  @override
  Widget build(BuildContext context) {
    return Get.find<GlobalController>().isAnonymousMode
        ? Text(
            '尊贵的游客,该功能需要登录 🤨',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 10.w,
            ),
          )
        : Row(
            children: [
              if (post.yours != true) ...[
                _LikeButton(post: post, controller: controller),
                16.hGap,
              ],
              _CopyButton(post: post, controller: controller),
              16.hGap,
              _BookmarkButton(post: post, controller: controller),
              16.hGap,
              // 举报按钮
              _ReportButton(post: post, controller: controller),

              // 16.hGap,
              // if (post.canEdit == true) _EditButton(post: post),
              16.hGap,
              if (post.canDelete == true)
                _DeleteButton(post: post, controller: controller),

              //ExpandMenu(controller: controller, post: post),
              const Spacer(),

              _ReplyButton(post: post, controller: controller),

              post.isForumMaster(controller.topic.value?.userId ?? 0)
                  ? 10.hGap
                  : const SizedBox.shrink(),
            ],
          );
  }
}

class _ReportButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const _ReportButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showReportDialog(post),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 14.w,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }

  // 显示举报对话框
  void showReportDialog(Post post) {
    final selectedIndex = 0.obs;
    final customDesc = ''.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)).w,
        ),
        child: Container(
          width: 0.8.sw,
          constraints: BoxConstraints(maxHeight: 0.7.sh),
          padding: const EdgeInsets.all(20).w,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)).w,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题和关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConst.posts.reportTitle,
                      style: TextStyle(
                        fontSize: 18.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, size: 20.w),
                    ),
                  ],
                ),
                SizedBox(
                  height: 320.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 左侧选择器
                      SizedBox(
                        width: 0.65.sw,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8).w,
                          itemCount: AppConst.posts.reasons.length,
                          separatorBuilder: (context, index) => 8.vGap,
                          itemBuilder: (context, index) {
                            return Obx(() {
                              final isSelected = selectedIndex.value == index;
                              return InkWell(
                                onTap: () => selectedIndex.value = index,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ).w,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Get.theme.primaryColor
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ).w,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppConst.posts.reasons[index]['title']!,
                                      style: TextStyle(
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Get.theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                      // 右侧内容
                    ],
                  ),
                ),
                6.vGap,

                Obx(() {
                  final reason = AppConst.posts.reasons[selectedIndex.value];
                  return Container(
                    height: 90.w,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).cardColor,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Obx(() {
                      final isOther =
                          selectedIndex.value ==
                          AppConst.posts.reasons.length - 1;
                      if (isOther) {
                        return TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Theme.of(Get.context!).cardColor,
                            hintText: AppConst.posts.reportHint,
                            hintStyle: TextStyle(
                              fontSize: 12.w,
                              color: Get.theme.hintColor,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(Get.context!).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(Get.context!).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            contentPadding: EdgeInsets.all(8.w),
                          ),
                          style: TextStyle(
                            fontSize: 12.w,
                            color: Get.theme.textTheme.bodyMedium?.color,
                            height: 1.4,
                          ),
                          onChanged: (value) => customDesc.value = value,
                        );
                      }
                      return Text(
                        reason['desc']!,
                        style: TextStyle(
                          fontSize: 13.w,
                          color: Get.theme.hintColor,
                          height: 1.4,
                        ),
                      );
                    }),
                  );
                }),
                20.vGap,
                SizedBox(
                  width: 0.65.sw,
                  child: DisButton(
                    text: AppConst.posts.reportButton,
                    onPressed: () {
                      final reason =
                          AppConst.posts.reasons[selectedIndex.value];
                      final value = reason['value']!;
                      final isOther =
                          selectedIndex.value ==
                          AppConst.posts.reasons.length - 1;
                      final desc = isOther ? customDesc.value : reason['desc']!;
                      controller.reportPost(post, value, desc);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 点赞按钮组件
class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.post, required this.controller, Key? key})
    : super(key: key);

  final Post post;
  final TopicDetailController controller;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.toggleLike(post),
      child: Row(
        children: [
          Obx(
            () => Icon(
              controller.likedPosts[post.postNumber] == true
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart,
              size: 14.w,
              color: controller.likedPosts[post.postNumber] == true
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
            ),
          ),
          4.hGap,
          Obx(
            () => Text(
              '${controller.postScores[post.postNumber] ?? 0}',
              style: TextStyle(
                fontSize: 12.w,
                fontFamily: AppFontFamily.dinPro,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 回复按钮组件
class _ReplyButton extends StatelessWidget {
  final TopicDetailController controller;
  const _ReplyButton({required this.post, required this.controller, Key? key})
    : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        controller.startReply(
          post.postNumber,
          post.cooked,
          post.name?.isEmpty ?? true ? post.username : post.name,
        ),
      },
      child: Row(
        children: [
          Icon(
            CupertinoIcons.reply,
            size: 14.w,
            color: Theme.of(context).hintColor,
          ),
          4.hGap,
          Text(
            '回复',
            style: TextStyle(
              fontSize: 12.w,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 复制按钮组件
class _CopyButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const _CopyButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.copyPost(post),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.square_on_square,
            size: 14.w,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}

/// 书签按钮组件
class _BookmarkButton extends StatelessWidget {
  final TopicDetailController controller;
  final Post post;
  const _BookmarkButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.toggleBookmark(post),
      child: Row(
        children: [
          Obx(
            () => Icon(
              controller.bookmarkedPosts[post.postNumber ?? -1] ?? false
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              size: 14.w,
              color: controller.bookmarkedPosts[post.postNumber ?? -1] ?? false
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 删除按钮组件
class _DeleteButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const _DeleteButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.deletePost(post),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.trash,
            size: 14.w,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}
