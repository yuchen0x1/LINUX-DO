import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_theme.dart';

import '../const/app_const.dart';
import '../utils/mixins/animation_mixin.dart';

import 'loading/loading.dart';

class DisLoadingController extends GetxController
    with GetSingleTickerProviderStateMixin, AnimationMixin {
  late AnimationController animationController;
  late Animation<double> rotationAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = createRotationController(vsync: this);
    rotationAnimation = createRotationAnimation(animationController);
    scaleAnimation = createScaleAnimation(animationController);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class DisSquareLoading extends GetView {
  const DisSquareLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      // decoration: BoxDecoration(
      //   color: Colors.white.withValues(alpha: .8),
      //   borderRadius: BorderRadius.circular(4.w),
      // ),
      child: Center(
        child: LoadingIndicator(
          indicatorType: Indicator.ballBeat,
          colors: [Theme.of(context).primaryColor],
          strokeWidth: 2,
          pathBackgroundColor: Colors.black45,
        ),
      ),
    );
  }
}

class DisRefreshController extends GetxController
    with GetSingleTickerProviderStateMixin, AnimationMixin {
  late AnimationController animationController;
  late Animation<double> rotationAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = createRotationController(vsync: this);
    rotationAnimation = createRotationAnimation(animationController);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  double getCharOffset(int index) {
    final progress = calculatePhaseOffset(animationController.value, index);
    return calculateSineOffset(progress);
  }
}

class DisRefreshLoading extends StatelessWidget {
  final controller = Get.put(DisRefreshController());
  final double? fontSize;
  final double? opacity;

  DisRefreshLoading({super.key, this.fontSize = 16.0, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.rotationAnimation,
      builder: (_, __) {
        return _buildTextAnimation(context);
      },
    );
  }

  Widget _buildTextAnimation(BuildContext context) {
    final chars = AppConst.siteName.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(chars.length, (index) {
        return _DisBouncingChar(
          char: chars[index],
          offset: controller.getCharOffset(index),
          color: Theme.of(context).primaryColor,
          fontSize: fontSize,
          opacity: opacity,
        );
      }),
    );
  }
}

class _DisBouncingChar extends StatelessWidget {
  final String char;
  final double offset;
  final Color color;
  final double? fontSize;
  final double? opacity;

  const _DisBouncingChar({
    required this.char,
    required this.offset,
    required this.color,
    this.fontSize = 16.0,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Text(
        char,
        style: TextStyle(
          fontSize: fontSize?.w,
          color: color.withValues(alpha: opacity),
          fontFamily: AppFontFamily.dinPro,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
