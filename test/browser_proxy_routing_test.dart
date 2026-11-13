import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linux_do/net/proxy_service.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/browser_util.dart';
import 'package:linux_do/utils/storage_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageManager.init();
  });
  setUp(() async {
    await StorageManager.setData(ProxyService.keyEnabled, true);
    Get.testMode = true;
  });
  tearDown(() async {
    Get.reset();
    await StorageManager.clear();
  });

  testWidgets('启用代理后默认网页入口留在应用内浏览器', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(
            name: Routes.WEBVIEW,
            page: () => Scaffold(body: Text(Get.arguments as String)),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    const url = 'https://tool.example.invalid/';
    await BrowserUtil.openUrlWithOptions(url: url);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.WEBVIEW);
    expect(find.text(url), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
