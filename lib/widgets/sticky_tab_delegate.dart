import 'package:flutter/material.dart';

import '../const/app_colors.dart';

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyTabBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.transparent, child: child);
  }
}
