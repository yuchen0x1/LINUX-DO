import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/summary.dart';
import '../../../controller/base_controller.dart';
import '../../../utils/mixins/concatenated.dart';

class SummaryController extends BaseController with Concatenated {
  final Rxn<List<StatItem>> topStats = Rxn();
  final Rxn<List<StatItem>> bottomStats = Rxn();
  final summaryData = Rxn<SummaryResponse>();

  void updateData(SummaryResponse? data) async {
    if (data == null) {
      _setDefaultValues();
      return;
    }
    summaryData.value = data;

    try {
      final summary = data.userSummary!;

      // 转换时间格式
      final timeRead = Duration(seconds: summary.timeRead ?? 0);
      final recentTimeRead = Duration(seconds: summary.recentTimeRead ?? 0);

      topStats.value = [
        StatItem(
          value: '${summary.daysVisited?.toString() ?? '0'}天',
          label: '访问天数',
          icon: CupertinoIcons.calendar,
          iconColor: Colors.blue,
        ),
        StatItem(
          value: '${((timeRead.inSeconds) / 86400).toStringAsFixed(1)}天',
          label: '阅读时间',
          icon: CupertinoIcons.time,
          iconColor: Colors.orange,
        ),
        StatItem(
          value: '${((recentTimeRead.inSeconds) / 86400).toStringAsFixed(1)}天',
          label: '最近阅读时间',
          icon: CupertinoIcons.clock,
          iconColor: Colors.green,
        ),
        StatItem(
          value: formatNumber(summary.topicsEntered ?? 0),
          label: '浏览的话题',
          icon: CupertinoIcons.eye,
          iconColor: Colors.purple,
        ),
        StatItem(
          value: formatNumber(summary.postsReadCount ?? 0),
          label: '已读帖子',
          icon: CupertinoIcons.doc_text,
          iconColor: Colors.teal,
        ),
      ];

      bottomStats.value = [
        StatItem(
          value: '${summary.likesGiven ?? 0}赞',
          label: '已送出',
          icon: CupertinoIcons.heart_circle_fill,
          iconColor: Colors.red,
        ),
        StatItem(
          value: '${summary.likesReceived ?? 0}赞',
          label: '已收到',
          icon: CupertinoIcons.heart_solid,
          iconColor: Colors.red,
        ),
        StatItem(
          value: (summary.bookmarkCount ?? 0).toString(),
          label: '书签',
          icon: CupertinoIcons.bookmark_fill,
          iconColor: Colors.amber,
        ),
        StatItem(
          value: (summary.topicCount ?? 0).toString(),
          label: '创建的话题',
          icon: CupertinoIcons.plus_square_fill,
          iconColor: Colors.indigo,
        ),
        StatItem(
          value: (summary.postCount ?? 0).toString(),
          label: '创建的帖子',
          icon: CupertinoIcons.chat_bubble_fill,
          iconColor: Colors.cyan,
        ),
      ];
    } catch (e) {
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }

  String formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}w';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _setDefaultValues() {
    topStats.value = [
      StatItem(
        value: '0',
        label: '访问天数',
        icon: CupertinoIcons.calendar,
        iconColor: Colors.blue,
      ),
      StatItem(
        value: '0天',
        label: '阅读时间',
        icon: CupertinoIcons.time,
        iconColor: Colors.orange,
      ),
      StatItem(
        value: '0天',
        label: '最近阅读时间',
        icon: CupertinoIcons.clock,
        iconColor: Colors.green,
      ),
      StatItem(
        value: '0',
        label: '浏览的话题',
        icon: CupertinoIcons.eye,
        iconColor: Colors.purple,
      ),
      StatItem(
        value: '0',
        label: '已读帖子',
        icon: CupertinoIcons.doc_text,
        iconColor: Colors.teal,
      ),
    ];

    bottomStats.value = [
      StatItem(
        value: '0',
        label: '已送出',
        icon: CupertinoIcons.heart_fill,
        iconColor: Colors.red,
      ),
      StatItem(
        value: '0',
        label: '已收到',
        icon: CupertinoIcons.heart_solid,
        iconColor: Colors.red,
      ),
      StatItem(
        value: '0',
        label: '书签',
        icon: CupertinoIcons.bookmark_fill,
        iconColor: Colors.amber,
      ),
      StatItem(
        value: '0',
        label: '创建的话题',
        icon: CupertinoIcons.plus_square_fill,
        iconColor: Colors.indigo,
      ),
      StatItem(
        value: '0',
        label: '创建的帖子',
        icon: CupertinoIcons.chat_bubble_fill,
        iconColor: Colors.cyan,
      ),
    ];
  }
}

class StatItem {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  StatItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });
}
