import 'package:flutter/material.dart';

import 'dart:math' as math;

mixin AnimationMixin {
  // 创建旋转动画控制器
  AnimationController createRotationController({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
  }) {
    return AnimationController(vsync: vsync, duration: duration)..repeat();
  }

  // 创建旋转动画
  Animation<double> createRotationAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
  }

  // 创建缩放动画
  Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.2,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // 创建弹跳动画
  Animation<double> createBounceAnimation(
    AnimationController controller, {
    double begin = 0,
    double end = -6,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // 计算错峰动画的偏移
  double calculatePhaseOffset(
    double controllerValue,
    int index, {
    double phaseStep = 0.15,
  }) {
    return (controllerValue + index * phaseStep) % 1.0;
  }

  // 计算正弦波动画的偏移
  double calculateSineOffset(double progress, {double amplitude = 6.0}) {
    return math.sin(progress * 2 * math.pi) * amplitude;
  }
}
