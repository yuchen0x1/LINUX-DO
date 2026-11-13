import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/image_size.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/models/upload_image_response.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import 'package:dio/dio.dart' as dio;

import '../const/app_colors.dart';
import '../const/app_theme.dart';
import '../controller/base_controller.dart';
import '../models/category_data.dart';
import '../models/user.dart';
import '../net/api_service.dart';
import '../net/success_response.dart';
import '../utils/badge.dart';
import '../utils/log.dart';
import 'state_view.dart';
import '../const/app_const.dart';

enum AvatarActions { openCard, openUserInfo, noAction }

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final bool circle;
  final Color? borderColor;
  final String username;
  final AvatarActions avatarActions;
  final Post? post;
  final String? title;
  final bool? toPersonalPage;
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    this.size = 42,
    this.borderRadius = 4,
    this.backgroundColor = Colors.transparent,
    this.circle = true,
    this.borderColor,
    this.username = '',
    this.avatarActions = AvatarActions.noAction,
    this.post,
    this.title,
    this.toPersonalPage = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (avatarActions == AvatarActions.openCard) {
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12).w,
              ),
              child: UserInfoCard(
                username: username,
                post: post,
                title: title,
                toPersonalPage: toPersonalPage ?? true,
              ),
            ),
            barrierColor: Colors.black.withValues(alpha: 0.5),
          );
        }
      },
      child: CachedImage(
        imageUrl: avatarUrl,
        width: size,
        height: size,
        circle: circle,
        backgroundColor: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        borderColor: borderColor ?? AppColors.transparent,
        showBorder: true,
      ),
    );
  }
}

class UserInfoCard extends GetView<UserInfoCardController> {
  final String username;
  final Post? post;
  final String? title;
  final bool toPersonalPage;
  const UserInfoCard({
    super.key,
    required this.username,
    this.post,
    this.title,
    this.toPersonalPage = true,
  });

