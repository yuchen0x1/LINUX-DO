import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_theme.dart';

class OwnerBanner extends StatelessWidget {
  final void Function()? onTap;
  const OwnerBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(50.w, 50.w),
        painter: OwnerPainter(
          color: Theme.of(context).primaryColor,
          text: 'OWNER',
        ),
      ),
    );
  }
}

class OwnerPainter extends CustomPainter {
  final Color color;
  final String text;

  OwnerPainter({required this.color, required this.text});

  final bannerPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width, size.height);

    // 旋转-45度（顺时针），使banner沿对角线放置
    canvas.rotate(-pi / 4);

    final bannerWidth = 10.w; // banner宽度
    final bannerLength = size.width * 1; // banner长度，确保足够长

    final rect = Rect.fromLTWH(
      -bannerLength / 2, // 居中放置
      -bannerWidth / 2, // 居中放置
      bannerLength,
      bannerWidth,
    );

    final gradient = LinearGradient(
      end: Alignment.centerLeft,
      begin: Alignment.centerRight,
      colors: [color, color.withValues(alpha: 0.3)],
    );

    bannerPaint.shader = gradient.createShader(rect);

    canvas.drawRect(rect, bannerPaint);

    final textStyle = TextStyle(
        color: Colors.white,
        fontSize: bannerWidth * 0.8,
        fontWeight: FontWeight.bold,
        fontFamily: AppFontFamily.dinPro);

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
          -textPainter.width / 2,
          -textPainter.height / 2,
        ));

    // 恢复画布状态
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is OwnerPainter &&
      (oldDelegate.color != color || oldDelegate.text != text);
}
