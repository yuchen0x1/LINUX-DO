import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/controller/global_controller.dart';

import '../../widgets/dis_switch.dart';
import '../../widgets/dis_button.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.settings.title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        children: [
          _buildSection(context, AppConst.settings.accountAndProfile, [
            _buildNavigationItem(
              context,
              '我的等级特权',
              CupertinoIcons.rosette,
              iconColor: const Color(0xFFFF9800),
              onTap: () {
                controller.showTrustLevelPrivileges();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.security,
              CupertinoIcons.shield_fill,
              iconColor: const Color(0xFF66BB6A),
              onTap: () {
                controller.toSecuritySettings();
              },
            ),
            // _buildNavigationItem(
            //   context,
            //   AppConst.settings.editProfile,
            //   CupertinoIcons.pencil_circle_fill,
            //   iconColor: const Color(0xFFFF7043),
            //   onTap: () {
            //     controller.toProfileSettings();
            //   },
            // ),
            _buildNavigationItem(
              context,
              AppConst.settings.emailSettings,
              CupertinoIcons.envelope_circle_fill,
              iconColor: const Color(0xFF26A69A),
              onTap: () {
                controller.toEmailSettings();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.dataExport,
              CupertinoIcons.doc_text_fill,
              iconColor: const Color(0xFF7E57C2),
              onTap: () {
                _showExportDialog(context);
              },
            ),
          ]),
          16.vGap,
          _buildSection(context, AppConst.settings.notificationsAndPrivacy, [
            _buildSwitchItem(
              context,
              '实时推送通知',
              controller.isPushEnabled,
              CupertinoIcons.antenna_radiowaves_left_right,
              (value) {
                controller.updatePushNotification(value);
              },
              const Color(0xFFEF5350),
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.notifications,
              CupertinoIcons.bell_fill,
              iconColor: const Color(0xFFEF5350),
              onTap: () {
                controller.toNotificationSettings();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.tracking,
              CupertinoIcons.location_fill,
              iconColor: const Color(0xFF42A5F5),
              onTap: () {
                controller.toTrackingSettings();
              },
            ),
            // _buildNavigationItem(
            //   context,
            //   AppConst.settings.doNotDisturb,
            //   CupertinoIcons.moon_fill,
            //   iconColor: const Color(0xFF8D6E63),
            //   onTap: () {
            //     controller.toDoNotDisturbSettings();
            //   },
            // ),
            _buildSwitchItem(
              context,
              AppConst.settings.anonymousMode,
              controller.isAnonymousMode,
              CupertinoIcons.eye_slash_fill,
              (value) {
                controller.isAnonymousMode.value = value;
              },
              const Color(0xFF78909C),
            ),
          ]),
          16.vGap,
          _buildSection(context, AppConst.settings.appearance, [
            _buildThemeDropdown(
              context,
              const Color(0xFFFFB300),
              CupertinoIcons.moon_stars_fill,
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.themeCustom,
              CupertinoIcons.paintbrush_fill,
              iconColor: const Color(0xFFFFB300),
              onTap: () {
                controller.showColorPicker();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.fontSize,
              CupertinoIcons.textformat_size,
              iconColor: const Color(0xFFFFB300),
              onTap: () {
                controller.toFontSizeSettings();
              },
            ),
          ]),
          16.vGap,
          _buildSection(context, '网络与连接', [
            _buildNavigationItem(
              context,
              '网络与 DoH 设置',
              CupertinoIcons.wifi,
              iconColor: const Color(0xFF00ACC1),
              onTap: () {
                controller.toNetworkSettings();
              },
            ),
          ]),
          16.vGap,
          _buildSection(context, AppConst.settings.other, [
            _buildSwitchItem(
              context,
              AppConst.settings.browserTips,
              controller.browserTips,
              CupertinoIcons.globe,
              (value) {
                controller.updateBrowserTips(value);
              },
              const Color(0xFF10B086),
            ),
            _buildSwitchItem(
              context,
              '动态 Emoji 表情',
              controller.isAnimatedEmojiEnabled,
              CupertinoIcons.smiley_fill,
              (value) {
                controller.updateAnimatedEmoji(value);
              },
              const Color(0xFFFF9800),
            ),
          ]),
          16.vGap,
          _buildSection(context, AppConst.settings.helpAndSupport, [
            _buildNavigationItem(
              context,
              AppConst.settings.about,
              CupertinoIcons.info_circle_fill,
              iconColor: const Color(0xFF29B6F6),
              onTap: () {
                controller.toAbout();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.faq,
              CupertinoIcons.question_circle_fill,
              iconColor: const Color(0xFF4DB6AC),
              onTap: () {
                controller.toFaq();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.terms,
              CupertinoIcons.doc_text_fill,
              iconColor: const Color(0xFF9CCC65),
              onTap: () {
                controller.toTerms();
              },
            ),
            _buildNavigationItem(
              context,
              AppConst.settings.privacy,
              CupertinoIcons.lock_fill,
              iconColor: const Color(0xFFBA68C8),
              onTap: () {
                controller.toPrivacy();
              },
            ),
          ]),
          26.vGap,
          _buildLogoutButton(context),
          16.vGap,
        ],
      ),
    );
  }

  Widget _buildThemeDropdown(
    BuildContext context,
    Color? iconColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).primaryColor).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
          ),
          12.hGap,
          Expanded(
            child: Obx(
              () => DropdownButton(
                value: controller.selectedThemeMode,
                dropdownColor: Theme.of(context).cardColor,
                items: controller.themeModeOptions.map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: controller.setThemeMode,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12.w),
                underline: const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 16.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
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
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              return Column(
                children: [
                  entry.value,
                  if (index < children.length - 1)
                    Divider(
                      height: .25.w,
                      thickness: .25.w,
                      indent: 16.w,
                      color: isDark
                          ? Theme.of(context).dividerColor.withValues(alpha: .2)
                          : Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: .1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Icon(
                  icon,
                  size: 20.w,
                  color: iconColor ?? Theme.of(context).primaryColor,
                ),
              ),
              12.hGap,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16.w,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final globalController = Get.find<GlobalController>();
    return ElevatedButton(
      onPressed: () => globalController.isAnonymousMode
          ? controller.logout()
          : _showLogoutDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: globalController.isAnonymousMode
            ? AppColors.success
            : AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.w)),
        padding: EdgeInsets.symmetric(vertical: 12.w),
      ),
      child: Text(
        globalController.isAnonymousMode
            ? AppConst.settings.login
            : AppConst.settings.logout,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: AppColors.error,
                  size: 24.w,
                ),
              ),
              16.vGap,
              Text(
                AppConst.settings.logoutConfirmTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              12.vGap,
              Text(
                AppConst.settings.logoutConfirmMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.8),
                  height: 1.4,
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
                      type: ButtonType.transform,
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
      controller.logout();
    }
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    Rx<bool> value,
    IconData icon,
    Function(bool) onChanged,
    Color? iconColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).primaryColor).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
          ),
          12.hGap,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(
            height: 28.w,
            child: Obx(
              () => DisSwitch(value: value.value, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    Get.dialog(
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
                  color: const Color(0xFF7E57C2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.arrow_down_doc,
                  color: const Color(0xFF7E57C2),
                  size: 24.w,
                ),
              ),
              16.vGap,
              Text(
                AppConst.settings.dataExport,
                style: TextStyle(
                  fontSize: 18.w,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              12.vGap,
              Text(
                AppConst.settings.dataExportMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              24.vGap,
              Row(
                children: [
                  Expanded(
                    child: DisButton(
                      text: AppConst.settings.cancel,
                      type: ButtonType.outline,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  12.hGap,
                  Expanded(
                    child: DisButton(
                      text: AppConst.confirm,
                      type: ButtonType.primary,
                      onPressed: () {
                        controller.exportData();
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
