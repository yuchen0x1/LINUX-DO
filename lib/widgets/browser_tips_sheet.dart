import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserTipsSheet extends StatelessWidget {
  final String url;
  const BrowserTipsSheet({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16).w,
          topRight: const Radius.circular(16).w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.w),
            width: 36.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          // 标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            child: Text(
              AppConst.posts.openBrowser,
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // URL 预览
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              url,
              style: TextStyle(
                fontSize: 12.w,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontFamily.dinPro,
                color: Theme.of(Get.context!).hintColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          16.vGap,
          // 选项按钮
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildOptionButton(
                  icon: CupertinoIcons.compass,
                  title: AppConst.posts.openInApp,
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.WEBVIEW, arguments: url);
                  },
                ),
                12.vGap,
                _buildOptionButton(
                  icon: CupertinoIcons.arrowshape_turn_up_right_circle,
                  title: AppConst.posts.openInBrowser,
                  onTap: () async {
                    Get.back();
                    try {
                      await launchUrlString(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      l.e('打开浏览器失败: $e');
                    }
                  },
                ),
              ],
            ),
          ),
          // 底部安全区域
          SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(Get.context!).dividerColor.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.w),
              12.hGap,
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16.w,
                color: Theme.of(Get.context!).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context, String url) async {
    return Get.bottomSheet(
      BrowserTipsSheet(url: url),
      enterBottomSheetDuration: const Duration(milliseconds: 200),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }
}
