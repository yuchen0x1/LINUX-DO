import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linux_do/main.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageManager.init();
  });

  testWidgets('startup page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(designSize: Size(1024, 768), initialRoute: Routes.STARTUP),
    );
    await tester.pump();

    expect(find.text('真诚'), findsOneWidget);
    expect(find.text('下一步'), findsOneWidget);
  });
}
