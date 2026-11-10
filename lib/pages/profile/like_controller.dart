import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/summary.dart';
import '../../controller/base_controller.dart';

class LikeController extends BaseController {
  final RxInt selectedIndex = 0.obs;

  final Rxn<SummaryResponse> summaryData = Rxn<SummaryResponse>();

  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    //获取summaryData
    final args = Get.arguments;
    if (args != null && args is SummaryResponse) {
      summaryData.value = args;
    }

    // 初始化PageController
    pageController = PageController(initialPage: selectedIndex.value);
  }

  // 切换标签
  void switchTab(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 根据传入的页面索引更新selectedIndex
  void onPageChanged(int page) {
    if (selectedIndex.value != page) {
      selectedIndex.value = page;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
