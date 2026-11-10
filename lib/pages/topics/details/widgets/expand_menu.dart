import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_popup.dart';

class ExpandMenu extends StatelessWidget {
  final TopicDetailController controller;
  final Post post;
  const ExpandMenu({super.key, required this.controller, required this.post});

  @override
  Widget build(BuildContext context) {
    return _buildMoreButton(context);
  }

  CustomPopup _buildMoreButton(BuildContext context) {
    return CustomPopup(
      backgroundColor: Theme.of(context).cardColor,
      arrowColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(14).w,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.copyPost(post),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CopyButton(post: post, controller: controller),
                4.hGap,
                Text(
                  '复制内容',
                  style: TextStyle(
                    fontSize: 13.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          8.vGap,
          GestureDetector(
            onTap: () => controller.toggleBookmark(post),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BookmarkButton(post: post, controller: controller),
                4.hGap,
                Text(
                  '添加书签',
                  style: TextStyle(
                    fontSize: 13.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          8.vGap,
          GestureDetector(
            onTap: () => controller.reportPost(post, '举报', ''),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ReportButton(post: post, controller: controller),
                4.hGap,
                Text(
                  '举报',
                  style: TextStyle(
                    fontSize: 13.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          if (post.canEdit != true) ...[
            8.vGap,
            GestureDetector(
              onTap: () => controller.editPost(post),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _EditButton(post: post, controller: controller),
                  4.hGap,
                  Text(
                    '编辑',
                    style: TextStyle(
                      fontSize: 13.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (post.canDelete != true) ...[
            8.vGap,
            GestureDetector(
              onTap: () => controller.deletePost(post),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DeleteButton(post: post, controller: controller),
                  4.hGap,
                  Text(
                    '删除',
                    style: TextStyle(
                      fontSize: 13.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      child: Icon(
        CupertinoIcons.ellipsis_circle,
        size: 18.w,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}

/// 编辑话题按钮组件
class _EditButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;

  const _EditButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.pencil_circle,
      size: 22.w,
      color: Theme.of(context).hintColor,
    );
  }
}

class _ReportButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const _ReportButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.exclamationmark_circle_fill,
      size: 22.w,
      color: Theme.of(context).hintColor,
    );
  }

  // 显示举报对话框
  void showReportDialog(Post post, BuildContext context) {
    final selectedIndex = 0.obs;
    final customDesc = ''.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)).w,
        ),
        child: Container(
          width: 0.8.sw,
          constraints: BoxConstraints(maxHeight: 0.7.sh),
          padding: const EdgeInsets.all(20).w,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      color: Theme.of(context).cardColor,
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
                            fillColor: Theme.of(context).cardColor,
                            hintText: AppConst.posts.reportHint,
                            hintStyle: TextStyle(
                              fontSize: 12.w,
                              color: Get.theme.hintColor,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
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

/// 复制按钮组件
class _CopyButton extends StatelessWidget {
  final Post post;
  final TopicDetailController controller;
  const _CopyButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.doc_circle,
      size: 22.w,
      color: Theme.of(context).hintColor,
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
    return Obx(
      () => Icon(
        controller.bookmarkedPosts[post.postNumber ?? -1] ?? false
            ? CupertinoIcons.book_circle_fill
            : CupertinoIcons.book_circle,
        size: 22.w,
        color: controller.bookmarkedPosts[post.postNumber ?? -1] ?? false
            ? Theme.of(context).primaryColor
            : Theme.of(context).hintColor,
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
            CupertinoIcons.trash_circle_fill,
            size: 22.w,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}
