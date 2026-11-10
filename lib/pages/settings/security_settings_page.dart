import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/user_auth_token.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'security_settings_controller.dart';

class SecuritySettingsPage extends GetView<SecuritySettingsController> {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.settings.security,
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

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(
              AppConst.settings.password,
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            16.vGap,
            _buildSendEmail(context),
            16.vGap,
            Text(
              AppConst.settings.deviceHistory,
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            16.vGap,
            ...controller.devices
                .map((device) => _buildDeviceItem(context, device))
                .toList(),
            DisButton(
              text: AppConst.settings.logoutAll,
              type: ButtonType.primary,
              onPressed: () => _showLogoutAllDialog(context),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDeviceItem(BuildContext context, UserAuthToken device) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: FaIcon(
                    _getDeviceIcon(device.icon),
                    size: 20.w,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                12.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            device.browser ?? '',
                            style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                                color: device.isActive ?? false
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.color
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                fontFamily: AppFontFamily.dinPro),
                          ),
                          8.hGap,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.w),
                            decoration: BoxDecoration(
                              color: device.isActive ?? false
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Text(
                              device.isActive ?? false
                                  ? AppConst.settings.active
                                  : AppConst.settings.inactive,
                              style: TextStyle(
                                  fontSize: 9.w,
                                  color: device.isActive ?? false
                                      ? AppColors.success
                                      : Theme.of(context).disabledColor,
                                  fontFamily: AppFontFamily.dinPro),
                            ),
                          ),
                        ],
                      ),
                      4.vGap,
                      Text(
                        device.location ?? '',
                        style: TextStyle(
                            fontSize: 10.w,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontFamily: AppFontFamily.dinPro),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 26.w,
                  child: DisButton(
                    text: AppConst.settings.logout,
                    type: ButtonType.outline,
                    size: ButtonSize.small,
                    onPressed: () => controller.logoutDevice(device.id),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.w),
                bottomRight: Radius.circular(12.w),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInfoItem(
                    context,
                    AppConst.settings.device,
                    device.device ?? '',
                  ),
                ),
                12.hGap,
                Expanded(
                  flex: 2,
                  child: _buildInfoItem(
                    context,
                    AppConst.settings.operatingSystem,
                    device.os ?? '',
                  ),
                ),
                12.hGap,
                Flexible(
                  child: _buildInfoItem(
                    context,
                    AppConst.settings.lastSeen,
                    _formatDate(device.seenAt),
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10.w,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontFamily: AppFontFamily.dinPro),
        ),
        4.vGap,
        Text(
          value,
          style: TextStyle(
              fontSize: 12.w,
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontFamily: AppFontFamily.dinPro),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  FaIconData _getDeviceIcon(String? icon) {
    if (icon == null) {
      return FontAwesomeIcons.desktop;
    }
    switch (icon) {
      case 'fab-android':
        return FontAwesomeIcons.android;
      case 'fab-apple':
        return FontAwesomeIcons.apple;
      case 'fab-windows':
        return FontAwesomeIcons.windows;
      case 'fab-linux':
        return FontAwesomeIcons.linux;
      default:
        return FontAwesomeIcons.desktop;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) {
      return '';
    }
    return DateTime.parse(dateStr).friendlyDateTime;
  }

  Future<void> _showLogoutAllDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.macwindow,
                  color: Theme.of(context).colorScheme.error,
                  size: 24.w,
                ),
              ),
              16.vGap,
              Text(
                AppConst.settings.logoutAllConfirm,
                style: TextStyle(
                  fontSize: 18.w,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              24.vGap,
              Row(
                children: [
                  Expanded(
                    child: DisButton(
                      text: AppConst.settings.cancel,
                      type: ButtonType.outline,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  12.hGap,
                  Expanded(
                    child: DisButton(
                      text: AppConst.settings.confirm,
                      type: ButtonType.primary,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      controller.logoutAllDevices();
    }
  }

  Widget _buildSendEmail(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConst.settings.sendResetEmail,
                style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              controller.isEmailSent.value
                  ? Text(
                      AppConst.settings.sendEmailSuccess,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 32.w,
            child: DisButton(
              text: AppConst.confirm,
              type: ButtonType.transform,
              loading: controller.isSendingEmail.value,
              onPressed: () => controller.sendEmail(),
            ),
          ),
        ],
      ),
    );
  }
}
