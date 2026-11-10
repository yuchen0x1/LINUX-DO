import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dis_loading.dart';

class DisSmartRefresher extends StatelessWidget {
  final RefreshController controller;
  final Widget child;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final bool enablePullDown;
  final bool enablePullUp;
  final ScrollPhysics? physics;

  const DisSmartRefresher({
    super.key,
    required this.controller,
    required this.child,
    this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.physics = const ClampingScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      physics: physics,
      header: CustomHeader(
        builder: (context, mode) {
          if (mode == RefreshStatus.idle) {
            return const SizedBox();
          }
          return Container(
            padding: EdgeInsets.symmetric(vertical: 16.w),
            child: Center(child: DisRefreshLoading()),
          );
        },
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const SizedBox();
          } else if (mode == LoadStatus.loading) {
            body = DisRefreshLoading();
          } else if (mode == LoadStatus.failed) {
            body = Text(
              '加载失败，请重试',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12.w,
              ),
            );
          } else if (mode == LoadStatus.canLoading) {
            body = const SizedBox();
          } else {
            body = Text(
              '没有更多数据了',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12.w,
              ),
            );
          }
          return Container(
            padding: EdgeInsets.symmetric(vertical: 16.w),
            child: Center(child: body),
          );
        },
      ),
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: child,
    );
  }
}

class DisRefresh extends StatefulWidget {
  final Widget? child;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoading;
  final bool enablePullUp;
  final bool enablePullDown;
  final RefreshController? controller;

  const DisRefresh({
    super.key,
    this.child,
    required this.onRefresh,
    this.onLoading,
    this.enablePullUp = false,
    this.enablePullDown = true,
    this.controller,
  });

  @override
  State<DisRefresh> createState() => _DisRefreshState();
}

class _DisRefreshState extends State<DisRefresh> {
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = widget.controller ?? RefreshController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _refreshController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      header: WaterDropHeader(
        waterDropColor: Theme.of(context).primaryColor,
        complete: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.done, color: Colors.grey),
            Container(width: 15.0),
            Text(
              '刷新完成',
              style: TextStyle(color: Colors.grey, fontSize: 12.w),
            ),
          ],
        ),
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(
              '上拉加载',
              style: TextStyle(color: Colors.grey, fontSize: 12.w),
            );
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator(strokeWidth: 2);
          } else if (mode == LoadStatus.failed) {
            body = Text(
              '加载失败',
              style: TextStyle(color: Colors.grey, fontSize: 12.w),
            );
          } else if (mode == LoadStatus.canLoading) {
            body = Text(
              '松手加载更多',
              style: TextStyle(color: Colors.grey, fontSize: 12.w),
            );
          } else {
            body = Text(
              '没有更多数据',
              style: TextStyle(color: Colors.grey, fontSize: 12.w),
            );
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      onRefresh: () async {
        try {
          await widget.onRefresh();
          _refreshController.refreshCompleted();
        } catch (e) {
          _refreshController.refreshFailed();
        }
      },
      onLoading: widget.onLoading == null
          ? null
          : () async {
              try {
                await widget.onLoading!();
                _refreshController.loadComplete();
              } catch (e) {
                _refreshController.loadFailed();
              }
            },
      child: widget.child,
    );
  }
}
