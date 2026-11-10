import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';

import 'log.dart';

class BrowserUtil {
  static Future<void> openUrlWithOptions({required String url}) async {
    if (Platform.isAndroid) {
      try {
        final systemBarColor = Theme.of(Get.context!).colorScheme.surface;
        await launchUrl(
          Uri.parse(url),
          customTabsOptions: CustomTabsOptions(
            colorSchemes: CustomTabsColorSchemes(
              colorScheme: CustomTabsColorScheme.system,
              // 亮色主题配置
              lightParams: CustomTabsColorSchemeParams(
                toolbarColor: systemBarColor,
                navigationBarColor: systemBarColor,
                navigationBarDividerColor: Colors.transparent,
              ),
              // 暗色主题配置
              darkParams: CustomTabsColorSchemeParams(
                toolbarColor: systemBarColor,
                navigationBarColor: systemBarColor,
                navigationBarDividerColor: Colors.transparent,
              ),
            ),
            shareState: CustomTabsShareState.on,
            urlBarHidingEnabled: true,
            showTitle: true,
            closeButton: const CustomTabsCloseButton(),
          ),
        );
      } catch (e) {
        l.e('打开Custom Tabs失败: $e');
        // 降级到普通浏览器
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      }
    } else {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }
}
