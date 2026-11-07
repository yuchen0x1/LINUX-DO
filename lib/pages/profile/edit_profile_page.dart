import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.settings.editProfile,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Obx(() => SizedBox(
            width: 60.w,
            height: 30.w,
            child: DisButton(
                text: AppConst.settings.save,
                type: ButtonType.transform,
                loading: controller.isSaving.value,
                onPressed: controller.saveProfile,
              ),
          ),),
          16.hGap
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像部分
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: controller.pickAvatar,
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: .6),
                          width: 4.w,
                        ),
                      ),
                      child: ClipOval(
                        child: Obx(() => controller.isUploading.value
                          ? Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                child: DisRefreshLoading()
                              ),
                            )
                          : CachedImage(
                              imageUrl: controller.avatarUrl.value,
                              placeholder: Icon(
                                CupertinoIcons.person_fill,
                                size: 40.w,
                                color: Theme.of(context).hintColor.withValues(alpha: .2),
                              ),
                            ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6.w,
                    bottom: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: .5),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: .1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.camera_fill,
                        size: 12.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            24.vGap,
            // 基本信息部分
            _buildSection(
              context,
              title: AppConst.settings.basicInfo,
              children: [
                _buildTextField(
                  context,
                  label: AppConst.settings.name,
                  controller: controller.nameController,
                  hintText: AppConst.settings.inputName,
                ),
                _buildDivider(context),
                _buildTextField(
                  context,
                  label: AppConst.settings.username,
                  controller: controller.usernameController,
                  enabled: false,
                  hintText: AppConst.settings.usernameNotEditable,
                ),
                _buildDivider(context),

                _buildUserTitle(context),
              ],
            ),
            24.vGap,
            // 联系方式部分
            _buildSection(
              context,
              title: AppConst.settings.contact,
              children: [
                _buildTextField(
                  context,
                  label: AppConst.settings.email,
                  controller: controller.emailController,
                  enabled: false,
                  hintText: AppConst.settings.emailNotEditable,
                ),
                _buildDivider(context),
                _buildTextField(
                  context,
                  label: AppConst.settings.backupEmail,
                  controller: controller.backupEmailController,
                  hintText: AppConst.settings.inputBackupEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            24.vGap,
            // 关联账户部分
            _buildSection(
              context,
              title: AppConst.settings.linkedAccounts,
              children: [
                for (var account in controller.linkedAccounts)
                  _buildAccountItem(context, account),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Container _buildUserTitle(BuildContext context) {
    return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: .1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80.w,
                      child: Text(
                        AppConst.settings.userTitle,
                        style: TextStyle(
                          fontSize: 14.w,
                          fontFamily: AppFontFamily.dinPro,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    12.hGap,
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8.w),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withValues(alpha: .1),
                          ),
                        ),
                        child: Obx(() => DropdownButton<String>(
                          value: controller.userTitle.value,
                          isExpanded: true,
                          focusColor: Theme.of(context).cardColor,
                          dropdownColor: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.w),
                          underline: const SizedBox(),
                          hint: Text(
                            AppConst.settings.noBadge,
                            style: TextStyle(
                              fontSize: 14.w,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          items: controller.badges.map((badge) {
                            return DropdownMenuItem<String>(
                              value: badge.name,
                              child: Text(
                                badge.name,
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontFamily: AppFontFamily.dinPro,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.userTitle.value = newValue;
                            }
                          },
                        )),
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16.w,
      color: Theme.of(context).dividerColor.withValues(alpha: .7),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        12.vGap,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    final Color backgroundColor = enabled 
        ? Theme.of(context).cardColor
        : Theme.of(context).disabledColor.withValues(alpha: .03);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .1),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.w,
                fontFamily: AppFontFamily.dinPro,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          12.hGap,
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14.w,
                fontFamily: AppFontFamily.dinPro,
                color: enabled 
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).disabledColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: backgroundColor,
                hintStyle: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).hintColor.withValues(alpha: .5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: .1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: .05),
                  ),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, Map<String, dynamic> account) {
    final accountType = account['name'] as String?;
    final accountDesc = account['description'] as String?;
    final bool isLinked = accountDesc != null;
    final bool isLastItem = controller.linkedAccounts.last['name'] == accountType;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    _getAccountIcon(accountType),
                    size: 16.w,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              12.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAccountDisplayName(accountType),
                      style: TextStyle(
                        fontSize: 14.w,
                        fontFamily: AppFontFamily.dinPro,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (isLinked) ...[
                      4.vGap,
                      Text(
                        accountDesc,
                        style: TextStyle(
                          fontSize: 12.w,
                          fontFamily: AppFontFamily.dinPro,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLinked)
                DisButton(
                  text: AppConst.settings.unlink,
                  type: ButtonType.outline,
                  size: ButtonSize.small,
                  onPressed: () => controller.unlinkAccount(accountType ?? ''),
                )
              else
                DisButton(
                  text: AppConst.settings.link,
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  onPressed: () => controller.linkAccount(accountType ?? ''),
                ),
            ],
          ),
        ),
        if (!isLastItem)
          _buildDivider(context),
      ],
    );
  }

  FaIconData _getAccountIcon(String? type) {
    switch (type) {
      case 'google_oauth2':
        return FontAwesomeIcons.google;
      case 'github':
        return FontAwesomeIcons.github;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'discord':
        return FontAwesomeIcons.discord;
      default:
        return FontAwesomeIcons.link;
    }
  }

  String _getAccountDisplayName(String? type) {
    switch (type) {
      case 'google_oauth2':
        return 'Google';
      case 'github':
        return 'GitHub';
      case 'twitter':
        return 'Twitter';
      case 'discord':
        return 'Discord';
      default:
        return AppConst.settings.unknownAccount;
    }
  }
} 