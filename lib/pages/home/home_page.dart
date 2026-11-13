import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

import '../chat/chat_list_page.dart';
import '../topics/topics_page.dart';
import '../category/category_topics_page.dart';
import '../profile/profile_page.dart';
import 'home_controller.dart';
import 'widgets/home_bottom_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        () => HomeBottomBar(
          isVisible: controller.topicsController.isBottomBarVisible.value,
          currentIndex: controller.currentTab.value,
          unreadCount: controller.badgeCount[3]?.toString(),
          onTap: (index) {
            if (index == controller.currentTab.value && index == 0) {
              controller.topicsController.currentTabController.onRefresh();
            } else {
              controller.switchTab(index);
            }
          },
        ),
      ),
    );
  }
}
