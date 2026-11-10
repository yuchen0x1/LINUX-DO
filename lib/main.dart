import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/app.dart';
import 'package:linux_do/utils/crash_reporter.dart';
import 'package:linux_do/utils/storage_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 尽早挂载全局异常处理，后续初始化出错也能被记录
  CrashReporter.install();

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化App
  await App.instance.initial();

  // 确定初始路由
  final initialRoute = await _determineInitialRoute();

  Size size = Platform.isMacOS ? const Size(1024, 768) : const Size(375, 812);

  runApp(MyApp(designSize: size, initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  // 检查是否首次启动
  final hasLaunched =
      StorageManager.getBool(AppConst.identifier.isFirst) ?? false;
  if (!hasLaunched) {
    return Routes.STARTUP;
  }

  // 检查登录状态
  final hasLogin = await Get.find<GlobalController>().checkLoginStatus();
  final isAnonymousMode =
      StorageManager.getBool(AppConst.identifier.isAnonymousMode) ?? false;
  return isAnonymousMode || hasLogin ? Routes.HOME : Routes.LOGIN;
}

class MyApp extends StatelessWidget {
  final Size designSize;
  final String initialRoute;

  const MyApp({Key? key, required this.designSize, required this.initialRoute})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化屏幕适配
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConst.siteName,
          debugShowCheckedModeBanner: false,

          /// 国际化配置
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppConst.supportedLanguages
              .map((e) => Locale(e))
              .toList(),

          // 主题配置
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getSavedThemeMode(),

          // 路由配置
          initialRoute: initialRoute, // 使用动态初始路由
          getPages: AppPages.routes,

          // 默认转场动画
          defaultTransition: Transition.cupertino,

          // 错误页面
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const Scaffold(body: Center(child: Text('页面不存在'))),
          ),

          // 全局设置
          builder: (context, child) {
            // 获取当前主题模式
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isAmoled = _getSavedTheme() == 'amoled';
            final themeColor = AppColors.getStoredColor();

            // 使用主题数据包装子组件
            Widget? result = child;
            if (isAmoled || themeColor != null) {
              var themeData = Theme.of(context);
              if (isAmoled && isDark) {
                themeData = AppTheme.amoledTheme;
              }
              if (themeColor != null) {
                // 与设置页换色一致：保留整套主题样式，只替换主色
                themeData = AppTheme.withPrimaryColor(
                  base: themeData,
                  primary: themeColor,
                );
              }
              result = Theme(data: themeData, child: child!);
            }

            // 根据主题设置系统UI样式
            if (Platform.isAndroid) {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarColor: isDark
                      ? (isAmoled ? Colors.black : const Color(0xFF121212))
                      : Colors.white,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
              );
            }

            return GestureDetector(
              // 点击空白处收起键盘
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: result!,
            );
          },
        );
      },
    );
  }

  String _getSavedTheme() {
    return StorageManager.getString(AppConst.identifier.theme) ?? 'system';
  }

  // 从存储中获取保存的主题模式
  ThemeMode _getSavedThemeMode() {
    switch (_getSavedTheme()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
