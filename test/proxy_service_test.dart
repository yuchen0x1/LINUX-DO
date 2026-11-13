import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linux_do/net/proxy_service.dart';
import 'package:linux_do/net/proxy_subscription.dart';
import 'package:linux_do/net/subscription_proxy_core.dart';
import 'package:linux_do/utils/storage_manager.dart';

const fixture = '''
proxies:
 - {name: slow, type: http, server: example.invalid, port: 8080}
 - {name: fast, type: http, server: example.invalid, port: 8081}
''';

class FakeCore implements SubscriptionProxyCore {
  @override
  int? port = 17890;
  String? selected;
  int starts = 0;
  bool rejectStart = false;
  Map<String, int> delays = {'node_1': 180, 'node_2': 40};
  Completer<Map<String, int>>? pending;
  @override
  Future<void> start(Map<String, dynamic> configuration) async {
    starts++;
    if (rejectStart) throw StateError('invalid fixture');
  }

  @override
  Future<Map<String, int>> probe() => pending?.future ?? Future.value(delays);
  @override
  Future<void> select(String nodeId) async {
    selected = nodeId;
  }

  @override
  Future<String?> currentNode() async => selected;
  @override
  Future<void> stop() async {}
}

class MemoryStore implements SubscriptionSettingsStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('secure storage unavailable');
    this.value = value;
  }

  @override
  Future<void> remove() async {
    value = null;
  }
}

// Use real loopback sockets for the transport check, outside the widget HTTP mock.
class _LoopbackHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageManager.init();
  });
  late FakeCore core;
  late MemoryStore store;
  late ProxyService service;
  setUp(() async {
    await StorageManager.clear();
    core = FakeCore();
    store = MemoryStore();
    service = ProxyService.forTesting(
      core: core,
      store: store,
      download: (_) async => fixture,
      applyWebView: () async {},
    );
  });
  tearDown(() {
    service.dispose();
  });

  test(
    'late failures from the previous node cannot discard the new healthy node',
    () async {
      await service.importSubscription('https://example.invalid/sub');
      expect(service.selectedNodeId, 'node_2');
      expect(await service.recover(failedNodeId: 'node_2'), true);
      expect(service.selectedNodeId, 'node_1');
      expect(await service.recover(failedNodeId: 'node_2'), true);
      expect(service.selectedNodeId, 'node_1');
      expect(service.isConnected, true);
      expect(await service.recover(failedNodeId: 'node_1'), false);
      expect(service.errorMessage, contains('全部节点'));
    },
  );

  test(
    'failed nodes are tried once and all-node failure is reported once',
    () async {
      var notifications = 0;
      service.onAllNodesFailed = (_) {
        notifications++;
      };
      await service.importSubscription('https://example.invalid/sub');
      expect(core.selected, 'node_2');
      expect(await service.recover(), true);
      expect(core.selected, 'node_1');
      expect(await service.recover(), false);
      expect(core.selected, 'REJECT');
      expect(await service.recover(), false);
      expect(notifications, 1);
      expect(service.errorMessage, contains('全部节点'));
      expect(await service.recheck(), true);
      expect(service.isConnected, true);
    },
  );

  test(
    'import selects the faster node and failure recovery moves to another',
    () async {
      await service.importSubscription('https://example.invalid/sub');
      expect(service.nodeCount, 2);
      expect(service.selectedNodeName, 'fast');
      expect(service.isConnected, true);
      core.delays = {'node_1': 180};
      expect(await service.recover(), true);
      expect(service.selectedNodeName, 'slow');
    },
  );

  test(
    'all nodes failing retains the proxy route instead of leaking direct',
    () async {
      core.delays = {};
      await service.importSubscription('https://example.invalid/sub');
      expect(service.isConnected, false);
      expect(service.hasValidRule, true);
      expect(service.dioRule, 'PROXY 127.0.0.1:17890');
      expect(service.errorMessage, isNotNull);
    },
  );

  test('credentials are not persisted in preferences and secure storage failure aborts', () async {
    store.fail = true;
    await expectLater(
      service.importSubscription('https://example.invalid/sub?token=fixture'),
      throwsA(isA<SubscriptionException>()),
    );
    expect(core.starts, 0);
    expect(service.isEnabled, false);
    expect(StorageManager.prefs.getKeys(), isEmpty);
  });

  test(
    'a bad replacement preserves the existing imported subscription',
    () async {
      await service.importSubscription('https://example.invalid/old');
      final previous = store.value;
      core.rejectStart = true;
      await expectLater(
        service.importSubscription('https://example.invalid/bad'),
        throwsA(isA<SubscriptionException>()),
      );
      expect(store.value, previous);
      expect(service.subscriptionUrl, 'https://example.invalid/old');
      expect(service.isConnected, true);
    },
  );

  test(
    'concurrent failures share a probe and disabling cancels late selection',
    () async {
      await service.importSubscription('https://example.invalid/sub');
      core.pending = Completer<Map<String, int>>();
      final one = service.recheck();
      final two = service.recover(avoidCurrent: false);
      await service.disable();
      core.pending!.complete({'node_1': 20});
      expect(await one, false);
      expect(await two, false);
      expect(service.isEnabled, false);
      expect(service.selectedNodeName, isNull);
    },
  );

  test(
    'actual Dio traffic uses the loopback proxy even with DoH enabled',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      core.port = server.port;
      final seen = Completer<String>();
      server.listen((request) async {
        if (!seen.isCompleted) seen.complete(request.uri.toString());
        request.response.write('via-proxy');
        await request.response.close();
      });
      await StorageManager.setData('doh_enabled', true);
      await service.importSubscription('https://example.invalid/sub');
      final dio = Dio();
      service.applyToDio(dio);
      try {
        final response = await HttpOverrides.runWithHttpOverrides(
          () => dio.get<String>('http://origin.invalid/proxy-check'),
          _LoopbackHttpOverrides(),
        );
        expect(response.data, 'via-proxy');
        expect(await seen.future, contains('origin.invalid/proxy-check'));
      } finally {
        dio.close(force: true);
        await server.close(force: true);
      }
    },
  );
}
