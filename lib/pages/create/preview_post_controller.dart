import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controller/base_controller.dart';
import '../../models/category_data.dart';
import '../../routes/app_pages.dart';

class PreviewPostController extends BaseController {
  final String title;
  final String content; // 已经是HTML格式
  final Category category;
  final List<String> tags;

  PreviewPostController({
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
  });

  // 控制滚动
  final scrollController = ScrollController();

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void launchUrl(String? url) {
    if (url == null || url.isEmpty) return;
    Get.toNamed(Routes.WEBVIEW, arguments: url);
  }
}
