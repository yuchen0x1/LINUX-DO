import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

import '../const/app_images.dart';
import 'dis_button.dart';

enum ViewState { loading, error, empty, content }

class StateView extends GetView {
  final ViewState state;
  final Widget child;
  final String? errorMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  final int shimmerCount;
  final Widget? shimmerView;

  const StateView({
    super.key,
    required this.state,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
    this.shimmerCount = 7,
    this.shimmerView,
    required this.child,
  });

  /// 创建加载状态视图的工厂方法
  static Widget loading({int shimmerCount = 7, Widget? shimmerView}) {
    return StateView(
      state: ViewState.loading,
      shimmerCount: shimmerCount,
      shimmerView: shimmerView,
      child: const SizedBox(),
    );
  }

  /// 创建空状态视图的工厂方法
  static Widget empty({String? message, VoidCallback? onRetry}) {
    return StateView(
      state: ViewState.empty,
      emptyMessage: message,
      onRetry: onRetry,
      child: const SizedBox(),
    );
  }

  /// 创建错误状态视图的工厂方法
  static Widget error({String? message, VoidCallback? onRetry}) {
    return StateView(
      state: ViewState.error,
      errorMessage: message,
      onRetry: onRetry,
      child: const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return shimmerView == null
            ? _buildShimmerLoading(context)
            : shimmerView!;
      case ViewState.error:
        return _buildError(context);
      case ViewState.empty:
        return _buildEmpty(context);
      case ViewState.content:
        return child;
    }
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF262626) : Colors.white,
      highlightColor: isDark
          ? const Color(0xFF303030)
          : const Color(0xFFF5F5F5),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        itemCount: shimmerCount,
        itemBuilder: (_, __) => ShimmerItem(context: context),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return StateViewError(errorMessage: errorMessage, onRetry: onRetry);
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          30.vGap,
          Image.asset(AppImages.getEmpty(context), width: 180.w),
          16.vGap,
          Text(
            // 调用方传入的自定义文案优先，否则用默认空态提示
            emptyMessage ?? AppConst.stateHint.empty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.w,
              color: Theme.of(context).hintColor,
            ),
          ),
          if (onRetry != null) ...[
            16.vGap,
            DisButton(text: '重试', size: ButtonSize.small, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  const ShimmerItem({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark
        ? const Color(0xFF303030)
        : const Color(0xFFF5F5F5);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像占位
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              // 标题占位
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    SizedBox(height: 8.w),
                    Container(
                      width: 100.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          // 内容占位
          Container(
            width: double.infinity,
            height: 12.w,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          SizedBox(height: 8.w),
          Container(
            width: 200.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerDetails extends GetView {
  const ShimmerDetails({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF262626) : Colors.white,
      highlightColor: isDark
          ? const Color(0xFF303030)
          : const Color(0xFFF5F5F5),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 4.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class StateViewError extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  const StateViewError({super.key, this.errorMessage, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          30.vGap,
          Image.asset(AppImages.getNetError(context), width: 180.w),
          16.vGap,
          Text(
            errorMessage ?? AppConst.stateHint.error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.w,
              color: Theme.of(context).hintColor,
            ),
          ),
          if (onRetry != null) ...[
            16.vGap,
            DisButton(text: '重试', size: ButtonSize.small, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
