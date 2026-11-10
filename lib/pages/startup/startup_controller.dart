import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/utils/storage_manager.dart';

import '../../const/app_icons.dart';
import '../../controller/base_controller.dart';
import '../../routes/app_pages.dart';

class StartupController extends BaseController {
  final _currentPage = 0.obs;
  final _guidePages = <GuidePageEntity>[
    GuidePageEntity(
      title: '真诚',
      description: '以真诚待人为荣\n以虚伪欺人为耻',
      icon: AppIcons.sincerity,
      backgroundColor: AppColors.logoColor1,
      textColor: Colors.white,
    ),
    GuidePageEntity(
      title: '友善',
      description: '以友善热心为荣\n以傲慢冷漠为耻',
      icon: AppIcons.friendly,
      backgroundColor: AppColors.logoColor2,
      textColor: AppColors.primary,
    ),
    GuidePageEntity(
      title: '团结',
      description: '以团结协作为荣\n以孤立对抗为耻',
      icon: AppIcons.unity,
      backgroundColor: AppColors.logoColor3,
      textColor: Colors.white,
    ),
    GuidePageEntity(
      title: '专业',
      description: '以专业敬业为荣\n以敷衍了事为耻',
      icon: AppIcons.professional,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    ),
  ].obs;

  int get currentPage => _currentPage.value;
  List<GuidePageEntity> get guidePages => _guidePages;

  final pageController = PageController();

  void onPageChanged(int index) {
    _currentPage.value = index;
  }

  void handleNextPage() {
    if (_currentPage.value < _guidePages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      StorageManager.setData(AppConst.identifier.isFirst, true);
      Get.offNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class GuidePageEntity {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  GuidePageEntity({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}
