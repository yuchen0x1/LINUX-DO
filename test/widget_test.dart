import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/main.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/pages/login/login_page.dart';
import 'package:linux_do/pages/startup/startup_page.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';

class _SessionController extends GlobalController {
  _SessionController(this.checkSession);

  final Future<bool> Function() checkSession;
  int checkCalls = 0;

  @override
  Future<bool> checkLoginStatus() {
    checkCalls++;
    return checkSession();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageManager.init();
  });

  setUp(() async {
    Get.testMode = true;
    await StorageManager.clear();
    await StorageManager.setData(AppConst.identifier.clientId, 'startup-test');
    Get.put(ApiService(Dio()));
  });

  tearDown(() {
    Get.reset();
  });

  _SessionController session(Future<bool> Function() check) =>
      Get.put<GlobalController>(_SessionController(check))
          as _SessionController;

  Widget routeHarness({bool reduceMotion = false}) => GetMaterialApp(
    initialRoute: Routes.STARTUP,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    getPages: [
      AppPages.routes.first,
      GetPage(
        name: Routes.LOGIN,
        page: () => const Scaffold(body: Text('login destination')),
      ),
      GetPage(
        name: Routes.HOME,
        page: () => const Scaffold(body: Text('home destination')),
      ),
    ],
  );

  for (final hasLaunched in [false, true]) {
    testWidgets(
      'cold launch reaches login without taps (old flag: $hasLaunched)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(
          () =>
              StorageManager.setData(AppConst.identifier.isFirst, hasLaunched),
        );
        session(() async => false);

        await tester.pumpWidget(const MyApp(designSize: Size(375, 812)));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(StartupPage), findsOneWidget);
        expect(find.text('LINUX DO'), findsOneWidget);
        expect(find.byType(PageView), findsNothing);
        expect(find.text('下一步'), findsNothing);
        expect(find.text('进入应用'), findsNothing);

        await tester.pump(StartupPage.animationDuration);
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
        expect(Get.currentRoute, Routes.LOGIN);
        expect(Get.key.currentState!.canPop(), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('existing session enters home after the animation', (
    tester,
  ) async {
    session(() async => true);
    await tester.pumpWidget(routeHarness());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('home destination'), findsNothing);

    await tester.pump(StartupPage.animationDuration);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.HOME);
    expect(Get.key.currentState!.canPop(), isFalse);
  });

  testWidgets('saved guest mode enters home without a login probe', (
    tester,
  ) async {
    await tester.runAsync(
      () => StorageManager.setData(AppConst.identifier.isAnonymousMode, true),
    );
    final global = session(
      () => throw StateError('guest must not probe login'),
    );
    await tester.pumpWidget(routeHarness());
    await tester.pump(StartupPage.animationDuration);
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.HOME);
    expect(global.isAnonymousMode, isTrue);
    expect(global.checkCalls, 0);
  });

  testWidgets('reduced motion does not wait for the startup animation', (
    tester,
  ) async {
    session(() async => false);
    await tester.pumpWidget(routeHarness(reduceMotion: true));
    await tester.pump();
    expect(Get.currentRoute, Routes.LOGIN);
    await tester.pumpAndSettle();
    expect(find.text('login destination'), findsOneWidget);
  });

  testWidgets(
    'a late session result cannot navigate after startup is removed',
    (tester) async {
      final pendingSession = Completer<bool>();
      session(() => pendingSession.future);
      await tester.pumpWidget(routeHarness());
      await tester.pump(StartupPage.animationDuration);
      await tester.pump();
      expect(Get.currentRoute, Routes.STARTUP);

      Get.offAllNamed(Routes.LOGIN);
      await tester.pumpAndSettle();
      pendingSession.complete(true);
      await tester.pumpAndSettle();

      expect(Get.currentRoute, Routes.LOGIN);
      expect(find.text('home destination'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
