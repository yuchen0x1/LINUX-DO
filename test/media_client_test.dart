import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linux_do/net/media_client.dart';
import 'package:linux_do/net/proxy_service.dart';
import 'package:linux_do/utils/storage_manager.dart';

class _LoopbackHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('图片下载经过登录代理且不向图片站发送论坛凭据', () async {
    SharedPreferences.setMockInitialValues({});
    await StorageManager.init();
    await HttpOverrides.runWithHttpOverrides(() async {
      final proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = <HttpRequest>[];
      proxy.listen((request) async {
        received.add(request);
        request.response.headers.contentType = ContentType.binary;
        request.response.add([1, 2, 3]);
        await request.response.close();
      });
      try {
        await StorageManager.setData(ProxyService.keyEnabled, true);
        await StorageManager.setData(ProxyService.keyMode, 'manual');
        await StorageManager.setData(ProxyService.keyHost, '127.0.0.1');
        await StorageManager.setData(ProxyService.keyPort, '${proxy.port}');
        final response = await MediaClient.dio.get<List<int>>(
          'http://image.invalid/original.png',
          options: Options(responseType: ResponseType.bytes),
        );
        expect(response.data, [1, 2, 3]);
        expect(received, hasLength(1));
        expect(received.single.uri.host, 'image.invalid');
        for (final name in ['Cookie', 'User-Api-Key', 'X-CSRF-Token']) {
          expect(received.single.headers.value(name), isNull);
        }
      } finally {
        MediaClient.dio.close(force: true);
        await proxy.close(force: true);
        await StorageManager.clear();
      }
    }, _LoopbackHttpOverrides());
  });
}
