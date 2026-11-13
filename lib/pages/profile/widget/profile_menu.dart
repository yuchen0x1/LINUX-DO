import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/pages/profile/profile_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';

class ProfileMenu extends StatelessWidget with ToastMixin {
  final ProfileController controller;
  const ProfileMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final userInfo = Get.find<GlobalController>().userInfo;
    final user = userInfo?.user;
    return Container(
      margin: const EdgeInsets.only(top: 18, left: 12, right: 12).w,
      child: Column(
        children: [
          // 使用ExpandablePageView替代固定高度的方案
          ExpandablePageView(
            controller: controller.featurePageController,
            onPageChanged: (index) {
              controller.featurePageIndex.value = index;
            },
            children: [
              // 第一页：统计信息
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      '信任等级',
                      user?.trustLevel.toString() ?? '',
                      () => Get.toNamed(Routes.CONNECT),
                    ),
                    _buildStatItem(
                      '徽章数',
                      user?.badgeCount.toString() ?? '',
                      () {},
                    ),
                    _buildStatItem(
                      '积分',
                      '${user?.gamificationScore ?? 0}',
                      () {},
                    ),
                  ],
                ),
              ),
              // 第二页：功能按钮
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton(
                      CupertinoIcons.hand_thumbsup_fill,
                      '点赞',
                      'Likes',
                      [
                        const Color(0xFF5B86E5).withValues(alpha: 0.7),
                        const Color(0xFF36D1DC).withValues(alpha: 0.7),
                      ],
                      () => controller.toLikePage(),
                    ),
                    _buildFeatureButton(
                      CupertinoIcons.bookmark_fill,
                      '收藏',
                      'Favorite',
                      [
                        const Color(0xFFf46b45).withValues(alpha: 0.7),
                        const Color(0xFFFFB75E).withValues(alpha: 0.7),
                      ],
                      () => controller.toCollectPage(),
                    ),
                    _buildFeatureButton(
                      CupertinoIcons.heart_fill,
                      '关注',
                      'Followed',
                      [
                        const Color(0xFF45B649).withValues(alpha: 0.7),
                        const Color(0xFFDCE35B).withValues(alpha: 0.7),
                      ],
                      () => controller.toFollowPage(),
                    ),
                    _buildFeatureButton(
                      CupertinoIcons.person_2_fill,
                      '关注者',
                      'Followers',
                      [
                        const Color(0xFF4e54c8).withValues(alpha: 0.7),
                        const Color(0xFF8f94fb).withValues(alpha: 0.7),
                      ],
                      () => controller.toFollowPage(),
                    ),
                    _buildFeatureButton(
                      CupertinoIcons.flame_fill,
                      '热门',
                      'Popular',
                      [
                        const Color(0xFFe53935).withValues(alpha: 0.7),
                        const Color(0xFFe35d5b).withValues(alpha: 0.7),
                      ],
                      () => controller.toPopularPage(),
                    ),
                  ],
                ),
              ),
              // // 第三页：热门
              // Center(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       18.hGap,
              //       _buildFeatureButton(
              //           CupertinoIcons.flame_fill,
              //           '热门',
              //           'Popular',
              //           [
              //             const Color(0xFFf46b45).withValues(alpha: 0.4),
              //             const Color(0xFFFFB75E).withValues(alpha: 0.4)
              //           ],
              //           () => showWarning('热门功能')),
              //     ],
              //   ),
              // ),
            ],
          ),

          // 添加页面指示器
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8).w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 页面指示器
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        width: controller.featurePageIndex.value == index
                            ? 16.w
                            : 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          gradient: controller.featurePageIndex.value == index
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor
                                        .withValues(alpha: 0.6),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.withValues(alpha: 0.5),
                                    Colors.grey.withValues(alpha: 0.5),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.w,
              fontFamily: AppFontFamily.dinPro,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    IconData icon,
    String label,
    String subtitle,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.w,
        height: 86.w,
        margin: const EdgeInsets.only(bottom: 4).w,
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(4).w,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: 46.w,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    topRight: Radius.circular(4.w),
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 16.w, color: Colors.white),
                ),
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(Get.context!).textTheme.titleMedium?.color,
                fontSize: 10.w,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                fontSize: 10.w,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
            6.vGap,
          ],
        ),
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
