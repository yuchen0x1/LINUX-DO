import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linux_do/pages/home/widgets/home_bottom_bar.dart';

void main() {
  Widget harness({
    required double bottomInset,
    bool visible = true,
    bool keyboardOpen = false,
    ValueChanged<int>? onTap,
  }) => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(375, 812),
          padding: EdgeInsets.only(bottom: keyboardOpen ? 0 : bottomInset),
          viewPadding: EdgeInsets.only(bottom: bottomInset),
          viewInsets: EdgeInsets.only(bottom: keyboardOpen ? 300 : 0),
        ),
        child: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: HomeBottomBar(
            isVisible: visible,
            currentIndex: 0,
            onTap: onTap ?? (_) {},
          ),
        ),
      ),
    ),
  );

  for (final bottomInset in [0.0, 24.0, 48.0]) {
    testWidgets('all navigation buttons clear the $bottomInset bottom inset', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final tapped = <int>[];
      await tester.pumpWidget(
        harness(bottomInset: bottomInset, onTap: tapped.add),
      );
      await tester.pumpAndSettle();

      final barRect = tester.getRect(find.byType(HomeBottomBar));
      for (final icon in [
        CupertinoIcons.square_list_fill,
        CupertinoIcons.square_split_2x2_fill,
        CupertinoIcons.add,
        CupertinoIcons.app_badge_fill,
        CupertinoIcons.person_crop_square_fill,
      ]) {
        final button = find.ancestor(
          of: find.byIcon(icon),
          matching: find.byType(InkWell),
        );
        final buttonRect = tester.getRect(button);
        expect(buttonRect.top, greaterThanOrEqualTo(barRect.top));
        expect(buttonRect.bottom, lessThanOrEqualTo(812 - bottomInset - 8));
        await tester.tap(button);
      }
      expect(tapped, [0, 1, 2, 3, 4]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keyboard does not discard the navigation safe area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness(bottomInset: 24));
    await tester.pumpAndSettle();
    final closedRect = tester.getRect(find.byType(HomeBottomBar));

    await tester.pumpWidget(harness(bottomInset: 24, keyboardOpen: true));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(HomeBottomBar)), closedRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation collapses and returns at its full content height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness(bottomInset: 24));
    await tester.pumpAndSettle();
    final shownHeight = tester.getSize(find.byType(HomeBottomBar)).height;

    await tester.pumpWidget(harness(bottomInset: 24, visible: false));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(HomeBottomBar)).height, 0);

    await tester.pumpWidget(harness(bottomInset: 24));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(HomeBottomBar)).height, shownHeight);
    expect(tester.takeException(), isNull);
  });
}
