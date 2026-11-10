library loading;

import 'dart:math';

import 'package:flutter/material.dart';

const double _kMinIndicatorSize = 36.0;

const double _kDefaultStrokeWidth = 2;

enum Indicator { ballBeat }

/// Entrance of the loading.
class LoadingIndicator extends StatelessWidget {
  /// Indicate which type.
  final Indicator indicatorType;

  /// The color you draw on the shape.
  final List<Color>? colors;
  final Color? backgroundColor;

  /// The stroke width of line.
  final double? strokeWidth;

  /// Applicable to which has cut edge of the shape
  final Color? pathBackgroundColor;

  /// Animation status, true will pause the animation, default is false
  final bool pause;

  const LoadingIndicator({
    Key? key,
    required this.indicatorType,
    this.colors,
    this.backgroundColor,
    this.strokeWidth,
    this.pathBackgroundColor,
    this.pause = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> safeColors = colors == null || colors!.isEmpty
        ? [Theme.of(context).primaryColor]
        : colors!;
    return DecorateContext(
      decorateData: DecorateData(
        indicator: indicatorType,
        colors: safeColors,
        strokeWidth: strokeWidth,
        pathBackgroundColor: pathBackgroundColor,
        pause: pause,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(color: backgroundColor, child: BallBeat()),
      ),
    );
  }
}

enum Shape {
  circle,
  ringThirdFour,
  rectangle,
  ringTwoHalfVertical,
  ring,
  line,
  triangle,
  arc,
  circleSemi,
}

/// Wrapper class for basic shape.
class IndicatorShapeWidget extends StatelessWidget {
  final Shape shape;
  final double? data;

  /// The index of shape in the widget.
  final int index;

  const IndicatorShapeWidget({
    Key? key,
    required this.shape,
    this.data,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    final color = decorateData.colors[index % decorateData.colors.length];

    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinIndicatorSize,
        minHeight: _kMinIndicatorSize,
      ),
      child: CustomPaint(
        painter: _ShapePainter(
          color,
          shape,
          data,
          decorateData.strokeWidth,
          pathColor: decorateData.pathBackgroundColor,
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Paint _paint;
  final double? data;
  final double strokeWidth;
  final Color? pathColor;

  _ShapePainter(
    this.color,
    this.shape,
    this.data,
    this.strokeWidth, {
    this.pathColor,
  }) : _paint = Paint()..isAntiAlias = true,
       super();

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case Shape.circle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case Shape.ringThirdFour:
        if (pathColor != null) {
          _paint
            ..color = pathColor!
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2,
            _paint,
          );
        }
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.shortestSide / 2,
          ),
          -3 * pi / 4,
          3 * pi / 2,
          false,
          _paint,
        );
        break;
      case Shape.rectangle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, _paint);
        break;
      case Shape.ringTwoHalfVertical:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        final rect = Rect.fromLTWH(
          size.width / 4,
          size.height / 4,
          size.width / 2,
          size.height / 2,
        );
        canvas.drawArc(rect, -3 * pi / 4, pi / 2, false, _paint);
        canvas.drawArc(rect, 3 * pi / 4, -pi / 2, false, _paint);
        break;
      case Shape.ring:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case Shape.line:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(size.shortestSide / 2),
          ),
          _paint,
        );
        break;
      case Shape.triangle:
        final offsetY = size.height / 4;
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        Path path = Path()
          ..moveTo(0, size.height - offsetY)
          ..lineTo(size.width / 2, size.height / 2 - offsetY)
          ..lineTo(size.width, size.height - offsetY)
          ..close();
        canvas.drawPath(path, _paint);
        break;
      case Shape.arc:
        assert(data != null);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(
          Offset.zero & size,
          data!,
          pi * 2 - 2 * data!,
          true,
          _paint,
        );
        break;
      case Shape.circleSemi:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, -pi * 6, -2 * pi / 3, false, _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      data != oldDelegate.data ||
      strokeWidth != oldDelegate.strokeWidth ||
      pathColor != oldDelegate.pathColor;
}

class BallBeat extends StatefulWidget {
  const BallBeat({Key? key}) : super(key: key);

  @override
  State<BallBeat> createState() => _BallBeatState();
}

class _BallBeatState extends State<BallBeat> with TickerProviderStateMixin {
  static const int _durationInMills = 700;
  static const List<int> _delayInMills = [350, 0, 350, 0, 350, 0];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _scaleAnimations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _animationControllers.add(
        AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills),
        ),
      );
      _scaleAnimations.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 0.3,
            ).chain(CurveTween(curve: Curves.easeOutQuad)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 0.3,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInQuad)),
            weight: 1,
          ),
        ]).animate(_animationControllers[i]),
      );
      _animationControllers[i].repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        List<Widget> widgets = List.filled(11, Container());
        for (int i = 0; i < 11; i++) {
          if (i.isEven) {
            widgets[i] = Expanded(
              child: FadeTransition(
                opacity: _scaleAnimations[i ~/ 2],
                child: IndicatorShapeWidget(shape: Shape.circle, index: i ~/ 2),
              ),
            );
          } else {
            widgets[i] = const SizedBox(width: 2);
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgets,
        );
      },
    );
  }
}

/// Information about a piece of animation (e.g., color).
class DecorateData {
  final Color? backgroundColor;
  final Indicator indicator;

  /// It will promise at least one value in the collection.
  final List<Color> colors;
  final double? _strokeWidth;

  /// Applicable to which has cut edge of the shape
  final Color? pathBackgroundColor;

  /// Animation status, true will pause the animation
  final bool pause;

  const DecorateData({
    required this.indicator,
    required this.colors,
    this.backgroundColor,
    double? strokeWidth,
    this.pathBackgroundColor,
    required this.pause,
  }) : _strokeWidth = strokeWidth,
       assert(colors.length > 0);

  double get strokeWidth => _strokeWidth ?? _kDefaultStrokeWidth;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecorateData &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          indicator == other.indicator &&
          _strokeWidth == other._strokeWidth &&
          pathBackgroundColor == other.pathBackgroundColor &&
          pause == other.pause;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      indicator.hashCode ^
      colors.hashCode ^
      _strokeWidth.hashCode ^
      pathBackgroundColor.hashCode ^
      pause.hashCode;

  @override
  String toString() {
    return 'DecorateData{backgroundColor: $backgroundColor, indicator: $indicator, colors: $colors, strokeWidth: $_strokeWidth, pathBackgroundColor: $pathBackgroundColor, pause: $pause}';
  }
}

/// Establishes a subtree in which decorate queries resolve to the given data.
class DecorateContext extends InheritedWidget {
  final DecorateData decorateData;

  const DecorateContext({
    Key? key,
    required this.decorateData,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(DecorateContext oldWidget) =>
      oldWidget.decorateData != decorateData;

  static DecorateContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }
}
