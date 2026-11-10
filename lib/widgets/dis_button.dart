import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonType {
  primary, // 主按钮
  secondary, // 次要按钮
  text, // 文本按钮
  outline, // 边框按钮
  transform, // 变换按钮 - 支持加载动画和宽度变换效果
}

enum ButtonSize {
  small, // 小按钮
  medium, // 中等按钮
  large, // 大按钮
}

/// LiDo主题按钮组件
/// 支持多种按钮类型:
/// - primary: 主按钮（渐变色）
/// - secondary: 次要按钮
/// - text: 文本按钮
/// - outline: 边框按钮
/// - transform: 变换按钮(支持加载动画和宽度变换)（渐变色）
class DisButton extends StatefulWidget {
  final String? text; // 按钮文本
  final VoidCallback? onPressed; // 点击回调
  final ButtonType type; // 按钮类型
  final ButtonSize size; // 按钮大小
  final bool? loading; // 是否处于加载状态
  final bool block; // 是否块级按钮
  final IconData? icon; // 图标
  final double? width; // 自定义宽度
  final EdgeInsetsGeometry? margin; // 外边距
  final bool useWidthAnimation; // 是否使用宽度动画(仅transform类型有效)
  final Widget? loadingStateWidget; // 自定义加载组件(仅transform类型有效)
  final bool? disabled; // 是否禁用按钮
  final double? spacing; // Add spacing property
  final double? fontSize; // 字体大小
  final double? borderRadius; // 圆角大小

  const DisButton({
    super.key,
    this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.loading,
    this.block = false,
    this.icon,
    this.width,
    this.margin,
    this.useWidthAnimation = false,
    this.loadingStateWidget,
    this.disabled,
    this.spacing,
    this.fontSize,
    this.borderRadius,
  });

  @override
  State<DisButton> createState() => _DisButtonState();
}

