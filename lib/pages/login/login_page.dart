import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_sizes.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import '../../const/app_spacing.dart';
import '../../const/app_images.dart';
import '../../const/app_const.dart';
import '../../widgets/dis_button.dart';
import '../../widgets/proxy_settings_dialog.dart';
import 'login_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_html/flutter_html.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  /// 显示协议对话框
  Future<void> showAgreementDialog(
      BuildContext context, String title, String htmlAsset) async {
    try {
      final htmlContent = await rootBundle.loadString(htmlAsset);
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusTiny),
          ),
          child: Container(
            width: double.infinity,
            height: Get.height * 0.8,
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            Theme.of(Get.context!).textTheme.titleLarge?.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                8.vGap,
                Expanded(
                  child: SingleChildScrollView(
                    child: Html(
                      data: htmlContent,
                      style: {
                        "body": Style(
                          padding: HtmlPaddings.zero,
                          color: Theme.of(Get.context!)
                              .textTheme
                              .bodyMedium
                              ?.color,
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 4.w),
                          fontSize: FontSize(AppSizes.fontSmall),
                        ),
                        "h1": Style(
                          margin: Margins.only(bottom: 12.w),
                          fontSize: FontSize(18.sp),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                        "h2": Style(
                          margin: Margins.only(top: 16.w, bottom: 4.w),
                          fontSize: FontSize(AppSizes.fontNormal),
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                        "ul": Style(
                          margin: Margins.only(bottom: 4.w),
                          padding: HtmlPaddings.only(left: 16.w),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 2.w),
                          fontSize: FontSize(AppSizes.fontTiny),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      controller.showSnackbar(
        title: '加载失败',
        message: '无法加载$title文件',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => Material(
        child: controller.isChecking.value
            ? const Center(
                child: DisSquareLoading(),
              )
            : _buildContent(context),
      ),
    ));
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // 顶部背景
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            AppImages.getHeaderBackground(context),
            fit: BoxFit.fill,
          ),
        ),

        // 主要内容
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSizes.speceMedium20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * .18),
                    Text.rich(TextSpan(
                        text: AppConst.login.greetingPhrase,
                        style: TextStyle(
                            fontSize: AppSizes.fontLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white),
                        children: [
                          TextSpan(
                            text: ' ${AppConst.siteName}',
                            style: TextStyle(
                                fontSize: AppSizes.fontEnormousb,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFontFamily.dinPro,
                                color: AppColors.white),
                          )
                        ])),
                    SizedBox(height: MediaQuery.of(context).size.height * .18),

                    Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: controller.scanLogin,
                        color: theme.primaryColor,
                        icon: const Icon(CupertinoIcons.qrcode),
                      ),
                    ),
                    // 账号输入框
                    // Container(
                    //   height: AppSizes.spaceHuge44,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: theme.hintColor.withValues(alpha: .2),
                    //       width: 1,
                    //     ),
                    //     borderRadius:
                    //         BorderRadius.circular(AppSizes.radiusTiny),
                    //   ),
                    //   child: TextField(
                    //     style: TextStyle(fontSize: AppSizes.fontNormal),
                    //     onChanged: (value) => controller.username.value = value,
                    //     decoration: InputDecoration(
                    //       hintText: AppConst.login.accountHint,
                    //       hintStyle: TextStyle(
                    //         fontSize: AppSizes.fontNormal,
                    //         color: theme.hintColor.withValues(alpha: .2),
                    //       ),
                    //       filled: false,
                    //       fillColor: Colors.transparent,
                    //       border: InputBorder.none,
                    //       prefixIcon: Padding(
                    //         padding: EdgeInsets.all(AppSizes.spaceSmall10),
                    //         child: Image.asset(
                    //           AppImages.getInputAccount(context),
                    //           width: AppSizes.iconTiny,
                    //           height: AppSizes.iconTiny,
                    //           color: Theme.of(context).primaryColor,
                    //         ),
                    //       ),
                    //       isDense: true,
                    //       contentPadding: EdgeInsets.symmetric(
                    //         horizontal: AppSizes.spaceMedium,
                    //         vertical: AppSizes.spaceSmall10,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // 16.vGap,
                    // // 密码输入框
                    // Container(
                    //   height: AppSizes.spaceHuge44,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: theme.hintColor.withValues(alpha: .2),
                    //       width: 1,
                    //     ),
                    //     borderRadius:
                    //         BorderRadius.circular(AppSizes.radiusTiny),
                    //   ),
                    //   child: Obx(
                    //     () => TextField(
                    //       style: TextStyle(fontSize: AppSizes.fontNormal),
                    //       onChanged: (value) =>
                    //           controller.password.value = value,
                    //       obscureText: !controller.isPasswordVisible.value,
                    //       decoration: InputDecoration(
                    //         hintText: AppConst.login.passwordHint,
                    //         hintStyle: TextStyle(
                    //           fontSize: AppSizes.fontNormal,
                    //           color: theme.hintColor.withValues(alpha: .2),
                    //         ),
                    //         filled: false,
                    //         fillColor: Colors.transparent,
                    //         border: InputBorder.none,
                    //         prefixIcon: Padding(
                    //           padding: EdgeInsets.all(AppSizes.spaceNormal),
                    //           child: Image.asset(
                    //             AppImages.getInputPassword(context),
                    //             width: AppSizes.iconTiny,
                    //             height: AppSizes.iconTiny,
                    //             color: Theme.of(context).primaryColor,
                    //           ),
                    //         ),
                    //         suffixIcon: IconButton(
                    //           icon: Icon(
                    //             controller.isPasswordVisible.value
                    //                 ? CupertinoIcons.eye_fill
                    //                 : CupertinoIcons.eye_slash,
                    //             color: theme.hintColor,
                    //             size: AppSizes.spaceMedium,
                    //           ),
                    //           onPressed: controller.togglePasswordVisibility,
                    //         ),
                    //         isDense: true,
                    //         contentPadding: EdgeInsets.symmetric(
                    //           horizontal: AppSizes.spaceMedium,
                    //           vertical: AppSizes.spaceSmall10,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // 忘记密码和注册
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     TextButton(
                    //       onPressed: controller.forgetPassword,
                    //       style: TextButton.styleFrom(
                    //         padding: EdgeInsets.zero,
                    //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //       ),
                    //       child: Text(
                    //         AppConst.login.forgotPassword,
                    //         style: TextStyle(
                    //           fontSize: AppSizes.fontSmall,
                    //           color: theme.hintColor,
                    //         ),
                    //       ),
                    //     ),
                    //     Row(
                    //       children: [
                    //         Text(
                    //           AppConst.login.noAccount,
                    //           style: TextStyle(
                    //             fontSize: AppSizes.fontSmall,
                    //             color: theme.hintColor,
                    //           ),
                    //         ),
                    //         TextButton(
                    //           onPressed: controller.reigster,
                    //           style: TextButton.styleFrom(
                    //             padding: EdgeInsets.zero,
                    //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //           ),
                    //           child: Text(
                    //             AppConst.login.register,
                    //             style: TextStyle(
                    //               fontSize: AppSizes.fontSmall,
                    //               color: theme.primaryColor,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    24.vGap,
                    // 登录按钮
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 44.w,
                    //   child: Obx(
                    //     () => DisButton(
                    //       text: AppConst.login.title,
                    //       type: ButtonType.primary,
                    //       size: ButtonSize.large,
                    //       onPressed: controller.loginTips,
                    //       loading: controller.isLoading.value,
                    //     ),
                    //   ),
                    // ),
                    // 12.vGap,
                    // Web 登录按钮
                    SizedBox(
                      width: double.infinity,
                      height: 44.w,
                      child: DisButton(
                        text: AppConst.login.webTitle,
                        type: ButtonType.outline,
                        size: ButtonSize.large,
                        onPressed: controller.webLogin,
                      ),
                    ),
                    10.vGap,
                    // 官方 User API Key 登录按钮
                    SizedBox(
                      width: double.infinity,
                      height: 44.w,
                      child: DisButton(
                        text: '官方 API Key 授权登录',
                        type: ButtonType.primary,
                        size: ButtonSize.large,
                        onPressed: controller.apiKeyLogin,
                      ),
                    ),
                    8.vGap,
                    // 网络线路 / 代理入口（国内直连不通时使用）
                    ProxyEntryTile(),
                    4.vGap,
                    // 全部网页登录方式提示
                    Center(
                      child: Text(
                        '网页授权登录内支持 Google / GitHub / Discord /\nApple / 通行密钥 等全部登录方式',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.hintColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 底部协议
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toHome(),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                AppConst.login.anonymousMode,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(() => GestureDetector(
                                    onTap: () => controller
                                            .isAgreementChecked.value =
                                        !controller.isAgreementChecked.value,
                                    child: Container(
                                      width: 16.w,
                                      height: 16.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: controller
                                                  .isAgreementChecked.value
                                              ? theme.primaryColor
                                              : theme.hintColor
                                                  .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(3.w),
                                        color:
                                            controller.isAgreementChecked.value
                                                ? theme.primaryColor
                                                : Colors.transparent,
                                      ),
                                      child: controller.isAgreementChecked.value
                                          ? Icon(
                                              CupertinoIcons.checkmark,
                                              size: 12.w,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  )),
                              4.hGap,
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    text: AppConst.login.agreement,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.hintColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: AppConst.login.serviceAgreement,
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showAgreementDialog(
                                                context,
                                                AppConst.login.serviceAgreement,
                                                AppConst.terms,
                                              ),
                                      ),
                                      TextSpan(text: ' ${AppConst.login.and} '),
                                      TextSpan(
                                        text: AppConst.login.privacyPolicy,
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showAgreementDialog(
                                                context,
                                                AppConst.login.privacyPolicy,
                                                AppConst.privacy,
                                              ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    20.vGap,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
