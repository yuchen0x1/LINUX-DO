import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/app_version.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/net/update_checker.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/glowing_text_wweep.dart';
import 'package:url_launcher/url_launcher.dart';

class DisAppUpdate {
  static void showUpdateDialog(AppVersion appVersion) {
    // 更新内容列表
    final List<String> updateItems = appVersion.releaseNotes?.split('\n') ?? [];
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24).w,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16).w,
        ),
        backgroundColor: Theme.of(Get.context!).cardColor,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16).w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ).w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(Get.context!).primaryColor,
                          Theme.of(
                            Get.context!,
                          ).primaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16).w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '发现新版本',
                          style: TextStyle(
                            fontSize: 20.w,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFontFamily.dinPro,
                            color: Colors.white,
                          ),
                        ),
                        4.vGap,
                        Text(
                          'Experience the new upgrade...',
                          style: TextStyle(
                            fontSize: 14.w,
                            fontFamily: AppFontFamily.dinPro,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        16.vGap,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ).w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Text(
                            'v${appVersion.latestVersion}',
                            style: TextStyle(
                              fontSize: 12.w,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontFamily.dinPro,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -36,
                    top: 40,
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: GlowingTextSweep(
                        text: 'LINUX.DO',
                        style: TextStyle(
                          fontSize: 52.w,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFontFamily.dinPro,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        glowColor: Colors.white,
                        sweepDuration: const Duration(seconds: 2),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 220.w),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ).w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: updateItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == updateItems.length - 1 ? 0 : 12,
                        ).w,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 6.w),
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  Get.context!,
                                ).textTheme.titleSmall?.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            12.hGap,
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  height: 1.5,
                                  color: Theme.of(
                                    Get.context!,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 底部按钮区域
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(16).w,
                    bottomRight: const Radius.circular(16).w,
                  ),
                ),
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: DisButton(
                        text: AppConst.settings.cancelUpdate,
                        type: ButtonType.outline,
                        onPressed: () => Get.back(),
                      ),
                    ),
                    12.hGap,
                    Expanded(
                      child: DisButton(
                        text: AppConst.settings.updateNow,
                        type: ButtonType.primary,
                        onPressed: () {
                          Get.back();
                          final raw = appVersion.downloadUrl;
                          if (raw == null || raw.isEmpty) return;

                          // GitHub 源给绝对地址；旧自建接口给相对路径
                          final url = raw.startsWith('http')
                              ? raw
                              : '${HttpConfig.otherUrl}$raw';

                          if (!UpdateChecker.isTrustedDownload(url)) {
                            l.w('拒绝打开非可信下载地址: $url');
                            return;
                          }
                          l.d('下载地址: $url');
                          launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 底部提示
              // Container(
              //   padding: EdgeInsets.only( bottom: 24).w,
              //   child: Text(
              //     '今日不在提示',
              //   ),
              // ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
    );
  }
}
