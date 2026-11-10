import 'package:flutter/material.dart';

class GlowingTextSweep extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final Duration sweepDuration;

  const GlowingTextSweep({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.glowColor = Colors.white,
    this.sweepDuration = const Duration(seconds: 2),
  });

  @override
  _GlowingTextSweepState createState() => _GlowingTextSweepState();
}

class _GlowingTextSweepState extends State<GlowingTextSweep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.sweepDuration,
      vsync: this,
    )..repeat(); // 循环
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            widget.glowColor.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: [
            _animation.value - 0.5,
            _animation.value,
            _animation.value + 0.5,
          ],
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
