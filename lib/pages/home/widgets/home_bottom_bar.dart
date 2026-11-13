import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.isVisible,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount,
  });

  final bool isVisible;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 由实际按钮尺寸决定高度，避免固定高度裁掉发布按钮和安全区。
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: isVisible ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              maintainBottomViewPadding: true,
              child: Padding(
                // 在系统手势/三键区域之上再留出间距，方便点击。
                padding: EdgeInsets.only(bottom: 8.w),
                child: SalomonBottomBar(
                  duration: const Duration(milliseconds: 200),
                  selectedItemColor:
                      theme.bottomNavigationBarTheme.selectedItemColor,
                  unselectedItemColor:
                      theme.bottomNavigationBarTheme.unselectedItemColor,
                  backgroundColor: Colors.transparent,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  itemPadding: EdgeInsets.symmetric(
                    vertical: 6.w,
                    horizontal: 11.w,
                  ),
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(CupertinoIcons.square_list_fill),
                      title: const Text('帖子', style: TextStyle(fontSize: 12)),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(CupertinoIcons.square_split_2x2_fill),
                      title: const Text('分类', style: TextStyle(fontSize: 12)),
                    ),
                    SalomonBottomBarItem(
                      icon: Container(
                        width: 44.w,
                        height: 44.w,
                        margin: EdgeInsets.only(bottom: 8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withValues(alpha: 0.75),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      title: const Text('发布', style: TextStyle(fontSize: 12)),
                    ),
                    SalomonBottomBarItem(
                      icon: Stack(
                        children: [
                          const Icon(CupertinoIcons.app_badge_fill),
                          if (unreadCount != null)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.w,
                                  minHeight: 16.w,
                                ),
                                child: Text(
                                  unreadCount!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.w,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: const Text('私信', style: TextStyle(fontSize: 12)),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(CupertinoIcons.person_crop_square_fill),
                      title: const Text('我的', style: TextStyle(fontSize: 12)),
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
