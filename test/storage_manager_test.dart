import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linux_do/utils/storage_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('initializes once when first storage operations overlap', () async {
    final results = await Future.wait([
      StorageManager.setData('first', 'value'),
      StorageManager.setData('second', 2),
    ]);

    expect(results, everyElement(isTrue));
    expect(StorageManager.getString('first'), 'value');
    expect(StorageManager.getInt('second'), 2);
  });
}
