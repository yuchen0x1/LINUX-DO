import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/proxy_subscription.dart';
import 'package:linux_do/net/subscription_proxy_core.dart';

class _LoopbackHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.linux.linuxdo/network_core');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'HTTP 504 from group health checks means all nodes are unavailable',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        expect(request.headers.value('authorization'), 'Bearer fixture-only');
        expect(request.uri.queryParameters['expected'], '200-499');
        request.response.statusCode = 504;
        request.response.headers.contentType = ContentType.json;
        request.response.write('{"message":"get delay: all proxies timeout"}');
        await request.response.close();
      });
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'start'
            ? {
                'port': 17890,
                'controllerPort': server.port,
                'secret': 'fixture-only',
              }
            : null,
      );
      final core = AndroidSubscriptionProxyCore();
      try {
        await core.start({});
        expect(
          await HttpOverrides.runWithHttpOverrides(
            core.probe,
            _LoopbackHttpOverrides(),
          ),
          isEmpty,
        );
      } finally {
        await core.stop();
        await server.close(force: true);
      }
    },
  );

  test(
    'native bridge serializes the node config and reads integer endpoint ports',
    () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        if (call.method == 'start') {
          final config =
              jsonDecode((call.arguments as Map)['config'] as String) as Map;
          expect(config['rules'], ['MATCH,${ProxySubscription.group}']);
          return {
            'port': 17890,
            'controllerPort': 17891,
            'secret': 'fixture-only',
          };
        }
        return null;
      });
      final core = AndroidSubscriptionProxyCore();
      await core.start(
        ProxySubscription.parse(
          'proxies: [{type: http, server: example.invalid, port: 8080}]',
        ).coreConfiguration(),
      );
      expect(core.port, 17890);
      await core.stop();
      expect(core.port, isNull);
      expect(calls, ['start', 'stop']);
    },
  );

  test('native diagnostics do not expose exception contents', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'PROXY_CORE',
        message: 'password=private',
        details: {
          'stage': 'validating-config',
          'type': 'IllegalStateException',
        },
      );
    });
    final core = AndroidSubscriptionProxyCore();
    await expectLater(
      core.start({}),
      throwsA(
        isA<SubscriptionException>()
            .having((e) => e.message.contains('password'), 'redacted', false)
            .having(
              (e) => e.message.contains('validating-config'),
              'stage available',
              true,
            ),
      ),
    );
  });
}