class _DisButtonState extends State<DisButton> with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  Animation? _anim;
  AnimationController? _animController;
  final Duration _duration = const Duration(milliseconds: 250);
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void _reset() {
    _width = widget.width ?? double.infinity;
    _height = _getHeight();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = widget.loading ?? false;
    final disabled = widget.disabled ?? false;
    final onPressed = (loading || disabled) ? null : widget.onPressed;

    final style = _getButtonStyle(theme);

    Widget child;
    if (widget.type == ButtonType.primary) {
      child = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: .65),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: _buildChild(theme),
        ),
      );
    } else if (widget.type == ButtonType.transform) {
      if (widget.useWidthAnimation) {
        child = PhysicalModel(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
          child: SizedBox(
            key: _globalKey,
            height: _height,
            width: _width,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: .65),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
              ),
              child: ElevatedButton(
                onPressed: loading ? null : _handlePress,
                style: style,
                child: _buildChild(theme),
              ),
            ),
          ),
        );
      } else {
        child = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withValues(alpha: .65),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: _buildChild(theme),
          ),
        );
      }
    } else {
      child = ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: _buildChild(theme),
      );
    }

    if (widget.block) {
      child = Center(child: child);
    }

    return Container(
      width: widget.block ? double.infinity : widget.width,
      height: _height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
      ),
      child: child,
    );
  }

  Widget _buildChild(ThemeData theme) {
    final fontSize = widget.fontSize ?? _getFontSize();
    final iconSize = _getIconSize();

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: iconSize,
            color: widget.type == ButtonType.primary
                ? Colors.white
                : theme.primaryColor,
          ),
          SizedBox(width: widget.spacing ?? 4.w),
        ],
        if ((widget.loading ?? false)) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child:
                widget.loadingStateWidget ??
                CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getLoadingColor(theme),
                  ),
                ),
          ),
        ] else
          Text(
            widget.text ?? '',
            style: TextStyle(
              fontSize: fontSize,
              color:
                  widget.type == ButtonType.primary ||
                      widget.type == ButtonType.transform
                  ? Colors.white
                  : theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );

    return child;
  }

  Future<void> _handlePress() async {
    if ((widget.loading ?? false) || widget.onPressed == null) return;

    if (widget.useWidthAnimation) {
      _forward();
      try {
        await Future(() => widget.onPressed!());
      } finally {
        if (mounted) {
          _reverse();
        }
      }
    } else {
      widget.onPressed!();
    }
  }

  void _forward() {
    double initialWidth = _globalKey.currentContext!.size!.width;
    double targetWidth = _height;

    _animController = AnimationController(duration: _duration, vsync: this);
    _anim = Tween(begin: 0.0, end: 1.0).animate(_animController!)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - targetWidth) * _anim!.value);
        });
      });

    _animController!.forward();
  }

  void _reverse() {
    _animController!.reverse();
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 16.w);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 20.w);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.w;
      case ButtonSize.medium:
        return 14.w;
      case ButtonSize.large:
        return 16.w;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 32.w;
      case ButtonSize.medium:
        return 40.w;
      case ButtonSize.large:
        return 48.w;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14.w;
      case ButtonSize.medium:
        return 16.w;
      case ButtonSize.large:
        return 18.w;
    }
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final baseStyle = switch (widget.type) {
      ButtonType.primary => ElevatedButton.styleFrom(
        textStyle: TextStyle(fontSize: widget.fontSize),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: _getPadding(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
        ),
      ),
      ButtonType.secondary => ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor.withValues(alpha: .1),
        textStyle: TextStyle(fontSize: widget.fontSize),
        foregroundColor: theme.primaryColor,
        padding: _getPadding(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
        ),
      ),
      ButtonType.text =>
        TextButton.styleFrom(
          foregroundColor: theme.primaryColor,
          padding: _getPadding(),
          textStyle: TextStyle(fontSize: widget.fontSize),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.hovered)) {
              return theme.primaryColor.withValues(alpha: .05);
            }
            return null;
          }),
        ),
      ButtonType.outline =>
        OutlinedButton.styleFrom(
          foregroundColor: theme.primaryColor,
          padding: _getPadding(),
          textStyle: TextStyle(fontSize: widget.fontSize),
          side: BorderSide(color: theme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.hovered)) {
              return theme.primaryColor.withValues(alpha: .05);
            }
            return Colors.white;
          }),
        ),
      ButtonType.transform => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: widget.fontSize),
        padding: _getPadding(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.w),
        ),
      ),
    };

    return baseStyle;
  }

  Color _getLoadingColor(ThemeData theme) {
    return switch (widget.type) {
      ButtonType.primary || ButtonType.transform => Colors.white,
      _ => theme.primaryColor,
    };
  }
}

/// 按钮状态
enum LiDoTransformButtonState {
  idle, // 空闲状态
  loading, // 加载状态
}

/// 按钮类型
enum LiDoTransformButtonType {
  elevated, // 凸起按钮（渐变色）
  outlined, // 边框按钮
  text, // 文本按钮
}

/// 变换按钮组件
class LiDoTransformButton extends StatefulWidget {
  /// 空闲状态下的内容组件
  final Widget idleStateWidget;

  /// 加载状态下的内容组件
  final Widget loadingStateWidget;

  /// 按钮类型
  final LiDoTransformButtonType type;

  /// 是否启用宽度动画
  final bool useWidthAnimation;

  /// 是否强制加载状态组件使用相等尺寸
  final bool useEqualLoadingStateWidgetDimension;

  /// 按钮宽度
  final double width;

  /// 按钮高度
  final double height;

  /// 内容间距
  final double contentGap;

  /// 圆角大小
  final double borderRadius;

  /// 阴影高度
  final double elevation;

  /// 按钮颜色
  final Color buttonColor;

  /// 点击回调
  final Function? onPressed;

  const LiDoTransformButton({
    super.key,
    required this.idleStateWidget,
    required this.loadingStateWidget,
    this.type = LiDoTransformButtonType.elevated,
    this.useWidthAnimation = true,
    this.useEqualLoadingStateWidgetDimension = true,
    this.width = double.infinity,
    this.height = 40.0,
    this.contentGap = 0.0,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.buttonColor = Colors.blueAccent,
    this.onPressed,
  });

  @override
  State createState() => _LiDoTransformButtonState();
}

