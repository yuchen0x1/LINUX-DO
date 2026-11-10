import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_popup.dart';

class MoreMenu extends StatelessWidget with ToastMixin, Concatenated {
  final TopicDetailController controller;
  const MoreMenu({super.key, required this.controller});

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
            onTap: () => controller.handleOpenInBrowser(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.globe,
                    size: 16.w,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                2.hGap,
                Text(
                  '浏览器打开',
                  style: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          8.vGap,
          GestureDetector(
              onTap: () => _showCategoryDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.star_circle,
                      size: 16.w,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  2.hGap,
                  Text(
                    '本地收藏',
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              )),
          8.vGap,
          GestureDetector(
              onTap: () => _showShareDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.share,
                      size: 16.w,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  2.hGap,
                  Text(
                    '分享',
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              )),
          8.vGap,
          Obx(() {
            final isOnlyAuthor = controller.onlyAuthor.value;
            return GestureDetector(
              onTap: controller.toggleOnlyAuthor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOnlyAuthor
                        ? CupertinoIcons.person_fill
                        : CupertinoIcons.person,
                    size: 16.w,
                    color: isOnlyAuthor
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  2.hGap,
                  Text(
                    isOnlyAuthor ? '查看全部楼层' : '只看楼主',
                    style: TextStyle(
                      fontSize: 14.w,
                      color: isOnlyAuthor
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      child: const Icon(CupertinoIcons.ellipsis_circle),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16).w,
            topRight: const Radius.circular(16).w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部把手和标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12).w,
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                  16.vGap,
                  Text(
                    '选择分类',
                    style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 分类列表
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 16.w,
                  children: AppConst.bookmarkCategories.map((category) {
                    final hue = (category.hashCode % 12) * 30.0;
                    final color =
                        HSLColor.fromAHSL(1.0, hue, 0.6, 0.8).toColor();
                    final iconData = _getCategoryIcon(category);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Get.back(result: category);
                          bool isSuccess =
                              await controller.bookmarkTopic(category);
                          if (isSuccess) {
                            showSuccess('收藏成功');
                          }
                        },
                        borderRadius: BorderRadius.circular(12).w,
                        child: Container(
                          width: (Get.width - 56.w) / 3,
                          padding: const EdgeInsets.symmetric(vertical: 16).w,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.w),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 28.w,
                                color: color,
                              ),
                              8.vGap,
                              Text(
                                category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 底部取消按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16).w,
              child: DisButton(
                text: '取消',
                type: ButtonType.primary,
                onPressed: () => Get.back(),
              ),
            ),
            12.vGap
          ],
        ),
      ),
      enterBottomSheetDuration: 300.milliseconds,
      exitBottomSheetDuration: 200.milliseconds,
    );
  }

  // 根据分类名获取对应的图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '开发调优':
        return CupertinoIcons.wand_rays;
      case '文档共建':
        return CupertinoIcons.doc_text;
      case '非我莫属':
        return CupertinoIcons.person_2;
      case '扬帆起航':
        return CupertinoIcons.paperplane_fill;
      case '福利羊毛':
        return CupertinoIcons.gift;
      case '运营反馈':
        return CupertinoIcons.chat_bubble_2;
      case '资源荟萃':
        return CupertinoIcons.rectangle_stack;
      case '跳蚤市场':
        return CupertinoIcons.cart;
      case '读书成诗':
        return CupertinoIcons.book;
      case '前沿快讯':
        return CupertinoIcons.news;
      case '搞七捻三':
        return CupertinoIcons.lightbulb;
      case '深海幽域':
        return CupertinoIcons.moon_stars;
      default:
        return CupertinoIcons.tag;
    }
  }

  _showShareDialog(BuildContext context) {
    final topic = controller.topic.value;
    final title = topic?.title ?? '分享标题';
    const description = '来自Linux.DO的精彩话题讨论';
    final url = 'https://linux.do/t/${topic?.id ?? 1}?u=$userName';
    final box = context.findRenderObject() as RenderBox?;

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24).w,
            topRight: const Radius.circular(24).w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.8,
          minWidth: Get.width,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部装饰条
            Container(
              margin: const EdgeInsets.only(top: 12).w,
              width: 40.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // 链接分享卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).w,
              child: _buildShareCard(context, title, description, url),
            ),

            12.vGap,

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).w,
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: DisButton(
                  text: '分享',
                  type: ButtonType.primary,
                  onPressed: () => controller.shareController
                      .share(title, description, url, box),
                ),
              ),
            ),

            6.vGap,

            // 底部按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).w,
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: DisButton(
                  text: '取消',
                  type: ButtonType.outline,
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            30.vGap,
          ],
        ),
      ),
    );
  }

  // 分享卡片
  Widget _buildShareCard(
      BuildContext context, String title, String description, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预览区域
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8).w,
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.doc_text,
                      color: Theme.of(context).primaryColor,
                      size: 24.w,
                    ),
                  ),
                ),
                12.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontFamily: AppFontFamily.dinPro),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.vGap,
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontFamily: AppFontFamily.dinPro),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 链接区域
          Padding(
            padding: const EdgeInsets.all(12).w,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.hGap,
                SizedBox(
                  height: 30.w,
                  child: DisButton(
                    text: '复制',
                    type: ButtonType.primary,
                    onPressed: () {
                      controller.shareController.copyLink(url);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
