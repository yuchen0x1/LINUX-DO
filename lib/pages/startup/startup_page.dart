import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';

import 'startup_controller.dart';

class StartupPage extends GetView<StartupController> {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.guidePages.length,
            itemBuilder: (context, index) {
              final page = controller.guidePages[index];
              return Container(
                color: page.backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250.w,
                      height: 250.w,
                      margin: EdgeInsets.only(bottom: 60.w),
                      decoration: BoxDecoration(
                        color: index == 1
                            ? AppColors.primary.withValues(alpha: .2)
                            : Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Icon(
                          page.icon,
                          size: 100.w,
                          color: index == 0 ? AppColors.primary : Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      page.title,
                      style: TextStyle(
                        color: page.textColor,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.w),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: page.textColor, fontSize: 16.sp),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 50.w,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.guidePages.length,
                    (index) => Obx(
                      () => Container(
                        width: controller.currentPage == index ? 24.w : 8.w,
                        height: 8.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.w),
                GestureDetector(
                  onTap: controller.handleNextPage,
                  child: Container(
                    width: 200.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Obx(
                        () => Text(
                          controller.currentPage ==
                                  controller.guidePages.length - 1
                              ? '进入应用'
                              : '下一步',
                          style: TextStyle(
                            color: controller
                                .guidePages[controller.currentPage]
                                .backgroundColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
