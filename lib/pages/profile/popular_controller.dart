import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/badge_detail.dart';
import 'package:linux_do/models/category_data.dart' as cg;
import 'package:linux_do/models/summary.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/utils/tag.dart';
import 'package:linux_do/widgets/browser_tips_sheet.dart';

class PopularController extends BaseController {
  // 标签索引 (0: 话题, 1: 链接, 2: 回复, 3: 类别, 4: 徽章)
  final RxInt selectedIndex = 0.obs;

  // 用于控制标签页之间的切换
  late final PageController pageController;

  // 数据源
  final summaryData = Rxn<SummaryResponse>();

  // 热门话题数据
  final RxList<Topic> topics = <Topic>[].obs;

  // 热门链接数据
  final RxList<Link> links = <Link>[].obs;

  // 热门回复数据
  final RxList<Topic> replies = <Topic>[].obs;

  // 热门类别数据
  final RxList<cg.Category> categories = <cg.Category>[].obs;

  // 徽章数据
  final RxList<BadgeDetail> badges = <BadgeDetail>[].obs;

  // 加载状态
  final RxBool topicsLoaded = false.obs;
  final RxBool topicsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化PageController
    pageController = PageController(initialPage: selectedIndex.value);

    BadgeManager().initialize();

    // 从参数中获取数据
    if (Get.arguments is SummaryResponse) {
      summaryData.value = Get.arguments as SummaryResponse;
      _loadInitialData();
    }

    // 监听标签页切换，实现延迟加载
    ever(selectedIndex, (index) {
      _loadDataForTab(index);
    });
  }

  // 加载初始数据
  void _loadInitialData() {
    if (summaryData.value != null) {
      // 初始加载第一个标签页的数据
      _loadDataForTab(selectedIndex.value);
    }
  }

  // 根据选中的标签页加载数据
  void _loadDataForTab(int index) async {
    if (summaryData.value == null) return;

    final summary = summaryData.value!.userSummary;

    switch (index) {
      case 0: // 话题
        if (topics.isEmpty && !topicsLoading.value) {
          await _loadTopics();
        }
        break;
      case 1: // 链接
        if (links.isEmpty) {
          links.value = summary?.links ?? [];
        }
        break;
      case 2: // 回复
        if (replies.isEmpty) {
          // for (final reply in summary?.replies ?? []) {
          //   try {
          //     final associatedTopic = summaryData.value!.topics!
          //         .firstWhere((topic) => topic.id == reply.topicId);
          //     reply.postNumber = associatedTopic.postNumber;
          //   } catch (e) {
          //     l.e('关联主题失败: $e');
          //   }
          // }
          replies.value = [
            for (final reply in summary?.replies ?? [])
              summaryData.value!.topics!.firstWhere(
                (topic) => topic.id == reply.topicId,
              ),
          ];
        }
        break;
      case 3: // 类别
        if (categories.isEmpty) {
          categories.value = summary?.topCategories ?? [];
        }
        break;
      case 4: // 徽章
        if (badges.isEmpty) {
          l.d(
            'summary?.badges: ${jsonEncode(summaryData.value!.userSummary?.badges)}',
          );
          badges.value = [
            for (final badge in summary?.badges ?? [])
              BadgeManager().getBadge(badge.badgeId)!,
          ];
        }
        break;
    }
  }

  // 加载话题数据
  Future<void> _loadTopics() async {
    if (summaryData.value == null) return;

    try {
      topicsLoading.value = true;

      final topicIds = summaryData.value!.userSummary?.topicIds;
      if (topicIds == null || topicIds.isEmpty) {
        topics.clear();
        return;
      }

      final List<Topic> loadedTopics = [];

      // 获取话题详情
      for (final id in topicIds) {
        loadedTopics.add(
          summaryData.value!.topics!.firstWhere((topic) => topic.id == id),
        );
      }

      topics.value = loadedTopics;
      topicsLoaded.value = true;
    } catch (e, s) {
      showError('获取话题失败：$e ---$s');
    } finally {
      topicsLoading.value = false;
    }
  }

  // 切换标签
  void switchTab(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 根据页面滑动更新选中的标签
  void onPageChanged(int page) {
    if (selectedIndex.value != page) {
      selectedIndex.value = page;
    }
  }

  // 刷新数据
  Future<void> refreshData() async {
    try {
      isLoading.value = true;

      // 根据当前选中的标签刷新数据
      switch (selectedIndex.value) {
        case 0: // 话题
          await _loadTopics();
          break;
        case 1: // 链接
          if (summaryData.value != null) {
            links.value = summaryData.value!.userSummary?.links ?? [];
          }
          break;
        case 2: // 回复
          if (summaryData.value != null) {
            // for (final reply in summaryData.value!.userSummary?.replies ?? []) {
            //   try {
            //     final associatedTopic = summaryData.value!.topics!
            //         .firstWhere((topic) => topic.id == reply.topicId);
            //     associatedTopic.postNumber = reply.postNumber;
            //     replies.add(associatedTopic);
            //   } catch (e) {
            //     l.e('关联主题失败: $e');
            //   }
            // }

            replies.value = [
              for (final reply in summaryData.value!.userSummary?.replies ?? [])
                summaryData.value!.topics!.firstWhere(
                  (topic) => topic.id == reply.topicId,
                ),
            ];
          }
          break;
        case 3: // 类别
          if (summaryData.value != null) {
            categories.value =
                summaryData.value!.userSummary?.topCategories ?? [];
          }
          break;
        case 4: // 徽章
          if (summaryData.value != null) {
            l.d(
              'summary?.badges: ${jsonEncode(summaryData.value!.userSummary?.badges)}',
            );
            badges.value = [
              for (final badge in summaryData.value!.userSummary?.badges ?? [])
                BadgeManager().getBadge(badge.badgeId)!,
            ];
          }
          break;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 跳转到话题详情
  void toTopicDetail(int id, int? postNumber) {
    if (postNumber != null) {
      Get.toNamed(
        Routes.TOPIC_DETAIL,
        arguments: id,
        parameters: {'postNumber': postNumber.toString()},
      );
      return;
    }

    Get.toNamed(Routes.TOPIC_DETAIL, arguments: id);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void openLink(String url) {
    if (url.isEmpty) return;

    final savedBrowserTips =
        StorageManager.getBool(AppConst.identifier.browserTips) ?? false;

    if (!savedBrowserTips) {
      Get.toNamed(Routes.WEBVIEW, arguments: url);
      return;
    }

    BrowserTipsSheet.show(Get.context!, url);
  }

  // 获取徽章类型名称
  String getBadgeTypeName(int typeId) {
    final type = BadgeManager().getBadge(typeId);
    return type?.name ?? '';
  }
}
