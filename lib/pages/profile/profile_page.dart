import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/pages/profile/widget/profile_menu.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_emoji_picker.dart';
import 'package:linux_do/widgets/emoji_text.dart';
import 'package:linux_do/widgets/glowing_text_wweep.dart';
import 'dart:ui';
import '../../const/app_const.dart';
import '../../controller/global_controller.dart';
import '../../models/user.dart';
import '../../utils/mixins/toast_mixin.dart';
import '../../widgets/dis_button.dart';
import '../../widgets/switch.dart';
import '../../widgets/trust_level_badge.dart';
import 'profile_controller.dart';
import '../../widgets/dis_loading.dart';
import 'package:slide_switcher/slide_switcher.dart';

class ProfilePage extends GetView<ProfileController> with ToastMixin {
  const ProfilePage({super.key});

  Widget _buildTabText(String text, int index) {
    final context = Get.context!;
    return Obx(() => Text(
          text,
          style: TextStyle(
            fontSize: 14.w,
            color: controller.selectedIndex == index
                ? AppColors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // 创建一个 ValueNotifier 来跟踪滚动进度
    final scrollProgress = ValueNotifier<double>(0.0);

    return Scaffold(
      body: Obx(() {
        final globalController = Get.find<GlobalController>();
        final userInfo = globalController.userInfo;
        final expandedHeight =
            userInfo?.user?.backgroundUrl != null ? 380.w : 280.w;
        final user = userInfo?.user;

        return NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: expandedHeight,
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final top = constraints.biggest.height;
                  final shrinkOffset = expandedHeight - top;
                  final progress =
                      (shrinkOffset / (expandedHeight - kToolbarHeight))
                          .clamp(0.0, 1.0);

                  // 更新滚动进度
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollProgress.value = progress;
                  });

                  return Container(
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: progress),
                    child: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 背景图片
                          if (progress < 1)
                            Opacity(
                              opacity: (1 - progress).clamp(0.0, 1.0),
                              child: user?.cardBackgroundUploadUrl != null
                                  ? CachedImage(
                                      imageUrl: user?.backgroundUrl ?? '',
                                      fit: BoxFit.cover)
                                  : Image.asset(
                                      AppImages.profileHeaderBg,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          // 模糊效果
                          if (progress > 0)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: progress * 10,
                                sigmaY: progress * 10,
                              ),
                              child: Container(
                                color: Colors.black
                                    .withValues(alpha: progress * 0.3),
                              ),
                            ),
                          // 渐变遮罩
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // 用户信息
                          Positioned(
                              // 使用线性插值函数
                              bottom: lerpDouble(10.w, 16.w, progress),
                              left: lerpDouble(8.w, 56.w, progress),
                              right: 0,
                              child: _buildProfile(user, progress, context)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              title: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showTitle = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: showTitle ? 1.0 : 0.0,
                    child: showTitle
                        ? Text(
                            user?.username ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              leading: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showAvatar = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showAvatar ? 1.0 : 0.0,
                    child: showAvatar
                        ? Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.white, width: 1.w),
                                      borderRadius:
                                          BorderRadius.circular(80.w)),
                                  child: Stack(
                                    children: [
                                      CachedImage(
                                        imageUrl: user?.avatarUrl ?? '',
                                        circle: true,
                                        width: 30.w,
                                        height: 30.w,
                                        borderRadius:
                                            BorderRadius.circular(80.w),
                                        showBorder: true,
                                        borderColor: AppColors.white,
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: user?.status?.emoji != null
                                            ? EmojiText(
                                                ':${user?.status?.emoji}:',
                                                style: TextStyle(
                                                  fontSize: 10.w,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      controller.toSettings();
                    },
                    icon: const Icon(
                      CupertinoIcons.gear_solid,
                      color: AppColors.white,
                    )),
                8.hGap
              ],
            ),

            // 统计信息及菜单按钮
            SliverToBoxAdapter(
              child: globalController.isAnonymousMode
                  ? const SizedBox.shrink()
                  : ProfileMenu(controller: controller),
            ),

            // Tab栏
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 40.w,
                maxHeight: 40.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(12.w),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SlideSwitcher(
                    containerHeight: 40.w,
                    containerWight: MediaQuery.of(context).size.width - 40.w,
                    initialIndex: controller.selectedIndex,
                    containerColor: Theme.of(context).cardColor,
                    slidersGradients: [
                      LinearGradient(colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.6)
                      ])
                    ],
                    onSelect: (index) => controller.selectedIndex = index,
                    children: [
                      _buildTabText('总结', 0),
                      _buildTabText('活动', 1),
                      _buildTabText('通知', 2),
                      _buildTabText('消息', 3),
                      _buildTabText('徽章', 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Obx(() => globalController.isAnonymousMode
              ? GestureDetector(
                  onLongPress: () {
                    showSuccess('没有惊喜 😜');
                  },
                  child: Center(
                    child: Text(
                      '尊贵的游客,长按此处3秒没有惊喜哦',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),
                )
              : Get.find<GlobalController>().userInfo == null
                  ? const Center(child: DisSquareLoading())
                  : controller.createCurrent()),
        );
      }),
    );
  }

  Widget _buildProfile(
      CurrentUser? user, double progress, BuildContext context) {
    final globalController = Get.find<GlobalController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 2.w),
                      borderRadius: BorderRadius.circular(45.w)),
                  child: CachedImage(
                    imageUrl: user?.avatarUrl ?? '',
                    circle: true,
                    width: 70.w,
                    height: 70.w,
                  ),
                ),
                Positioned(
                    bottom: 10.w,
                    left: 60.w,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                          color: user?.userAction?.hidePresence == false
                              ? AppColors.disabled
                              : AppColors.success,
                          border:
                              Border.all(color: AppColors.white, width: 1.5.w),
                          borderRadius: BorderRadius.circular(10.w)),
                    ))
              ],
            ),
            16.hGap,
            if (progress < 0.5) ...[
              // 用户名
              Opacity(
                opacity: (1 - progress * 2).clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlowingTextSweep(
                          text: user?.name ??
                              (globalController.isAnonymousMode ? '旅途雅士' : ''),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18.w,
                            fontFamily: AppFontFamily.dinPro,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          glowColor: Colors.white,
                        ),
                        globalController.isAnonymousMode
                            ? const SizedBox.shrink()
                            : IconButton(
                                onPressed: () {
                                  Get.toNamed(Routes.EDIT_PROFILE);
                                },
                                icon: Icon(
                                  CupertinoIcons.pencil,
                                  color: AppColors.white.withValues(alpha: .9),
                                  size: 20.w,
                                )),
                        if (!globalController.isAnonymousMode &&
                            (user?.trustLevel != null))
                          TrustLevelBadge(level: user!.trustLevel)
                      ],
                    ),
                    globalController.isAnonymousMode
                        ? const SizedBox.shrink()
                        : Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: .9),
                              fontFamily: AppFontFamily.dinPro,
                              fontSize: 12.sp,
                            ),
                          ),
                  ],
                ),
              )
            ],
          ],
        ),
        10.vGap,
        globalController.isAnonymousMode
            ? const SizedBox.shrink()
            : Row(
                children: [
                  Container(
                    height: 28.w,
                    constraints: BoxConstraints(maxWidth: 150.w),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14.w)),
                    child: InkWell(
                      onTap: () => showCustomStatusDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          user?.status?.emoji != null
                              ? const SizedBox.shrink()
                              : Icon(
                                  CupertinoIcons.plus_circle,
                                  size: 16.w,
                                  color: Theme.of(context).primaryColor,
                                ),
                          user?.status?.emoji != null
                              ? EmojiText(
                                  ':${user?.status?.emoji}:',
                                )
                              : const SizedBox.shrink(),
                          4.hGap,
                          Text(
                            user?.status?.description ?? '自定义状态',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  12.hGap,
                  globalController.isAnonymousMode
                      ? const SizedBox.shrink()
                      : SizedBox(
                          height: 28.w,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DisSwitch(
                                value:
                                    (user?.userAction?.hidePresence ?? false),
                                textOn: '在线',
                                textOff: '离线',
                                colorOn: Theme.of(context).primaryColor,
                                iconOn:
                                    CupertinoIcons.checkmark_alt_circle_fill,
                                iconOff: Icons.power_settings_new,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                onChanged: (bool state) {
                                  controller.updatePresence(state);
                                },
                              ),
                            ],
                          ),
                        ),
                ],
              )
      ],
    );
  }

  void showCustomStatusDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Obx(
                    () => controller.emojiStatus.value.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Theme.of(Get.context!)
                                  .primaryColor
                                  .withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: EmojiText(controller.emojiStatus.value),
                          )
                        : const SizedBox.shrink(),
                  ),
                  6.hGap,
                  Expanded(
                    child: TextField(
                      controller: controller.statusController,
                      decoration: InputDecoration(
                        hintText: AppConst.settings.status,
                        filled: false,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Theme.of(Get.context!).hintColor,
                            fontSize: 12.sp),
                      ),
                    ),
                  ),
                  16.hGap,
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
              ),
              16.hGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      AppConst.cancel,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12.sp),
                    ),
                  ),
                  8.hGap,
                  SizedBox(
                      width: 80.w,
                      height: 30.w,
                      child: DisButton(
                        text: AppConst.confirm,
                        size: ButtonSize.small,
                        onPressed: () {
                          controller.updateStatus();
                          Get.back();
                        },
                      ))
                ],
              ),
              Obx(
                () => Offstage(
                  offstage: !controller.isShowEmojiPicker.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: DisEmojiPicker(
                      height: 320.w,
                      onEmojiSelected: (emoji) {
                        controller.emojiStatus.value = emoji;
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 使用 clamp 确保不会出现精度问题
    final double currentExtent =
        (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    return SizedBox(
      height: currentExtent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
