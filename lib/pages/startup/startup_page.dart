import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_theme.dart';

import 'startup_controller.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  static const animationDuration = Duration(milliseconds: 1200);

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final StartupController _startup;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _startup = Get.find<StartupController>();
    _animation =
        AnimationController(
          vsync: this,
          duration: StartupPage.animationDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _startup.completeStartup();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!_started || (reduceMotion && !_animation.isCompleted)) {
      _started = true;
      // 无障碍设置要求减少动画时，直接展示最终状态并跳转。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (reduceMotion) {
          _animation.value = 1;
        } else {
          _animation.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Semantics(
            label: 'LINUX DO 正在启动',
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final progress = _animation.value;
                  final reveal = Curves.easeOutCubic.transform(
                    (progress / .65).clamp(0.0, 1.0),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 172,
                        child: CustomPaint(
                          painter: _LogoOrbitPainter(progress: progress),
                          child: Center(
                            child: Opacity(
                              opacity: reveal,
                              child: Transform.scale(
                                scale: .86 + .14 * reveal,
                                child: Image.asset(
                                  AppImages.logoCircle,
                                  width: 104,
                                  height: 104,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Opacity(opacity: reveal, child: child),
                    ],
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LINUX DO',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: AppFontFamily.dinPro,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '真诚 · 友善 · 团结 · 专业',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 环绕 Logo 的金色弧线只播放一次，收尾后自动进入下一页。
class _LogoOrbitPainter extends CustomPainter {
  const _LogoOrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = math.sin(math.pi * progress).clamp(0.0, 1.0);
    final radius = 64 + 10 * Curves.easeOut.transform(progress);
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.logoColor3.withValues(alpha: opacity);
    final angle = -math.pi / 2 + math.pi * 2 * progress;
    canvas.drawArc(rect, angle, math.pi * .8, false, paint);
    canvas.drawArc(
      rect,
      angle + math.pi,
      math.pi * .25,
      false,
      paint..color = AppColors.logoColor3.withValues(alpha: opacity * .3),
    );
  }

  @override
  bool shouldRepaint(_LogoOrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
