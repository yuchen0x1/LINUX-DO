import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/base_controller.dart';

abstract class BasePage<T extends BaseController> extends GetView<T> {
  const BasePage({Key? key}) : super(key: key);

  // 构建页面主体
  Widget buildBody(BuildContext context);

  // 是否显示返回按钮
  bool showBackButton() => true;

  // 是否显示AppBar
  bool showAppBar() => true;

  // 获取AppBar标题
  String? get appBarTitle => null;

  // 构建AppBar右侧按钮
  List<Widget>? buildActions() => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar()
          ? AppBar(
              title: appBarTitle != null ? Text(appBarTitle!) : null,
              centerTitle: true,
              leading: showBackButton()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Get.back(),
                    )
                  : null,
              actions: buildActions(),
            )
          : null,
      body: Stack(
        children: [
          buildBody(context),
          // 加载指示器
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }),
          // 错误提示
          Obx(() {
            if (controller.hasError.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withValues(alpha: .3),
                child: Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