  @override
  Widget build(BuildContext context) {
    // 初始化controller
    Get.put(UserInfoCardController(username: username));
    final globalController = Get.find<GlobalController>();
    return Container(
      width: globalController.isAnonymousMode ? 300.w : 380.w,
      constraints: BoxConstraints(
        maxHeight: globalController.isAnonymousMode ? 380.w : 450.w,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Obx(
        () => StateView(
          state: _getViewState(),
          child: Stack(
            children: [
              // 卡片背景半透明图片
              _buildBackground(context),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部背景和头像
                  _buildHeader(context),

                  // 用户信息
                  _buildUserInfo(context),

                  // 统计信息
                  _buildStats(context),

                  // 其他信息
                  _buildOtherInfo(context),

                  // 徽章
                  _buildBadges(context),

                  // 底部按钮
                  globalController.isAnonymousMode
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              '尊贵的游客,该功能需要登录 🤨',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 10.w,
                              ),
                            ),
                          ),
                        )
                      : _buildActions(context),
                ],
              ),

              // 加载中
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: controller._coverLoading.value
                    ? const Center(child: DisSquareLoading())
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final user = controller._userInfo.value?.user;
    if (user?.backgroundUrl == null) return const SizedBox();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: 0.16,
        child: CachedImage(
          imageUrl: user?.backgroundUrl ?? '',
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.w),
            topRight: Radius.circular(12.w),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 顶部背景
        Container(
          height: 80.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.w),
              topRight: Radius.circular(12.w),
            ),
          ),
        ),

        // 头像
        Positioned(
          left: 20.w,
          bottom: -20.w,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(user?.id != 1 ? 30.w : 4.w),
            ),
            child: GestureDetector(
              onTap: () {
                if (toPersonalPage == true) {
                  Get.toNamed(Routes.PERSONAL, arguments: username);
                }
              },
              child: CachedImage(
                imageUrl: user?.avatarUrl ?? '',
                width: 60,
                height: 60,
                circle: user?.id != 1,
              ),
            ),
          ),
        ),

        // 关闭按钮
        Positioned(
          right: 8.w,
          top: 8.w,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: Colors.white, size: 20.w),
          ),
        ),

        // 时间
        Positioned(
          left: 130,
          right: 30.w,
          bottom: -40.w,
          child: Row(
            children: [
              16.hGap,
              _buildTopTimeItem(
                context,
                AppConst.user.joinTime,
                '${user?.cakedate}',
              ),
              16.hGap,
              _buildTopTimeItem(
                context,
                AppConst.user.postTime,
                _getRelativeTime(user?.lastPostedAt ?? ''),
              ),
            ],
          ),
        ),

        // 用户名
        Positioned(
          right: 0,
          left: 100.w,
          bottom: 8.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? username,
                style: TextStyle(
                  fontSize: 14.w,
                  fontFamily: AppFontFamily.dinPro,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              user?.admin == true
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        AppConst.user.admin,
                        style: TextStyle(
                          fontSize: 9.w,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : 16.hGap,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(top: 10.w),
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Center(
        child: Text(
          '@${user?.username ?? username}',
          style: TextStyle(
            fontSize: 8.w,
            fontFamily: AppFontFamily.dinPro,
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Container(
      padding: EdgeInsets.only(bottom: 16.w, left: 16.w, right: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            AppConst.user.points,
            formattedScore(user?.gamificationScore ?? 0),
          ),
          _buildStatItem(
            context,
            AppConst.user.follow,
            '${user?.totalFollowing ?? 0}',
          ),
          _buildStatItem(
            context,
            AppConst.user.followers,
            '${user?.totalFollowers ?? 0}',
          ),
          _buildStatItem(
            context,
            AppConst.user.solutions,
            '${user?.acceptedAnswers ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildTopTimeItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 10.w,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          4.vGap,
          Text(
            label,
            style: TextStyle(fontSize: 8.w, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15.w,
            fontWeight: FontWeight.bold,
            fontFamily: AppFontFamily.dinPro,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        4.vGap,
        Text(
          label,
          style: TextStyle(fontSize: 12.w, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          SizedBox(
            height: 30.w,
            width: double.infinity,
            child: DisButton(
              text: AppConst.user.like,
              onPressed: () {
                controller.fetchCategorys();
                _showAcceptDialog();
              },
              icon: CupertinoIcons.hand_thumbsup,
              size: ButtonSize.small,
            ),
          ),
          6.vGap,
          SizedBox(
            height: 30.w,
            width: double.infinity,
            child: DisButton(
              text: user?.isFollowed == true
                  ? AppConst.user.unfollowUser
                  : AppConst.user.followUser,
              onPressed: () {
                controller.followUser();
              },
              icon: CupertinoIcons.person_crop_circle_badge_plus,
              size: ButtonSize.small,
            ),
          ),
          6.vGap,
          SizedBox(
            height: 30.w,
            child: Row(
              children: [
                Expanded(
                  child: DisButton(
                    text: AppConst.user.message,
                    onPressed: () {
                      _showPrivateMessageDialog();
                    },
                    icon: CupertinoIcons.envelope_circle,
                    size: ButtonSize.small,
                  ),
                ),
                12.hGap,
                Expanded(
                  child: DisButton(
                    text: AppConst.user.chat,
                    onPressed: () {
                      controller.toChatDetail();
                    },
                    type: ButtonType.secondary,
                    icon: CupertinoIcons.chat_bubble_2,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return '-';
    }
    try {
      final date = DateTime.parse(dateStr);
      return date.friendlyDateTime;
    } catch (e) {
      return '-';
    }
  }

  String formattedScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
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

  /// 构建徽章
  _buildBadges(BuildContext context) {
    final badges = controller._userInfo.value?.badges;
    if (badges == null || badges.isEmpty) return const SizedBox();
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6.w,
            crossAxisSpacing: 6.w,
            childAspectRatio: 3,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final badgeColor = BadgeIconHelper.getColor(badge.name);
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 80.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 3.w,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text(
                          badge.name,
                          style: TextStyle(
                            fontSize: 9.w,
                            fontWeight: FontWeight.bold,
                            color: badgeColor.withValues(alpha: 1),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建其他信息
  Widget _buildOtherInfo(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Container(
      width: double.infinity,
      height: 60.w,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: .6.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: HtmlWidget(
              html: user?.bioExcerpt ?? 'TA什么都没有留下~',
              fontSize: 11.w,
              customWidgetBuilder: (element) {
                final srcTmp = element.attributes['src'];
                final src =
                    srcTmp?.startsWith('http://') == true ||
                        srcTmp?.startsWith('https://') == true
                    ? srcTmp
                    : null;
                if (element.localName == 'img' && src != null) {
                  return Image.network(src, width: 20.w, height: 20.w);
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 显示认可对话框
  void _showAcceptDialog() {
    controller._endorseUserCategorys.value = [];
    final user = controller._userInfo.value?.user;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '您觉得 ${user?.name ?? username} 的优点是什么？',
                style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
              ),
              16.vGap,
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Obx(
                    () => Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children:
                          controller._categorys.value
                              ?.map(
                                (e) => _buildAdvantageItem(e.name ?? '', e.id),
                              )
                              .toList() ??
                          [],
                    ),
                  ),
                ),
              ),
              16.vGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(() {
                    final likesRemaining =
                        Get.find<GlobalController>()
                            .userInfo
                            ?.user
                            ?.voteCount ??
                        2;
                    return Text(
                      '今日还剩$likesRemaining次',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(Get.context!).hintColor,
                      ),
                    );
                  }),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      AppConst.cancel,
                      style: TextStyle(color: Theme.of(Get.context!).hintColor),
                    ),
                  ),
                  8.hGap,
                  Obx(
                    () => DisButton(
                      text: AppConst.user.like,
                      type: ButtonType.transform,
                      loading: controller._loading.value,
                      onPressed:
                          controller._endorseUserCategorys.value?.isEmpty ==
                              true
                          ? null
                          : () {
                              controller.fetchEndorseUserCategorys();
                            },
                      size: ButtonSize.small,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Widget _buildAdvantageItem(String name, int id) {
    return Obx(() {
      final isSelected =
          controller._endorseUserCategorys.value?.contains(id) ?? false;
      return GestureDetector(
        onTap: () {
          final currentList = controller._endorseUserCategorys.value ?? [];
          if (isSelected) {
            controller._endorseUserCategorys.value = currentList
                .where((element) => element != id)
                .toList();
          } else {
            controller._endorseUserCategorys.value = [...currentList, id];
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(Get.context!).primaryColor
                : Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: isSelected
                  ? Theme.of(Get.context!).primaryColor
                  : Theme.of(Get.context!).dividerColor,
              width: 1.w,
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14.w,
              color: isSelected
                  ? Colors.white
                  : Theme.of(Get.context!).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    });
  }

  /// 发送私信弹窗
  void _showPrivateMessageDialog() {
    final content = post?.cooked;
    final user = controller._userInfo.value?.user;

    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Container(
          width: 0.9.sw,
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '发送私信',
                    style: TextStyle(
                      fontSize: 15.w,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(Get.context!).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      CupertinoIcons.clear,
                      size: 20.w,
                      color: Theme.of(Get.context!).hintColor,
                    ),
                  ),
                ],
              ),
              8.vGap,
              // 标题和描述
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(Get.context!).primaryColor,
                      Theme.of(Get.context!).primaryColor
                          .withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.reply,
                      size: 16.w,
                      color: AppColors.white,
                    ),
                    8.hGap,
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: TextStyle(
                          fontSize: 12.w,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              8.vGap,
              Stack(
                children: [
                  Container(
                    height: 68.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        maxHeight: 68.w,
                        child: HtmlWidget(html: content ?? '', fontSize: 12.w),
                      ),
                    ),
                  ),
                  // 渐变遮罩
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0.w,
                    child: Container(
                      height: 30.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(Get.context!).cardColor
                                .withValues(alpha: 0),
                            Theme.of(Get.context!).cardColor,
                          ],
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(right: 4.w),
                    ),
                  ),
                ],
              ),
              16.vGap,
              // 用户信息
              Row(
                children: [
                  AvatarWidget(
                    avatarUrl: user?.avatarUrl ?? '',
                    size: 40.w,
                    username: username,
                    circle: user?.id != 1,
                    avatarActions: AvatarActions.noAction,
                  ),
                  12.hGap,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name == null || user?.name?.isEmpty == true
                            ? username
                            : user?.name ?? '',
                        style: TextStyle(
                          fontSize: 12.w,
                          fontWeight: user?.id != 1
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: user?.id != 1
                              ? Theme.of(Get.context!)
                                    .textTheme
                                    .titleMedium
                                    ?.color
                              : Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                      Text(
                        user?.userTitle ?? '',
                        style: TextStyle(
                          fontSize: 10.w,
                          color: Theme.of(Get.context!)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Get.find<GlobalController>().userInfo?.user?.admin ?? false
                  ? Row(
                      children: [
                        const Spacer(),
                        Obx(
                          () => Checkbox(
                            fillColor: WidgetStateProperty.all(
                              Theme.of(Get.context!).canvasColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            checkColor: Theme.of(Get.context!).primaryColor,
                            activeColor: Theme.of(Get.context!).primaryColor,
                            value: controller.isOfficialWarning.value,
                            onChanged: (value) {
                              controller.isOfficialWarning.value =
                                  value ?? false;
                            },
                          ),
                        ),
                        Text(
                          AppConst.posts.officialWarning,
                          style: TextStyle(
                            fontSize: 10.w,
                            color: Theme.of(Get.context!)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                      ],
                    )
                  : 12.vGap,

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).cardColor,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: Theme.of(Get.context!).primaryColor
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: controller.titleController,
                  maxLines: 1,
                  style: TextStyle(fontSize: 10.w),
                  decoration: InputDecoration(
                    hintText: AppConst.posts.titlePlaceholder,
                    hintStyle: TextStyle(
                      fontSize: 12.w,
                      color: Theme.of(Get.context!).hintColor,
                    ),
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
              6.vGap,
              // 输入框
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).cardColor,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: Theme.of(Get.context!).primaryColor
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  maxLines: 4,
                  style: TextStyle(fontSize: 10.w),
                  decoration: InputDecoration(
                    hintText: AppConst.posts.messagePlaceholder,
                    hintStyle: TextStyle(
                      fontSize: 12.w,
                      color: Theme.of(Get.context!).hintColor,
                    ),
                    filled: false,
                    contentPadding: EdgeInsets.all(12.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
              6.vGap,
              // 图片列表
              Obx(
                () => Column(
                  children: controller.uploadedImages
                      .map(
                        (image) => Container(
                          margin: EdgeInsets.only(bottom: 4.w),
                          decoration: BoxDecoration(
                            color: Theme.of(Get.context!).cardColor,
                            borderRadius: BorderRadius.circular(4.w),
                            border: Border.all(
                              color: Theme.of(Get.context!).dividerColor
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  image.originalFilename,
                                  style: TextStyle(
                                    fontSize: 10.w,
                                    color: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.removeImage(image),
                                child: Icon(CupertinoIcons.delete, size: 16.w),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              6.vGap,
              // 底部工具栏
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.pickAndUploadImage();
                    },
                    child: Icon(
                      CupertinoIcons.paperclip,
                      size: 20.w,
                      color: Theme.of(Get.context!).hintColor,
                    ),
                  ),
                  12.hGap,
                  Obx(
                    () => controller.isUploading.value
                        ? SizedBox(
                            height: 20.w,
                            child: DisRefreshLoading(fontSize: 8),
                          )
                        : const SizedBox(),
                  ),
                  const Spacer(),
                  DisButton(
                    text: AppConst.posts.send,
                    onPressed: () {
                      if (controller.messageController.text.trim().isEmpty) {
                        return;
                      }
                      controller.sendMessage();
                      Get.back();
                    },
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class UserInfoCardController extends BaseController {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final ApiService apiService = Get.find();
  final String username;
  final int? postCount;

  // 用户信息
  final _userInfo = Rxn<UserResponse>();
  final _categorys = Rxn<List<Category>>();
  final _endorseUserCategorys = Rxn<List<int>>();
  final _loading = RxBool(false);
  final _isFirst = RxBool(true);
  final _coverLoading = RxBool(false);

  final uploadedImages = <UploadImageResponse>[].obs;
  final isUploading = false.obs;

  // 是否是官方警告信息
  final isOfficialWarning = false.obs;

  UserInfoCardController({required this.username, this.postCount});

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = _isFirst.value;
      _coverLoading.value = !_isFirst.value;
      final user = await apiService.getUserCard(
        username,
        includePostCountFor: postCount,
      );
      _userInfo.value = user;
      isLoading.value = _isFirst.value = false;
      _coverLoading.value = false;
    } catch (e) {
      isLoading.value = _isFirst.value = false;
      _coverLoading.value = false;
      hasError.value = true;
    }
  }

  Future<void> fetchCategorys() async {
    try {
      final categorys = await apiService.getUserCategories(username);
      _categorys.value = categorys.categories;
    } catch (e, s) {
      l.e('fetchCategorys error: $e ---$s');
    }
  }

  Future<void> fetchEndorseUserCategorys() async {
    try {
      _loading.value = true;
      await apiService.endorseUserCategory(
        '',
        _endorseUserCategorys.value ?? [],
      );
      Get.back();

      /// 成功后,刷新用户信息
      Get.find<GlobalController>().fetchUserInfo();
    } catch (e) {
      l.e('fetchLikesRemaining error: $e');
      showError(AppConst.user.failed);
    } finally {
      _loading.value = false;
    }
  }

  Future<void> followUser() async {
    try {
      SuccessResponse<dynamic> response;
      if (_userInfo.value?.user?.isFollowed == true) {
        response = await apiService.unfollowUser(username);
      } else {
        response = await apiService.followUser(username);
      }
      if (response.isSuccess) {
        fetchUserInfo();
      } else {
        showError(AppConst.user.failed);
      }
    } catch (e, s) {
      l.e('followUser error: $e --- $s');
      showError(AppConst.user.failed);
    }
  }

  // 计算文件的SHA1
  String _calculateSha1(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }

  // 生成短文件名
  String _generateShortFileName(String originalFileName) {
    final extension = originalFileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    final random = (1000 + Random().nextInt(9000)).toString();
    return 'img_${timestamp}_$random.$extension';
  }

  // 选择并上传图片
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isUploading.value = true;
      try {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final originalFileName = pickedFile.path.split('/').last;
        final shortFileName = _generateShortFileName(originalFileName);
        final sha1Checksum = _calculateSha1(bytes);

        // 创建 FormData
        final formData = dio.FormData.fromMap({
          'upload_type': 'composer',
          'pasted': false,
          'name': shortFileName,
          'type': 'image/${shortFileName.split('.').last}',
          'sha1_checksum': sha1Checksum,
          'file': await dio.MultipartFile.fromFile(
            pickedFile.path,
            filename: shortFileName,
          ),
        });

        final response = await apiService.uploadImage(
          GlobalController.clientId,
          formData,
        );

        // 打印上传响应信息
        l.d(
          'Image upload response - shortUrl: ${response.shortUrl}, url: ${response.url}',
        );

        uploadedImages.add(response);

        // 将图片插入到内容中，使用 shortUrl 作为标记但在预览时使用完整 url
        final imageMarkdown =
            '\n![${response.originalFilename}|${response.width}x${response.height}](${response.shortUrl})\n';
        final currentContent = messageController.text;
        final cursorPosition = messageController.selection.baseOffset;

        if (cursorPosition >= 0) {
          final newContent =
              currentContent.substring(0, cursorPosition) +
              imageMarkdown +
              currentContent.substring(cursorPosition);
          messageController.text = newContent;
          messageController.selection = TextSelection.collapsed(
            offset: cursorPosition + imageMarkdown.length,
          );
        } else {
          messageController.text += imageMarkdown;
        }
      } catch (e, s) {
        showToast(AppConst.createPost.uploadFailed);
        l.e('Error uploading image: $e -- $s');
      } finally {
        isUploading.value = false;
      }
    }
  }

  // 删除图片
  void removeImage(UploadImageResponse image) {
    uploadedImages.remove(image);
    // 从内容中移除图片引用
    final imagePattern =
        '\\!\\[${image.originalFilename}\\|${image.width}x${image.height}\\]\\(${image.shortUrl}\\)';
    final regex = RegExp(imagePattern);
    messageController.text = messageController.text.replaceAll(regex, '');
  }

  /// 发送私信
  void sendMessage() async {
    final title = titleController.text;
    final content = messageController.text;
    if (title.isEmpty || content.isEmpty) {
      showError("请输入标题和内容");
      return;
    }

    final imageSizes = <String, ImageSize>{};
    for (final image in uploadedImages) {
      imageSizes[image.url] = ImageSize(
        width: image.width,
        height: image.height,
      );
    }

    try {
      final response = await apiService.createPost(
        title: title,
        content: content,
        targetRecipients: _userInfo.value?.user?.username,
        isWarning: isOfficialWarning.value,
        imageSizes: imageSizes,
        archetype: 'private_message',
      );

      if (response.success == true) {
        showSuccess(AppConst.posts.sendSuccess);
        Get.back();
      } else {
        showError(AppConst.posts.sendFailed);
      }
    } catch (e) {
      l.e('sendMessage error: $e');
      showError(AppConst.posts.sendFailed);
    }
  }

  void toChatDetail() async {
    try {
      final response = await apiService.getDirectChannel(username, true, true);
      if (response.channel != null) {
        Get.toNamed(Routes.CHAT_DETAIL, arguments: response.channel);
      } else {
        showError(AppConst.user.failed);
      }
    } catch (e, s) {
      l.e('toChatDetail error: $e --- $s');
      showError(AppConst.user.failed);
    }
  }
}
