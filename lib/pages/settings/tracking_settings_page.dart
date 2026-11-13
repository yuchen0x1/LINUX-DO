import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_switch.dart';

import 'tracking_settings_controller.dart';

class TrackingSettingsPage extends GetView<TrackingSettingsController> {
  const TrackingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.tracking,
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
                        title: AppConst.settings.enableTracking,
                        subtitle: AppConst.settings.enableTrackingDesc,
                        value: controller.enableTracking.value,
                        onChanged: (value) =>
                            controller.enableTracking.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.trackLocation,
                        subtitle: AppConst.settings.trackLocationDesc,
                        value: controller.trackLocation.value,
                        onChanged: (value) =>
                            controller.trackLocation.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.trackActivity,
                        subtitle: AppConst.settings.trackActivityDesc,
                        value: controller.trackActivity.value,
                        onChanged: (value) =>
                            controller.trackActivity.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.trackBrowsingHistory,
                        subtitle: AppConst.settings.trackBrowsingHistoryDesc,
                        value: controller.trackBrowsingHistory.value,
                        onChanged: (value) =>
                            controller.trackBrowsingHistory.value = value,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        context,
                        title: AppConst.settings.shareAnalytics,
                        subtitle: AppConst.settings.shareAnalyticsDesc,
                        value: controller.shareAnalytics.value,
                        onChanged: (value) =>
                            controller.shareAnalytics.value = value,
                      ),
                    ],
                  ),
                  16.vGap,
                  Text(
                    AppConst.settings.trackingPrivacyTip,
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
                      onPressed: () => controller.saveTrackingSettings(),
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
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                4.vGap,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          8.hGap,
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
