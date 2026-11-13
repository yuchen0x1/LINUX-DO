import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/banner_settings.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_text_field.dart';

class BannerPickerController extends BaseController {
  final _imagePicker = ImagePicker();
  final RxString networkUrl = RxString('');
  final RxString localImagePath = RxString('');
  final RxBool useDefault = true.obs;
  final BannerSettings? currentSettings;

  BannerPickerController(this.currentSettings);

  @override
  void onInit() {
    super.onInit();
    if (currentSettings != null) {
      // 设置网络图片URL
      if (currentSettings!.networkUrl?.isNotEmpty == true) {
        networkUrl.value = currentSettings!.networkUrl!;
        useDefault.value = false;
      }
      // 设置本地图片路径
      else if (currentSettings!.localPath?.isNotEmpty == true) {
        localImagePath.value = currentSettings!.localPath!;
        useDefault.value = false;
      }
      // 设置默认图片
      else {
        useDefault.value = currentSettings!.useDefault;
        networkUrl.value = '';
        localImagePath.value = '';
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        localImagePath.value = image.path;
        useDefault.value = false;
        networkUrl.value = '';
      }
    } catch (e) {
      showError('选择图片失败!');
    }
  }

  void setUseDefault(bool? value) {
    useDefault.value = value ?? true;
    if (useDefault.value) {
      networkUrl.value = '';
      localImagePath.value = '';
    }
  }

  void setNetworkUrl(String value) {
    networkUrl.value = value.trim();
    if (networkUrl.value.isNotEmpty) {
      useDefault.value = false;
      localImagePath.value = '';
    }
  }

  BannerSettings getSettings() {
    return BannerSettings(
      networkUrl: networkUrl.value,
      localPath: localImagePath.value,
      useDefault: useDefault.value,
    );
  }
}

class BannerPickerDialog extends GetView<BannerPickerController> {
  const BannerPickerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.85.sw,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 12.w,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部预览区域
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.w),
                  ),
                  child: Container(
                    height: 110.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          Theme.of(context).primaryColor
                              .withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: _buildPreviewImage(context),
                  ),
                ),
                // 关闭按钮
                Positioned(
                  right: 0.w,
                  top: 0.w,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.clear,
                        size: 14.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设置Banner图片',
                    style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  16.vGap,
                  // 选项卡
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          _buildOptionButton(
                            context,
                            icon: CupertinoIcons.globe,
                            label: '网络图片',
                            isSelected:
                                controller.networkUrl.isNotEmpty &&
                                !controller.useDefault.value &&
                                controller.localImagePath.isEmpty,
                            onTap: _showUrlInputDialog,
                          ),
                          _buildOptionButton(
                            context,
                            icon: CupertinoIcons.paintbrush_fill,
                            label: '本地图片',
                            isSelected:
                                controller.localImagePath.isNotEmpty &&
                                !controller.useDefault.value &&
                                controller.networkUrl.isEmpty,
                            onTap: controller.pickImage,
                          ),
                          _buildOptionButton(
                            context,
                            icon: CupertinoIcons.sparkles,
                            label: '默认图片',
                            isSelected:
                                controller.useDefault.value &&
                                controller.networkUrl.isEmpty &&
                                controller.localImagePath.isEmpty,
                            onTap: () => controller.setUseDefault(true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  16.vGap,
                  // 当前选择提示
                  Obx(() {
                    String statusText = '使用默认图片';
                    if (controller.networkUrl.isNotEmpty) {
                      statusText = '使用网络图片';
                    } else if (controller.localImagePath.isNotEmpty) {
                      statusText =
                          '已选择本地图片: ${controller.localImagePath.value.split('/').last}';
                    }
                    return Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10.w,
                        fontFamily: AppFontFamily.dinPro,
                        color: Theme.of(context).hintColor,
                      ),
                    );
                  }),
                  24.vGap,
                  // 确认按钮
                  SizedBox(
                    width: double.infinity,
                    child: DisButton(
                      text: AppConst.confirm,
                      type: ButtonType.primary,
                      onPressed: () =>
                          Get.back(result: controller.getSettings()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ]
                  : [Colors.transparent, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24.w,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              4.vGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.w,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUrlInputDialog() async {
    final result = await Get.dialog<String>(
      Dialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '输入图片URL',
                style: TextStyle(
                  fontSize: 14.w,
                  fontFamily: AppFontFamily.dinPro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              16.vGap,
              DisTextField(
                hintText: '请输入图片URL',
                value: controller.networkUrl.value,
                onChanged: (value) => controller.networkUrl.value = value,
                maxLines: 1,
              ),
              24.vGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      AppConst.cancel,
                      style: TextStyle(color: Theme.of(Get.context!).hintColor),
                    ),
                  ),
                  16.hGap,
                  SizedBox(
                    height: 32.w,
                    child: DisButton(
                      text: AppConst.confirm,
                      type: ButtonType.primary,
                      onPressed: () =>
                          Get.back(result: controller.networkUrl.value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      controller.setNetworkUrl(result);
    }
  }

  Widget _buildPreviewImage(BuildContext context) {
    return Obx(() {
      Widget image;
      if (controller.networkUrl.isNotEmpty) {
        image = Image.network(
          controller.networkUrl.value,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 32.w,
                  ),
                  8.vGap,
                  Text(
                    '图片加载失败',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14.w,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else if (controller.localImagePath.isNotEmpty) {
        image = Image.file(
          File(controller.localImagePath.value),
          fit: BoxFit.cover,
        );
      } else if (controller.useDefault.value) {
        image = Image.asset(AppImages.getBanner(context), fit: BoxFit.cover);
      } else {
        image = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_rounded,
                color: Theme.of(context).hintColor,
                size: 32.w,
              ),
              8.vGap,
              Text(
                '请选择图片',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 14.w,
                ),
              ),
            ],
          ),
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          image,
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
