import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'dart:io' show Platform;

import 'package:get/get.dart';

import '../net/proxy_service.dart';
import '../routes/app_pages.dart';
import 'log.dart';

class BrowserUtil {
  static Future<void> openUrlWithOptions({required String url}) async {
    final uri = Uri.tryParse(url);
    // Custom Tabs 属于系统浏览器，无法继承本应用的代理配置。
    if (ProxyService().isEnabled &&
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http')) {
      Get.toNamed(Routes.WEBVIEW, arguments: url);
      return;
    }
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
