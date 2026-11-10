import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_switch.dart';
import 'notification_settings_controller.dart';

class NotificationSettingsPage extends GetView<NotificationSettingsController> {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.notificationSettingsTitle,
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    children: [
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenLiked,
                        value: controller.whenLiked.value,
                        onChanged: (value) =>
                            controller.whenLiked.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenFollowed,
                        value: controller.allowFollow.value,
                        onChanged: (value) =>
                            controller.allowFollow.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenUserFollowed,
                        value: controller.whenFollowed.value,
                        onChanged: (value) =>
                            controller.whenFollowed.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenIFollow,
                        value: controller.whenIFollow.value,
                        onChanged: (value) =>
                            controller.whenIFollow.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenReplied,
                        value: controller.whenReplied.value,
                        onChanged: (value) =>
                            controller.whenReplied.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.notificationWhenTopicCreated,
                        value: controller.whenTopicCreated.value,
                        onChanged: (value) =>
                            controller.whenTopicCreated.value = value,
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        context,
                        title: AppConst.settings.notificationSchedule,
                        value: controller.notificationSchedule.value,
                        onChanged: (value) =>
                            controller.notificationSchedule.value = value,
                      ),
                    ],
                  ),
                  16.vGap,
                  Text(
                    AppConst.settings.notificationTip,
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Theme.of(context).hintColor,
                      height: 1.5,
                    ),
                  ),
                  32.vGap,
                  SizedBox(
                    width: double.infinity,
                    child: DisButton(
                      text: AppConst.settings.save,
                      type: ButtonType.primary,
                      onPressed: () => controller.saveNotificationSettings(),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(child: DisRefreshLoading()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10.w,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          DisSwitch(
            value: value,
            onChanged: onChanged,
            colorOn: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required String title,
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          DropdownButton<int>(
            value: value,
            dropdownColor: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            items: [
              DropdownMenuItem(
                value: 1,
                child: Text(
                  AppConst.settings.always,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text(
                  AppConst.settings.whenAway,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text(
                  AppConst.settings.never,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: .5.w,
      thickness: 1.w,
      indent: 16.w,
      color: Theme.of(Get.context!).dividerColor.withValues(alpha: 0.4),
    );
  }
}
