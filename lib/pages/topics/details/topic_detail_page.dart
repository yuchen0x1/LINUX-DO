import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/pages/topics/details/widgets/more_menu.dart';
import 'package:linux_do/pages/topics/details/widgets/post_content_action.dart';
import 'package:linux_do/pages/topics/details/widgets/post_reply.dart';
import 'package:linux_do/pages/topics/details/widgets/replay_list.dart';
import 'package:linux_do/utils/expand/num_expand.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_emoji_picker.dart';
import 'package:linux_do/widgets/emoji_text.dart';
import 'package:linux_do/widgets/owner_banner.dart';
import 'package:linux_do/widgets/state_view.dart';
import '../../../const/app_const.dart';
import '../../../const/app_spacing.dart';
import '../../../const/app_theme.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/dis_loading.dart';
import 'topic_detail_controller.dart';
import '../../../models/topic_detail.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'widgets/page_heder.dart';
import 'widgets/post_content.dart';
import 'widgets/post_header.dart';
import 'widgets/post_footer.dart';
import 'widgets/posts_selector.dart';

class TopicDetailPage extends GetView<TopicDetailController> with ToastMixin {
  const TopicDetailPage({super.key});

  // @override
  // TopicDetailController get controller {
  //   var topicId = Get.arguments as int;
  //   return Get.find<TopicDetailController>(tag: 'topic_$topicId');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Obx(() {
            final topic = controller.topic.value;
            return StateView(
              state: _getViewState(),
              errorMessage: controller.errorMessage.value,
              onRetry: controller.fetchTopicDetail,
              shimmerView: const ShimmerDetails(),
              child: topic == null
                  ? const SizedBox()
                  : _buildContent(context, topic),
            );
          }),
          // 新增楼层选择器
          Obx(() {
            final postsCount = controller.topic.value?.postsCount ?? 0;
            // 如果帖子数量小于50或者正在回复
            if (postsCount < 50) {
              return const SizedBox();
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: controller.isReplying.value ? -50.w : 16.w,
              bottom: MediaQuery.of(context).padding.bottom + 16.w,
              child: PostsSelector(
                  postsCount: postsCount,
                  currentIndex: controller.currentPostIndex.value,
                  controller: controller,
                  onIndexChanged: (index) {
                    if (!controller.isLoading.value) {
                      controller.scrollToPost(index);
                    }
                  }),
            );
          }),
        ],
      ),
    );
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    return ViewState.content;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.chevron_left_circle,
          size: 24.w,
        ),
        onPressed: () => Get.back(),
      ),
      title: _buildHeader(context),
      actions: [
        Obx(() => AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: controller.isBlinking.value ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.updateSuccess.value
                      ? Colors.green.withValues(
                          alpha: controller.isBlinking.value ? 0.3 : 1.0)
                      : Colors.red.withValues(
                          alpha: controller.isBlinking.value ? 0.3 : 1.0),
                ),
              ),
            )),
        Get.find<GlobalController>().isAnonymousMode
            ? const SizedBox.shrink()
            : MoreMenu(controller: controller),
        Get.find<GlobalController>().isAnonymousMode
            ? const SizedBox.shrink()
            : IconButton(
                icon: Obx(() => Icon(
                      controller.isFooderVisible.value
                          ? CupertinoIcons.chevron_up_circle
                          : CupertinoIcons.chevron_down_circle,
                    )),
                onPressed: () {
                  controller.isFooderVisible.toggle();
                },
              )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PageHeader(controller: controller);
  }

  Widget _buildContent(BuildContext context, TopicDetail topic) {
    return Stack(
      children: [
        Positioned.fill(
          bottom: controller.isReplying.value ? 380.w : 0,
          child: Obx(() => ScrollablePositionedList.builder(
                padding: const EdgeInsets.only(bottom: 20).w,
                key: PageStorageKey('topic_detail_${topic.id}'),
                itemScrollController: controller.itemScrollController,
                itemPositionsListener: controller.itemPositionsListener,
                initialScrollIndex: controller.initialScrollIndex.value,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.replyTree.length + 2,
                minCacheExtent: 300,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                itemBuilder: (context, index) {
                  // 头部加载指示器
                  if (index == 0) {
                    return Obx(() => controller.hasPrevious.value &&
                            !controller.isLoading.value
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10).w,
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 底部加载指示器
                  if (index == controller.replyTree.length + 1) {
                    return Obx(() => controller.hasMore.value &&
                            !controller.isLoading.value
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10).w,
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 帖子内容
                  if (controller.isLoading.value ||
                      index - 1 >= controller.replyTree.length) {
                    return const SizedBox();
                  }

                  final node = controller.replyTree[index - 1];
                  return _buildPostItem(context, node);
                },
              )),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          top: controller.isFooderVisible.value ? 0.w : -200.w,
          left: 0,
          right: 0,
          child: Container(
            child: _buildExpand(context, topic),
          ),
        ),
        // 回复输入框
        Obx(() {
          final isReplying = controller.isReplying.value;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: isReplying ? 0 : -380.w,
            left: 0,
            right: 0,
            child: _buildReplyInput(context, topic),
          );
        }),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, PostNode node) {
    final isReply = node.post.replyToPostNumber != null;
    final barWidth = 8.w;

    return GetBuilder<TopicDetailController>(
      id: 'post_${node.post.postNumber}',
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)).w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)).w,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: isReply ? 12.w + barWidth : 12.w,
                      right: isReply ? 12.w + barWidth : 12.w,
                      top: isReply ? 24.w : 12.w,
                      bottom: 12.w,
                    ),
                    child: buildPostContent(node.post, controller, context),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4)
                          .w,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(12).w,
                          bottomLeft: const Radius.circular(12).w,
                        ),
                      ),
                      child: Text(
                        '#${node.post.postNumber}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10.w,
                          fontFamily: AppFontFamily.dinPro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  isReply
                      ? Positioned(
                          top: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              if (node.post.replyToPostNumber != null) {
                                controller.scrollToPost(
                                    node.post.replyToPostNumber! - 1);
                              }
                            },
                            child: PostReply(
                                post: node.post, controller: controller),
                          ),
                        )
                      : const SizedBox(),
                  node.post.isForumMaster(
                              controller.topic.value?.userId ?? 0) &&
                          node.post.postType == 1
                      ? Positioned(
                          bottom: 14.w,
                          right: 14.w,
                          child: OwnerBanner(
                            onTap: () {
                              controller.startReply(
                                  node.post.postNumber,
                                  node.post.cooked,
                                  node.post.name?.isEmpty ?? true
                                      ? node.post.username
                                      : node.post.name);
                            },
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpand(BuildContext context, TopicDetail topic) {
    final theme = Theme.of(context);
    final createUser = topic.details?.createdBy;

    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.w),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(12).w,
          bottomRight: const Radius.circular(12).w,
        ),
      ),
      child: Column(
        children: [
          EmojiText(
            topic.title ?? '',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 10.sp, fontFamily: AppFontFamily.dinPro),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 4).w,
            child: Divider(
              height: 1.h,
              color: theme.dividerColor,
            ),
          ),
          Row(
            children: [
              CachedImage(
                imageUrl: createUser?.getAvatarUrl(),
                width: 25.w,
                height: 25.w,
                circle: !(createUser?.isWebMaster() ?? false),
                borderRadius: BorderRadius.circular(4).w,
                placeholder: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                errorWidget: Icon(
                  Icons.account_circle,
                  size: 25.w,
                  color: theme.iconTheme.color?.withValues(alpha: 0.5),
                ),
              ),
              4.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createUser?.name?.isEmpty ?? true
                          ? createUser?.username ?? ''
                          : createUser?.name ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 10.sp,
                          fontFamily: AppFontFamily.dinPro,
                          color: createUser?.isWebMaster() ?? false
                              ? Theme.of(context).primaryColor
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: createUser?.isWebMaster() ?? false
                              ? FontWeight.bold
                              : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        if (topic.views != null) ...[
                          Text(
                            '${AppConst.posts.views}:',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          2.hGap,
                          GestureDetector(
                            onTap: () {
                              controller.showStatsDialog();
                            },
                            child: Text(
                              '${topic.views?.toThousandsUnit()}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).primaryColor,
                                fontFamily: AppFontFamily.dinPro,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          8.hGap,
                        ],
                        if (topic.likeCount != null) ...[
                          Text(
                            '${AppConst.posts.likeCount}:',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          2.hGap,
                          GestureDetector(
                            onTap: controller.showStatsDialog,
                            child: Text(
                              '${topic.likeCount}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).primaryColor,
                                fontFamily: AppFontFamily.dinPro,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 28.w,
                child: DisButton(
                  text: AppConst.posts.reply,
                  fontSize: 12.w,
                  onPressed: () {
                    controller.startReply(
                        null, topic.title, topic.details?.createdBy?.username);
                  },
                ),
              )
            ],
          ),
          if (topic.details?.links?.isNotEmpty ?? false) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 4).w,
              child: Divider(
                height: 1.h,
                color: theme.dividerColor,
              ),
            ),
            SizedBox(
              height:
                  calculateLinkListHeight(topic.details?.links?.length ?? 0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: topic.details?.links?.length ?? 0,
                itemBuilder: (context, index) {
                  final link = topic.details?.links?[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 14.sp,
                          color: theme.hintColor,
                        ),
                        4.hGap,
                        Expanded(
                          child: Text(
                            link?.title ?? link?.url ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 10.sp,
                                fontFamily: AppFontFamily.dinPro),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        8.hGap,
                        Text(
                          link?.clicks?.toString() ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 10.sp,
                              fontFamily: AppFontFamily.dinPro),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context, TopicDetail topic) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8).w,
          topRight: const Radius.circular(8).w,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: controller.cancelReply,
                icon: Icon(
                  CupertinoIcons.clear,
                  size: 18.w,
                  color: theme.hintColor,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.all(4.w),
                ),
              ),
            ],
          ),
          // 回复引用
          Obx(() {
            if (controller.replyToPostNumber.value == null) {
              return const SizedBox();
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12).w,
              padding: const EdgeInsets.all(6).w,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)).w,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.reply,
                          size: 16.sp, color: theme.hintColor),
                      8.hGap,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '回复',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.hintColor,
                                fontFamily: AppFontFamily.dinPro,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' #${controller.replyToPostNumber}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFontFamily.dinPro,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.replyPostUser.value != null) ...[
                        4.hGap,
                        Text(
                          '(${controller.replyPostUser.value ?? ''})',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.hintColor,
                            fontFamily: AppFontFamily.dinPro,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ],
                  ),
                  4.vGap,
                  Text(
                    controller.replyPostTitle.value ?? '',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.textTheme.bodyMedium?.color,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ],
              ),
            );
          }),
          // 输入区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).w,
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: 80.w,
                    maxHeight: 200.w,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)).w,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: controller.contentController,
                    onChanged: (value) {
                      controller.replyContent.value = value;
                      controller.updateTypingTime();
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 11.w,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                        hintText: AppConst.posts.replyPlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 13.w,
                          color: theme.hintColor.withValues(alpha: 0.3),
                        ),
                        contentPadding: const EdgeInsets.all(10).w,
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: AppColors.transparent),
                  ),
                ),

                // 图片上传区域
                _buildMenus(context),
                Obx(() {
                  if (controller.uploadedImages.isEmpty) {
                    return Container();
                  }
                  return SizedBox(
                    height: 50.w,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.uploadedImages.length,
                      separatorBuilder: (context, index) => 8.hGap,
                      itemBuilder: (context, index) {
                        final image = controller.uploadedImages[index];
                        return Stack(
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                image: DecorationImage(
                                  image: NetworkImage(image.url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4.w,
                              top: 4.w,
                              child: InkWell(
                                onTap: () => controller.removeImage(image),
                                child: Container(
                                  padding: const EdgeInsets.all(3).w,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    size: 7.w,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),

                16.vGap,
                // 发送按钮
                Obx(() => AnimatedScale(
                      scale: controller.replyContent.value.isEmpty ? 0.8 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        opacity: controller.replyContent.value.isEmpty ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40.w,
                          child: DisButton(
                              text: AppConst.posts.send,
                              onPressed: controller.sendReply,
                              type: ButtonType.transform,
                              useWidthAnimation: true,
                              loading: controller.isSending.value),
                        ),
                      ),
                    )),
              ],
            ),
          ),

          Offstage(
            offstage: !controller.isShowEmojiPicker.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: DisEmojiPicker(
                height: 320.w,
                textEditingController: controller.contentController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenus(BuildContext context) => Row(
        children: [
          controller.isUploading.value
              ? Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: controller.pickAndUploadImage,
                  icon: Icon(
                    CupertinoIcons.camera_fill,
                    color: Theme.of(context).primaryColor,
                    size: 18.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
          // 表情切换
          IconButton(
            icon: Icon(
              CupertinoIcons.smiley_fill,
              color: Theme.of(context).primaryColor,
              size: 18.w,
            ),
            onPressed: () {
              controller.toggleEmojiPicker();
            },
          )
        ],
      );

  // 计算链接列表的高度，基于条目数量
  double calculateLinkListHeight(int linkCount) {
    if (linkCount == 0) return 0;
    final double itemHeight = 20.w;
    final calculatedHeight = linkCount * itemHeight;
    final double minHeight = 16.w;
    final double maxHeight = 100.w;

    return calculatedHeight.clamp(minHeight, maxHeight);
  }

  // 根据Post_type 分别展示不同的楼层内容
  Widget buildPostContent(
      Post post, TopicDetailController controller, BuildContext context) {
    /**
     *  1：普通帖子（Regular Post）
        2：版主操作帖子（Moderator Post）
        3：小动作通知（Small Action Post）
        4：私密帖子（Whisper Post）
        5：系统消息（System Message）
     */
    switch (post.postType) {
      case 3:
        return PostContentAction(
            post: post,
            controller: controller,
            title: controller.topic.value?.title);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            6.vGap,
            PostHeader(post: post, title: controller.topic.value?.title),
            2.vGap,
            PostContent(post: post, isReply: false, controller: controller),
            Divider(
              height: 1.h,
              color: Theme.of(context).dividerColor,
            ),
            12.vGap,
            if (post.replyCount != null && post.replyCount! > 0) ...[
              ReplayList(controller: controller, post: post),
              12.vGap,
            ],
            PostFooter(post: post, controller: controller),
          ],
        );
    }
  }
}
