import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_switch.dart';
import 'email_settings_controller.dart';

class EmailSettingsPage extends GetView<EmailSettingsController> {
  const EmailSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.emailSettingsTitle,
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
                      _buildOptionItem(
                        context,
                        title: AppConst.settings.personalMessage,
                        value: controller.personalMessageOption.value,
                        onChanged: (value) =>
                            controller.personalMessageOption.value = value,
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        context,
                        title: AppConst.settings.mentionsAndReplies,
                        value: controller.mentionsOption.value,
                        onChanged: (value) =>
                            controller.mentionsOption.value = value,
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        context,
                        title: AppConst.settings.watchingCategory,
                        value: controller.watchingOption.value,
                        onChanged: (value) =>
                            controller.watchingOption.value = value,
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        context,
                        title: AppConst.settings.policyReview,
                        value: controller.policyOption.value,
                        onChanged: (value) =>
                            controller.policyOption.value = value,
                      ),
                      if (controller.summary.value) ...[
                        _buildDivider(),
                        _buildOptionItem(
                          context,
                          title: AppConst.settings.activitySummary,
                          value: controller.summaryOption.value,
                          onChanged: (value) =>
                              controller.summaryOption.value = value,
                        ),
                      ],
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.includeNewUsers,
                        value: controller.includeReplies.value,
                        onChanged: (value) =>
                            controller.includeReplies.value = value,
                      ),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.summary,
                        value: controller.summary.value,
                        onChanged: (value) => controller.summary.value = value,
                      ),
                    ],
                  ),
                  32.vGap,
                  SizedBox(
                    width: double.infinity,
                    child: DisButton(
                      text: AppConst.settings.save,
                      type: ButtonType.primary,
                      onPressed: () => controller.saveEmailSettings(),
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

  void _showHelpDialog(BuildContext context, String title, String description) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHelpText(String title) {
    if (title == AppConst.settings.personalMessage) {
      return '当我收到个人消息时给我发电子邮件';
    } else if (title == AppConst.settings.mentionsAndReplies) {
      return '当我被引用、回复、我的用户名被提及 (@) 或当我关注的类别、标签或话题有新的活动时给我发送电子邮件';
    } else if (title == AppConst.settings.watchingCategory) {
      return '在电子邮件底部包含以前的回复';
    } else if (title == AppConst.settings.policyReview) {
      return '当策略需要我审核时给我发送电子邮件';
    } else if (title == AppConst.settings.activitySummary) {
      return '在总结电子邮件中包含来自新用户的内容';
    } else if (title == AppConst.settings.summary) {
      return '当我不访问这里时，向我发送热门话题和回复的电子邮件总结';
    }
    return '';
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
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                  icon: Icon(
                    CupertinoIcons.question_diamond_fill,
                    size: 13.w,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () =>
                      _showHelpDialog(context, title, _getHelpText(title)),
                ),
              ],
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

  Widget _buildSwitchItem(
    BuildContext context, {
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _buildDivider() {
    return Divider(
      height: .5.w,
      thickness: 1.w,
      indent: 16.w,
      color: Theme.of(Get.context!).dividerColor.withValues(alpha: 0.4),
    );
  }
}
