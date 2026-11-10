import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../const/app_colors.dart';

class DisSwitch extends StatefulWidget {
  @required
  final bool value;
  final double width;

  @required
  final Function(bool) onChanged;
  final String textOff;
  final Color textOffColor;
  final String textOn;
  final Color textOnColor;
  final Color colorOn;
  final Color colorOff;
  final double textSize;
  final Duration animationDuration;
  final IconData iconOn;
  final IconData iconOff;
  final Function? onTap;
  final Function? onDoubleTap;
  final Function? onSwipe;

  DisSwitch({
    this.value = false,
    this.width = 70,
    this.textOff = "关闭",
    this.textOn = "开启",
    this.textSize = 12.0,
    this.colorOn = AppColors.success,
    this.colorOff = AppColors.disabled,
    this.iconOff = Icons.flag,
    this.iconOn = Icons.check,
    this.animationDuration = const Duration(milliseconds: 600),
    this.textOffColor = AppColors.white,
    this.textOnColor = AppColors.white,
    this.onTap,
    this.onDoubleTap,
    this.onSwipe,
    required this.onChanged,
  });

  @override
  _DisSwitchState createState() => _DisSwitchState();
}

class _DisSwitchState extends State<DisSwitch>
    with SingleTickerProviderStateMixin {
  /// 延迟初始化的变量
  late AnimationController animationController;
  late Animation<double> animation;
  late bool turnState;

  double value = 0.0;

  @override
  void dispose() {
    // 确保释放动画控制器
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: widget.animationDuration);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    animationController.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
    turnState = widget.value;

    // 在布局完成后执行一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (turnState) {
          animationController.forward();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 颜色过渡动画
    Color? transitionColor = Color.lerp(widget.colorOff, widget.colorOn, value);

    return GestureDetector(
      onDoubleTap: () {
        _action();
        widget.onDoubleTap ?? ();
      },
      onTap: () {
        _action();
        widget.onTap ?? ();
      },
      onPanEnd: (details) {
        _action();
        widget.onSwipe ?? ();
      },
      child: Container(
        padding: EdgeInsets.all(5.w),
        width: widget.width.w,
        decoration: BoxDecoration(
            color: transitionColor, borderRadius: BorderRadius.circular(50.w)),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(10.w * value, 0),
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  padding: EdgeInsets.only(right: 10.w),
                  alignment: Alignment.centerRight,
                  height: 40.w,
                  child: Text(
                    widget.textOff,
                    style: TextStyle(
                        color: widget.textOffColor,
                        fontWeight: FontWeight.w500,
                        fontSize: widget.textSize.w),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(10.w * (1 - value), 0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  padding: EdgeInsets.only(left: 5.w),
                  alignment: Alignment.centerLeft,
                  height: 40.w,
                  child: Text(
                    widget.textOn,
                    style: TextStyle(
                        color: widget.textOnColor,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.textSize.w),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset((widget.width - 40).w * value, 0),
              child: Transform.rotate(
                angle: 0,
                child: Container(
                  height: 30.w,
                  width: 30.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.white),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                          opacity: (1 - value).clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOff,
                            size: 10.w,
                            color: transitionColor,
                          ),
                        ),
                      ),
                      Center(
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOn,
                            size: 10.w,
                            color: transitionColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _action() {
    _determine(changeState: true);
  }

  _determine({bool changeState = false}) {
    setState(() {
      if (changeState) turnState = !turnState;
      (turnState)
          ? animationController.forward()
          : animationController.reverse();

      widget.onChanged(turnState);
    });
  }
}
