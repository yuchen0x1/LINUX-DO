import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../const/app_theme.dart';
import '../topic_detail_controller.dart';

/// 楼层选择
class PostsSelector extends StatefulWidget {
  final int postsCount;
  final int currentIndex;
  final Function(int) onIndexChanged;
  final TopicDetailController controller;

  const PostsSelector({
    Key? key,
    required this.postsCount,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.controller,
  }) : super(key: key);

  @override
  State<PostsSelector> createState() => _PostsSelectorState();
}

class _PostsSelectorState extends State<PostsSelector>
    with SingleTickerProviderStateMixin {
  late double _dragPosition;
  late int _currentIndex;
  final double _defaultHeight = 120.w;
  final double _handleHeight = 22.w;
  bool _isLongPressed = false;
  double _expandedHeight = 0.0;
  Timer? _loadDataTimer;

  late AnimationController _expandController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _dragPosition = _calculateInitialPosition();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: _defaultHeight, end: _defaultHeight)
        .animate(
          CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(PostsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在非拖动状态且索引确实改变时才更新
    if (!_isLongPressed && widget.currentIndex != _currentIndex) {
      setState(() {
        _currentIndex = widget.currentIndex;
        _dragPosition = _calculateInitialPosition();
      });
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _loadDataTimer?.cancel();
    super.dispose();
  }

  double _calculateInitialPosition() {
    if (widget.postsCount <= 1) return 0;
    return (_currentIndex / (widget.postsCount - 1)) *
        (_defaultHeight - _handleHeight);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    setState(() {
      final maxHeight = _isLongPressed
          ? _heightAnimation.value
          : _defaultHeight;
      _dragPosition = (_dragPosition + details.delta.dy).clamp(
        0,
        maxHeight - _handleHeight,
      );

      // 计算新的索引，但只更新内部状态
      if (widget.postsCount > 1) {
        final progress = _dragPosition / (maxHeight - _handleHeight);
        // 计算新的索引 (0-based)
        final newIndex = (progress * (widget.postsCount - 1)).round();

        if (newIndex != _currentIndex) {
          _currentIndex = newIndex;
        }
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!mounted) return;
    if (!_isLongPressed) {
      final targetIndex = _currentIndex;
      // 拖动结束时通知 controller 更新索引
      widget.controller.updatePostSelectorIndex(targetIndex);
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressed = true;
      _currentIndex = widget.currentIndex;
      _dragPosition = _calculateInitialPosition();
    });
    _expandController.forward();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    // 计算在默认高度下的相对位置
    final currentProgress =
        _dragPosition / (_heightAnimation.value - _handleHeight);
    final newPosition = currentProgress * (_defaultHeight - _handleHeight);

    setState(() {
      _isLongPressed = false;
      _dragPosition = newPosition.clamp(0.0, _defaultHeight - _handleHeight);
    });

    // 长按结束时通知 controller 更新索引
    widget.controller.updatePostSelectorIndex(_currentIndex);
    _expandController.reverse();
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isLongPressed) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    setState(() {
      _dragPosition = (localPosition.dy - _handleHeight / 2).clamp(
        0,
        _heightAnimation.value - _handleHeight,
      );

      // 计算新的索引，但只更新内部状态
      final progress = _dragPosition / (_heightAnimation.value - _handleHeight);
      final newIndex = (progress * (widget.postsCount - 1)).round();

      if (newIndex != _currentIndex) {
        _currentIndex = newIndex;
      }
    });
  }

  void _updateExpandedHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    final maxExpandedHeight =
        screenHeight -
        appBarHeight -
        MediaQuery.of(context).padding.bottom -
        100.w;

    final newExpandedHeight = widget.postsCount > 200
        ? maxExpandedHeight
        : screenHeight * 0.5;

    if (_expandedHeight != newExpandedHeight) {
      _expandedHeight = newExpandedHeight;
      _heightAnimation =
          Tween<double>(begin: _defaultHeight, end: _expandedHeight).animate(
            CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateExpandedHeight(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          onLongPressStart: _handleLongPressStart,
          onLongPressEnd: _handleLongPressEnd,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          child: Container(
            width: 22.w,
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.all(Radius.circular(16)).w,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: _dragPosition,
                  child: Container(
                    width: 22.w,
                    height: _handleHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(16))
                          .w,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentIndex + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.w,
                          fontFamily: AppFontFamily.dinPro,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
