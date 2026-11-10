import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一的网络图片组件。
///
/// 相比直接用 [CachedNetworkImage]，这里做了两件容易被忽略但对长列表很关键的事：
/// 1. 按控件尺寸 × 设备像素比计算 [memCacheWidth]，让解码后的位图尺寸贴近实际
///    显示尺寸。列表里几百张头像如果都按原图分辨率解码，很容易在中低端机上
///    触发 OOM。
/// 2. 占位/错误态的圆角、尺寸计算补上空值兜底，避免 circle 模式在未显式指定
///    宽高时抛异常。
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool circle;
  final bool showBorder;
  final Color? borderColor;
  final bool showInnerBorder;
  final Color? innerBorderColor;
  final double? innerBorderWidth;

  /// 解码时的最大宽度（物理像素）。不传则按 [width] × 设备像素比推导；
  /// 两者都没有时不限制。
  final int? memCacheWidth;

  /// 解码时的最大高度（物理像素），规则同 [memCacheWidth]。
  final int? memCacheHeight;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.circle = false,
    this.showBorder = false,
    this.borderColor,
    this.showInnerBorder = false,
    this.innerBorderColor,
    this.innerBorderWidth,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final decodeWidth =
        memCacheWidth ?? _deriveCacheSize(width, devicePixelRatio);
    final decodeHeight =
        memCacheHeight ?? _deriveCacheSize(height, devicePixelRatio);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: decodeWidth,
      memCacheHeight: decodeHeight,
      // 尺寸参与缓存键，避免同一 URL 的不同展示尺寸互相顶掉解码缓存
      cacheKey: decodeWidth == null && decodeHeight == null
          ? null
          : '${imageUrl!}_${decodeWidth ?? 'x'}_${decodeHeight ?? 'x'}',
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
    );

    // 圆形或圆角
    if (circle || borderRadius != null) {
      image = ClipRRect(
        borderRadius: circle
            ? BorderRadius.circular(_shortestSide() / 2)
            : borderRadius ?? BorderRadius.zero,
        child: image,
      );
    }

    // 添加内边框
    if (showInnerBorder) {
      final innerBorderW = innerBorderWidth ?? 2.w;

      // 内边框和图片组合
      image = Container(
        padding: EdgeInsets.all(innerBorderW),
        decoration: BoxDecoration(
          color: innerBorderColor ?? Colors.white,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: !circle ? borderRadius : null,
        ),
        child: image,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: circle
            ? BorderRadius.circular(_shortestSide() / 2)
            : borderRadius,
        border: showBorder
            ? Border.all(
                color: borderColor ?? Theme.of(context).primaryColor,
                width: 1.w,
              )
            : null,
      ),
      child: image,
    );
  }

  /// 把逻辑像素换算成物理像素，并留 10% 余量给缩放动画。
  static int? _deriveCacheSize(double? logical, double devicePixelRatio) {
    if (logical == null || logical <= 0) return null;
    return (logical * devicePixelRatio * 1.1).round();
  }

  /// 圆形半径基准：两者都有时取小值，否则取给定的一方，都没有时退回 24。
  double _shortestSide() {
    final w = width;
    final h = height;
    if (w != null && h != null) return math.min(w, h);
    return w ?? h ?? 24;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: circle
                ? BorderRadius.circular(_shortestSide() / 2)
                : borderRadius,
          ),
          child: Icon(
            Icons.account_circle_sharp,
            size: _shortestSide() * 0.5,
            color: Colors.grey.withValues(alpha: .3),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: .1),
            borderRadius: circle
                ? BorderRadius.circular(_shortestSide() / 2)
                : borderRadius,
          ),
          child: Icon(
            Icons.broken_image_outlined,
            size: _shortestSide() * 0.5,
            color: Colors.grey.withValues(alpha: .3),
          ),
        );
  }
}
