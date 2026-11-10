import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_text_field.dart';
import 'profile_settings_controller.dart';

class ProfileSettingsPage extends GetView<ProfileSettingsController> {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.profile,
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: DisRefreshLoading());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverSection(context),
              16.vGap,
              _buildIntroSection(context),
              16.vGap,
              _buildInfoSection(context),
              16.vGap,
              _buildOtherSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCoverSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180.w,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            image: controller.cardBackground.value.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(controller.cardBackground.value),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: controller.cardBackground.value.isEmpty
              ? Center(
                  child: Text(
                    AppConst.settings.cardBackgroundHint,
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )
              : null,
        ),
        Positioned(
          top: 12.w,
          right: 12.w,
          child: DisButton(
            text: AppConst.settings.change,
            type: ButtonType.transform,
            onPressed: () => {},
          ),
        ),
      ],
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConst.settings.introduction,
                style: TextStyle(
                  fontSize: 16.w,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              IconButton(
                onPressed: () => _showIntroductionDialog(context),
                icon: Icon(
                  CupertinoIcons.pencil,
                  size: 16.w,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          8.vGap,
          Text(
            controller.introduction.value.isEmpty
                ? AppConst.settings.introductionHint
                : controller.introduction.value,
            style: TextStyle(
              fontSize: 14.w,
              color: controller.introduction.value.isEmpty
                  ? Theme.of(context).hintColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            title: AppConst.settings.timezone,
            trailing: Text(
              controller.timezone.value.isEmpty
                  ? AppConst.settings.useCurrentTimezone
                  : controller.timezone.value,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onTap: () => _showTimezoneDialog(context),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            title: AppConst.settings.region,
            trailing: Text(
              controller.region.value.isEmpty
                  ? AppConst.settings.useCurrentRegion
                  : controller.region.value,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onTap: () => _showRegionDialog(context),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            title: AppConst.settings.website,
            trailing: Text(
              controller.website.value.isEmpty
                  ? AppConst.settings.websiteHint
                  : controller.website.value,
              style: TextStyle(
                fontSize: 14.w,
                color: controller.website.value.isEmpty
                    ? Theme.of(context).hintColor
                    : Theme.of(context).primaryColor,
              ),
            ),
            onTap: () => _showWebsiteDialog(context),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            title: AppConst.settings.birthDate,
            trailing: Text(
              controller.birthDate.value.isEmpty
                  ? ''
                  : controller.birthDate.value,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onTap: () => selectBirthDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            title: AppConst.settings.mySignature,
            trailing: Text(
              controller.signature.value.isEmpty
                  ? AppConst.settings.signatureHint
                  : controller.signature.value,
              style: TextStyle(
                fontSize: 14.w,
                color: controller.signature.value.isEmpty
                    ? Theme.of(context).hintColor
                    : Theme.of(context).primaryColor,
              ),
            ),
            onTap: () => _showSignatureDialog(context),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            title: AppConst.settings.telegramNotification,
            trailing: Text(
              controller.telegramChatId.value.isEmpty
                  ? AppConst.settings.telegramHint
                  : controller.telegramChatId.value,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onTap: () => _showTelegramDialog(context),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            title: AppConst.settings.cardBadge,
            trailing: Text(
              controller.selectedBadge.value?.name ?? '',
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onTap: () => selectCardBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            Row(
              children: [
                trailing,
                8.hGap,
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14.w,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.w, thickness: 1.w, indent: 16.w, endIndent: 16.w);
  }

  void _showIntroductionDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.introduction,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              DisTextField(
                value: controller.introduction.value,
                onChanged: (value) => controller.introduction.value = value,
                maxLines: 5,
                hintText: AppConst.settings.introductionHint,
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: AppConst.settings.save,
                  type: ButtonType.primary,
                  onPressed: () {
                    Get.back();
                    controller.savePreferences();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimezoneDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.timezone,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              Container(
                height: 300.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: ListView.builder(
                  itemCount: controller.timezones.length,
                  itemBuilder: (context, index) {
                    final timezone = controller.timezones[index];
                    return InkWell(
                      onTap: () {
                        controller.timezone.value = timezone;
                        Get.back();
                        controller.savePreferences();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.w,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                timezone,
                                style: TextStyle(
                                  fontSize: 14.w,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                            if (controller.timezone.value == timezone)
                              Icon(
                                CupertinoIcons.checkmark_alt,
                                size: 16.w,
                                color: Theme.of(context).primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegionDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.region,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              DisTextField(
                value: controller.region.value,
                onChanged: (value) => controller.region.value = value,
                hintText: AppConst.settings.useCurrentRegion,
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: AppConst.settings.save,
                  type: ButtonType.primary,
                  onPressed: () {
                    Get.back();
                    controller.savePreferences();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWebsiteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.website,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              DisTextField(
                value: controller.website.value,
                onChanged: (value) => controller.website.value = value,
                hintText: AppConst.settings.websiteHint,
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: AppConst.settings.save,
                  type: ButtonType.primary,
                  onPressed: () {
                    Get.back();
                    controller.savePreferences();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignatureDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.mySignature,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              DisTextField(
                value: controller.signature.value,
                onChanged: (value) => controller.signature.value = value,
                hintText: AppConst.settings.signatureHint,
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: AppConst.settings.save,
                  type: ButtonType.primary,
                  onPressed: () {
                    Get.back();
                    controller.savePreferences();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTelegramDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.telegramNotification,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              DisTextField(
                value: controller.telegramChatId.value,
                onChanged: (value) => controller.telegramChatId.value = value,
                hintText: AppConst.settings.telegramHint,
              ),
              24.vGap,
              SizedBox(
                width: double.infinity,
                child: DisButton(
                  text: AppConst.settings.save,
                  type: ButtonType.primary,
                  onPressed: () {
                    Get.back();
                    controller.savePreferences();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 选择用户卡片徽章
  void selectCardBadge() {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
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
                    AppConst.settings.cardBadge,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(CupertinoIcons.clear, size: 20.w),
                  ),
                ],
              ),
              16.vGap,
              Container(
                height: 300.w,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).cardColor,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  itemCount: controller.badges.length,
                  itemBuilder: (context, index) {
                    final badge = controller.badges[index];
                    return ListTile(
                      title: Text(badge.name),
                      subtitle: Text(
                        badge.description,
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      trailing:
                          controller.selectedBadge.value?.name == badge.name
                          ? Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () {
                        controller.cardBadge.value = badge.name;
                        controller.selectedBadge.value = badge;
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectBirthDate() {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => Container(
        height: 280.w,
        padding: EdgeInsets.only(top: 6.w),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: Theme.of(context).cardColor,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(AppConst.settings.cancel),
                    onPressed: () => Get.back(),
                  ),
                  CupertinoButton(
                    child: Text(AppConst.confirm),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime date) {
                    controller.birthDate.value = '${date.month}-${date.day}';
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
