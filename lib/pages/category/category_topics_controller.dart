import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/pages/category/activities/activity_page.dart';
import 'package:linux_do/pages/category/widgets/my_bookmarks/my_bookmarks_page.dart';
import 'package:linux_do/widgets/drawer_menu.dart';

import '../../const/app_const.dart';
import '../../controller/base_controller.dart';
import 'birthday/birthday_controller.dart';
import 'birthday/birthday_page.dart';
import 'group/group_controller.dart';
import 'group/group_page.dart';
import 'leaderboard/leaderboard_controller.dart';
import 'leaderboard/leaderboard_page.dart';
import 'widgets/articles/docs_page.dart';
import 'widgets/my_posts/my_posts_page.dart';
import 'widgets/my_posts/my_posts_controller.dart';
import 'widgets/my_bookmarks/my_bookmarks_controller.dart';
import 'widgets/articles/docs_controller.dart';
import 'activities/activity_controller.dart';

class CategoryTopicsController extends BaseController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _currentTabIndex = 0.obs;
  int get currentTabIndex => _currentTabIndex.value;

  set currentTabIndex(int value) {
    _currentTabIndex.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    Get.put(MyPostsController(), tag: 'my_posts', permanent: true);
    Get.put(MyBookmarksController(), tag: 'my_bookmarks', permanent: true);
    Get.put(DocsController(), tag: 'docs', permanent: true);
    Get.put(LeaderboardController());
    Get.put(GroupController());
    Get.put(EventController());
    Get.put(BirthdayController());
    Get.lazyPut(() => DrawerMenuController());
  }

  final menuItems = [
    {
      'icon': CupertinoIcons.person_2_fill,
      'title': AppConst.categoryTopics.groups,
      'subtitle': 'groups',
      'colors': [const Color(0xFF5B86E5), const Color(0xFF36D1DC)],
    },
    {
      'icon': CupertinoIcons.chart_bar_square_fill,
      'title': AppConst.categoryTopics.ranking,
      'subtitle': 'ranking',
      'colors': [const Color(0xFFf46b45), const Color(0xFFFFB75E)],
    },
    {
      'icon': CupertinoIcons.calendar_circle_fill,
      'title': AppConst.categoryTopics.activities,
      'subtitle': 'activities',
      'colors': [const Color(0xFF45B649), const Color(0xFFDCE35B)],
    },
    {
      'icon': CupertinoIcons.gift_fill,
      'title': AppConst.categoryTopics.birthdays,
      'subtitle': 'birthday',
      'colors': [const Color(0xFF4e54c8), const Color(0xFF8f94fb)],
    },
  ];

  Widget createCurrent() {
    switch (currentTabIndex) {
      case 0:
        return const MyPostsPage();
      case 1:
        return const MyBookmarksPage();
      case 2:
        return const DocsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  void onMenuTap(int index) {
    if (index == 0) {
      Get.to(() => const GroupPage());
    } else if (index == 1) {
      Get.to(() => const LeaderboardPage());
    } else if (index == 2) {
      Get.to(() => const ActivityPage());
    } else if (index == 3) {
      Get.to(() => const BirthdayPage());
    }
  }
}
