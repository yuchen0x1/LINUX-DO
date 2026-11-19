import 'package:flutter/material.dart';

/// A stable content slot keeps loaded tabs alive while the window changes size.
class AdaptiveHomeScaffold extends StatelessWidget {
  const AdaptiveHomeScaffold({
    super.key,
    required this.body,
    required this.bottomBar,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.unreadCount,
  });

  final Widget body;
  final Widget bottomBar;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? unreadCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        return Scaffold(
          body: SafeArea(
            top: false,
            bottom: wide,
            child: Row(
              children: [
                SizedBox(
                  width: wide ? 88 : 0,
                  child: wide
                      ? NavigationRail(
                          selectedIndex: currentIndex,
                          labelType: NavigationRailLabelType.all,
                          onDestinationSelected: onDestinationSelected,
                          destinations: [
                            const NavigationRailDestination(
                              icon: Icon(Icons.forum_outlined),
                              selectedIcon: Icon(Icons.forum),
                              label: Text('帖子'),
                            ),
                            const NavigationRailDestination(
                              icon: Icon(Icons.grid_view_outlined),
                              label: Text('分类'),
                            ),
                            const NavigationRailDestination(
                              icon: Icon(Icons.add_circle_outline),
                              label: Text('发布'),
                            ),
                            NavigationRailDestination(
                              icon: Badge(
                                isLabelVisible:
                                    unreadCount != null && unreadCount != '0',
                                label: Text(unreadCount ?? ''),
                                child: const Icon(Icons.chat_bubble_outline),
                              ),
                              label: const Text('消息'),
                            ),
                            const NavigationRailDestination(
                              icon: Icon(Icons.person_outline),
                              label: Text('我的'),
                            ),
                          ],
                        )
                      : null,
                ),
                Expanded(child: body),
              ],
            ),
          ),
          bottomNavigationBar: wide ? null : bottomBar,
        );
      },
    );
  }
}
