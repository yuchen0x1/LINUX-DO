import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_text_field.dart';
import '../../widgets/dis_switch.dart';
import 'do_not_disturb_controller.dart';

class DoNotDisturbPage extends GetView<DoNotDisturbController> {
  const DoNotDisturbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.doNotDisturb,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: DisRefreshLoading());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConst.settings.ignoredUsers,
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddUserDialog(context),
                    icon: Icon(
                      CupertinoIcons.plus_circle_fill,
                      color: Theme.of(context).primaryColor,
                      size: 24.w,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  if (controller.ignoredUsers.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.w),
                        child: Text(
                          AppConst.settings.noIgnoredUsers,
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    )
                  else
                    ...controller.ignoredUsers
                        .map((username) => _buildUserItem(context, username))
                        .toList(),
                  32.vGap,
                  _buildSection(
                    context,
                    AppConst.settings.dndSettingsTitle,
                    AppConst.settings.dndSettingsDescription,
                    [
                      _buildSwitchItem(
                        context,
                        AppConst.settings.allowPersonalMessages,
                        controller.allowPersonalMessages,
                        (value) {
                          controller.allowPersonalMessages.value = value;
                          controller.saveSettings();
                        },
                      ),
                      _buildSwitchItem(
                        context,
                        AppConst.settings.allowChatMessages,
                        controller.allowChatMessages,
                        (value) {
                          controller.allowChatMessages.value = value;
                          controller.saveSettings();
                        },
                      ),
                    ],
                  ),
                  16.vGap,
                  _buildSection(
                    context,
                    AppConst.settings.messageSettingsTitle,
                    AppConst.settings.messageSettingsDescription,
                    [
                      _buildSwitchItem(
                        context,
                        AppConst.settings.allowOthersMessage,
                        controller.allowNotifications,
                        (value) {
                          controller.allowNotifications.value = value;
                          controller.saveSettings();
                        },
                      ),
                    ],
                  ),
                  32.vGap,
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUserItem(BuildContext context, String username) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Text(
            username[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(
          username,
          style: TextStyle(
            fontSize: 14.w,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        trailing: IconButton(
          onPressed: () => controller.removeIgnoredUser(username),
          icon: Icon(
            CupertinoIcons.delete,
            color: Theme.of(context).colorScheme.error,
            size: 20.w,
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConst.settings.addIgnoredUser,
                    style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      CupertinoIcons.clear,
                      size: 20.w,
                    ),
                  ),
                ],
              ),
              16.vGap,
              Text(
                AppConst.settings.addIgnoredUser,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              16.vGap,
              DisTextField(
                value: controller.selectedUser.value,
                onChanged: (value) => controller.selectedUser.value = value,
                hintText: AppConst.settings.inputIgnoredUsername,
              ),
              16.vGap,
              Text(
                AppConst.settings.duration,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              8.vGap,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Obx(() => DropdownButton<String>(
                      value: controller.selectedDuration.value,
                      items: controller.durations.map((duration) {
                        return DropdownMenuItem(
                          value: duration,
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: 14.w,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedDuration.value = value;
                        }
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    )),
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: '确认',
                  type: ButtonType.primary,
                  onPressed: () => controller.addIgnoredUser(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String description,
      List<Widget> children) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.w,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                8.vGap,
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    RxBool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
        ),
      ),
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
          Obx(() => DisSwitch(value: value.value, onChanged: onChanged)),
        ],
      ),
    );
  }
}
