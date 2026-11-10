import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'brithday_tab_controller.dart';

enum Filter {
  today('today', 0),
  tomorrow('tomorrow', 1),
  upcoming('upcoming', 2),
  month('month', 3);

  final String value;
  final int position;

  const Filter(this.value, this.position);

  static Filter fromPosition(int position) {
    return Filter.values.firstWhere((e) => e.position == position);
  }
}

class BirthdayController extends BaseController
    with GetTickerProviderStateMixin {
  late TabController tabController;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化所有的 TabController
    for (var filter in Filter.values) {
      Get.put(BrithdayTabController(filter), tag: filter.value);
    }

    tabController = TabController(
      length: Filter.values.length,
      vsync: this,
    );

    // 监听tab切换
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