class _LiDoTransformButtonState extends State<LiDoTransformButton>
    with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();

  Animation? _anim;
  AnimationController? _animController;
  final Duration _duration = const Duration(milliseconds: 250);
  LiDoTransformButtonState _state = LiDoTransformButtonState.idle;
  late double _width;
  late double _height;
  late double _borderRadius;

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _reset();
    super.deactivate();
  }

  @override
  void initState() {
    _reset();
    super.initState();
  }

  void _reset() {
    _state = LiDoTransformButtonState.idle;
    _width = widget.width;
    _height = widget.height;
    _borderRadius = widget.borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_borderRadius),
      child: SizedBox(
        key: _globalKey,
        height: _height,
        width: _width,
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    var padding = EdgeInsets.all(widget.contentGap);
    var shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    );

    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: padding,
      backgroundColor: Colors.transparent,
      elevation: widget.elevation,
      shape: shape,
    );

    final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
      padding: padding,
      shape: shape,
      side: BorderSide(color: widget.buttonColor),
    );

    final ButtonStyle textButtonStyle = TextButton.styleFrom(padding: padding);

    switch (widget.type) {
      case LiDoTransformButtonType.elevated:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: .8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: _onButtonPressed(),
            child: _buildChildren(context),
          ),
        );
      case LiDoTransformButtonType.outlined:
        return TextButton(
          style: outlinedButtonStyle,
          onPressed: _onButtonPressed(),
          child: _buildChildren(context),
        );
      case LiDoTransformButtonType.text:
        return TextButton(
          style: textButtonStyle,
          onPressed: _onButtonPressed(),
          child: _buildChildren(context),
        );
    }
  }

  Widget _buildChildren(BuildContext context) {
    double contentGap = widget.type == LiDoTransformButtonType.text
        ? 0.0
        : widget.contentGap;
    Widget contentWidget;

    switch (_state) {
      case LiDoTransformButtonState.idle:
        contentWidget = widget.idleStateWidget;
        break;
      case LiDoTransformButtonState.loading:
        contentWidget = widget.loadingStateWidget;
        if (widget.useEqualLoadingStateWidgetDimension) {
          contentWidget = SizedBox.square(
            dimension: widget.height - (contentGap * 2),
            child: widget.loadingStateWidget,
          );
        }
        break;
    }

    return contentWidget;
  }

  VoidCallback _onButtonPressed() {
    if (widget.onPressed == null) {
      return () {};
    }
    return _manageLoadingState;
  }

  Future _manageLoadingState() async {
    if (_state != LiDoTransformButtonState.idle) {
      return;
    }

    dynamic onIdle;

    if (widget.useWidthAnimation) {
      _toProcessing();
      _forward((status) {
        if (status == AnimationStatus.dismissed) {
          _toDefault();
          if (onIdle != null &&
              (onIdle is VoidCallback || onIdle is FormFieldValidator)) {
            onIdle();
          }
        }
      });
      onIdle = await widget.onPressed!();
      _reverse();
    } else {
      _toProcessing();
      onIdle = await widget.onPressed!();
      _toDefault();
      if (onIdle != null &&
          (onIdle is VoidCallback || onIdle is FormFieldValidator)) {
        onIdle();
      }
    }
  }

  void _toProcessing() {
    setState(() {
      _state = LiDoTransformButtonState.loading;
    });
  }

  void _toDefault() {
    if (mounted) {
      setState(() {
        _state = LiDoTransformButtonState.idle;
      });
    } else {
      _state = LiDoTransformButtonState.idle;
    }
  }

  void _forward(AnimationStatusListener stateListener) {
    double initialWidth = _globalKey.currentContext!.size!.width;
    double initialBorderRadius = widget.borderRadius;
    double targetWidth = _height;
    double targetBorderRadius = _height / 2;

    _animController = AnimationController(duration: _duration, vsync: this);
    _anim = Tween(begin: 0.0, end: 1.0).animate(_animController!)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - targetWidth) * _anim!.value);
          _borderRadius =
              initialBorderRadius -
              ((initialBorderRadius - targetBorderRadius) * _anim!.value);
        });
      })
      ..addStatusListener(stateListener);

    _animController!.forward();
  }

  void _reverse() {
    _animController!.reverse();
  }
}
