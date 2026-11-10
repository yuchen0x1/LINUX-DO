import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import '../chat/chat_list_page.dart';
import '../topics/topics_page.dart';
import '../category/category_topics_page.dart';
import '../profile/profile_page.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 计算底部导航栏总高度 = 基础高度 + 底部安全区域
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 46.w + bottomPadding;

    return Scaffold(
      body: Obx(
        () => LazyLoadIndexedStack(
          index: controller.currentTab.value,
          children: const [
            TopicsPage(),
            CategoryTopicsPage(),
            SizedBox(), // 占位
            ChatPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: controller.topicsController.isBottomBarVisible.value
              ? navBarHeight
              : 0,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SalomonBottomBar(
              duration: const Duration(milliseconds: 200),
              selectedItemColor:
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              backgroundColor: Colors.transparent,
              currentIndex: controller.currentTab.value,
              onTap: (index) {
                if (index == controller.currentTab.value && index == 0) {
                  controller.topicsController.currentTabController.onRefresh();
                } else {
                  controller.switchTab(index);
                }
              },
              itemPadding:
                  EdgeInsets.symmetric(vertical: 6.w, horizontal: 11.w),
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(CupertinoIcons.square_list_fill),
                  title: const Text(
                    '帖子',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(CupertinoIcons.square_split_2x2_fill),
                  title: const Text(
                    '分类',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                // 中间发布按钮 - 凸起 FAB 样式
                SalomonBottomBarItem(
                  icon: Container(
                    width: 44.w,
                    height: 44.w,
                    margin: EdgeInsets.only(bottom: 8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.75),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.4),
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
                      if (controller.badgeCount[3] != null)
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
                              '${controller.badgeCount[3]}',
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
                  title: const Text(
                    '私信',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(CupertinoIcons.person_crop_square_fill),
                  title: const Text(
                    '我的',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
