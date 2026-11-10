import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_item.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_switch.dart';
import 'package:linux_do/widgets/html/html_widget.dart';

class FontSizePage extends GetView<FontSizeController> {
  const FontSizePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "字体大小设置",
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.goforward, size: 20.w),
            onPressed: controller.resetToDefaults,
            tooltip: '重置为默认值',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            16.vGap,
            _buildPostFontSizeSection(context),
            20.vGap,
            _buildReplyFontSizeSection(context),
            20.vGap,
            _buildListDensitySection(context),
            28.vGap,
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16).w,
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8).w,
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.textformat_size,
            color: Get.theme.primaryColor,
            size: 24.w,
          ),
          12.hGap,
          Expanded(
            child: Text(
              '自定义帖子内容字体大小和布局密度，拖动滑块或选择选项即可实时预览效果',
              style: TextStyle(fontSize: 12.w, color: Get.theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFontSizeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).w,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(8).w,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '帖子正文字体大小',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
          ),
          10.vGap,
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.minFontSize.toInt()}',
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Get.theme.hintColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                Text(
                  controller.postFontSize.value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14.w,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                Text(
                  '${controller.maxFontSize.toInt()}',
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Get.theme.hintColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                trackHeight: 4.0,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Get.theme.primaryColor,
                thumbShape: CustomSliderThumbShape(
                  thumbRadius: 8.w,
                  borderWidth: 4.w,
                  borderColor: Colors.white,
                ),
                overlayColor: Get.theme.primaryColor.withValues(alpha: 0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTickMarkColor: Colors.white,
                inactiveTickMarkColor: Colors.white.withValues(alpha: 0.5),
                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 1.5.w),
                showValueIndicator: ShowValueIndicator.always,
                valueIndicatorColor: Get.theme.primaryColor,
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.w,
                ),
              ),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20).w,
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.primaryColor.withValues(alpha: 0.2),
                      Get.theme.primaryColor,
                    ],
                  ),
                ),
                child: Slider(
                  value: controller.postFontSize.value,
                  min: controller.minFontSize,
                  max: controller.maxFontSize,
                  divisions: 20,
                  label: controller.postFontSize.value.toStringAsFixed(1),
                  onChanged: controller.setPostFontSize,
                ),
              ),
            ),
          ),
          16.vGap,
          Text(
            '预览效果:',
            style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.bold),
          ),
          10.vGap,
          Container(
            padding: const EdgeInsets.all(12).w,
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(8).w,
              border: Border.all(color: Get.theme.dividerColor, width: 1),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HtmlWidget(
                    html: controller.exampleText,
                    fontSize: controller.postFontSize.value,
                  ),
                  const Divider(height: 24),
                  HtmlWidget(
                    html: controller.exampleMarkdown,
                    fontSize: controller.postFontSize.value,
                  ),
                  const Divider(height: 24),
                  HtmlWidget(
                    html: controller.exampleCode,
                    fontSize: controller.postFontSize.value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDensitySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10).w,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12).w,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14).w,
            child: Row(
              children: [
                Text(
                  '简洁列表',
                  style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Obx(
                  () => DisSwitch(
                    value: controller.simplified.value,
                    onChanged: (value) {
                      controller.setSimplified(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildDensitySection(),
        ],
      ),
    );
  }

  Widget _buildDensitySection() {
    return Obx(() {
      if (controller.simplified.value) {
        return const SizedBox.square();
      } else {
        return Column(
          children: [
            16.vGap,
            Divider(height: 1, color: Get.theme.dividerColor),
            16.vGap,
            // 标题和当前选择的布局
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '列表布局密度',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ).w,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16).w,
                      ),
                      child: Text(
                        controller.listDensity.value == ListDensity.compact
                            ? '紧凑'
                            : controller.listDensity.value == ListDensity.normal
                            ? '默认'
                            : '松散',
                        style: TextStyle(
                          fontSize: 12.w,
                          fontWeight: FontWeight.w500,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            14.vGap,

            // 布局密度滑块
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4.0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Get.theme.primaryColor,
                    thumbShape: CustomSliderThumbShape(
                      thumbRadius: 8.w,
                      borderWidth: 4.w,
                      borderColor: Colors.white,
                    ),
                    overlayColor: Get.theme.primaryColor.withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.white.withValues(alpha: 0.5),
                    tickMarkShape: RoundSliderTickMarkShape(
                      tickMarkRadius: 1.5.w,
                    ),
                    showValueIndicator: ShowValueIndicator.always,
                    valueIndicatorColor: Get.theme.primaryColor,
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.w,
                    ),
                  ),
                  child: Container(
                    height: 28.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20).w,
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.primaryColor.withValues(alpha: 0.2),
                          Get.theme.primaryColor,
                        ],
                      ),
                    ),
                    child: Slider(
                      value: controller.listDensity.value.index.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (value) {
                        controller.setListDensity(
                          ListDensity.values[value.toInt()],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            12.vGap,

            // 标签指示器
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDensityLabel(
                    CupertinoIcons.arrow_down_right_arrow_up_left,
                    '紧凑',
                    controller.listDensity.value == ListDensity.compact,
                  ),
                  _buildDensityLabel(
                    CupertinoIcons.equal_circle,
                    '默认',
                    controller.listDensity.value == ListDensity.normal,
                  ),
                  _buildDensityLabel(
                    CupertinoIcons.arrow_up_left_arrow_down_right,
                    '松散',
                    controller.listDensity.value == ListDensity.loose,
                  ),
                ],
              ),
            ),

            24.vGap,

            // 预览标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Text(
                '预览效果',
                style: TextStyle(
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),

            // 使用TopicItem预览
            Obx(() {
              final globalController = Get.find<GlobalController>();
              final exampleTopics = globalController.topics;
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: exampleTopics.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return TopicItem(
                    topic: exampleTopics[index],
                    avatarUrl: controller.getLatestPosterAvatar(
                      exampleTopics[index],
                    ),
                    nickName: controller.getNickName(exampleTopics[index]),
                    username: controller.getUserName(exampleTopics[index]),
                    avatarUrls: controller.getAvatarUrls(exampleTopics[index]),
                    avatarActions: AvatarActions.noAction,
                    toPersonalPage: false,
                    openSideslip: false,
                  );
                },
              );
            }),
          ],
        );
      }
    });
  }

  Widget _buildDensityLabel(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14).w,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Get.theme.primaryColor : Get.theme.hintColor,
        ),
      ),
    );
  }

  Widget _buildReplyFontSizeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).w,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(8).w,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '回复内容字体大小',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
          ),
          10.vGap,
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.minFontSize.toInt()}',
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Get.theme.hintColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                Text(
                  controller.replyFontSize.value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14.w,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
                Text(
                  '${controller.maxFontSize.toInt()}',
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Get.theme.hintColor,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                trackHeight: 4.0,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Get.theme.primaryColor,
                thumbShape: CustomSliderThumbShape(
                  thumbRadius: 8.w,
                  borderWidth: 4.w,
                  borderColor: Colors.white,
                ),
                overlayColor: Get.theme.primaryColor.withValues(alpha: 0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTickMarkColor: Colors.white,
                inactiveTickMarkColor: Colors.white.withValues(alpha: 0.5),
                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 1.5.w),
                showValueIndicator: ShowValueIndicator.always,
                valueIndicatorColor: Get.theme.primaryColor,
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.w,
                ),
              ),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20).w,
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.primaryColor.withValues(alpha: 0.2),
                      Get.theme.primaryColor,
                    ],
                  ),
                ),
                child: Slider(
                  value: controller.replyFontSize.value,
                  min: controller.minFontSize,
                  max: controller.maxFontSize,
                  divisions: 20,
                  label: controller.replyFontSize.value.toStringAsFixed(1),
                  onChanged: controller.setReplyFontSize,
                ),
              ),
            ),
          ),
          16.vGap,
          Text(
            '预览效果:',
            style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.bold),
          ),
          10.vGap,
          Container(
            padding: const EdgeInsets.all(12).w,
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(8).w,
              border: Border.all(color: Get.theme.dividerColor, width: 1),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HtmlWidget(
                    html: controller.replyExampleText,
                    fontSize: controller.replyFontSize.value,
                  ),
                  const Divider(height: 24),
                  HtmlWidget(
                    html: controller.replyExampleMarkdown,
                    fontSize: controller.replyFontSize.value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: DisButton(onPressed: controller.saveAndExit, text: '保存设置'),
    );
  }
}

// 自定义滑块形状
class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;
  final Color borderColor;

  const CustomSliderThumbShape({
    required this.thumbRadius,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, thumbRadius + 2, shadowPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius - borderWidth / 2, borderPaint);
  }
}
