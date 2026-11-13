import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/proxy_http_overrides.dart';

class _ConfiguredOverrides extends HttpOverrides {
  SecurityContext? receivedContext;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    receivedContext = context;
    return super.createHttpClient(context)
      ..userAgent = 'preserved-client-setting'
      ..connectionTimeout = const Duration(seconds: 3);
  }
}

class _ZoneClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String> _read(HttpClient client, Uri uri) async {
  final request = await client.getUrl(uri);
  final response = await request.close();
  return utf8.decoder.bind(response).join();
}

void main() {
  late HttpOverrides? previousGlobal;
  setUp(() {
    previousGlobal = Zone.root.run(() => HttpOverrides.current);
  });
  tearDown(() {
    HttpOverrides.global = previousGlobal;
  });

  test(
    'preserves an existing client and its security context without recursion',
    () {
      final previous = _ConfiguredOverrides();
      final securityContext = SecurityContext();
      final overrides = ProxyHttpOverrides(
        findProxy: (_) => 'DIRECT',
        previous: previous,
      );
      final client = overrides.createHttpClient(securityContext);
      try {
        expect(identical(previous.receivedContext, securityContext), true);
        expect(client.userAgent, 'preserved-client-setting');
        expect(client.connectionTimeout, const Duration(seconds: 3));
      } finally {
        client.close(force: true);
      }
    },
  );

  test(
    'installing the global route leaves a Zone-specific mock authoritative',
    () {
      final zoneClient = _ZoneClient();
      HttpOverrides.runZoned(() {
        final zoneOverrides = HttpOverrides.current;
        ProxyHttpOverrides.install(findProxy: (_) => 'PROXY 127.0.0.1:1');
        expect(identical(HttpOverrides.current, zoneOverrides), true);
        expect(identical(HttpClient(), zoneClient), true);
        expect(
          Zone.root.run(() => HttpOverrides.current),
          isA<ProxyHttpOverrides>(),
        );
      }, createHttpClient: (_) => zoneClient);
    },
  );

  test(
    'one existing default client switches direct, proxy, and direct again',
    () async {
      final origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var originRequests = 0;
      final proxiedUris = <Uri>[];
      origin.listen((request) async {
        originRequests++;
        request.response.write('direct');
        await request.response.close();
      });
      proxy.listen((request) async {
        proxiedUris.add(request.uri);
        request.response.write('proxied');
        await request.response.close();
      });
      var route = 'DIRECT';
      final overrides = ProxyHttpOverrides(findProxy: (_) => route);
      final client = HttpOverrides.runWithHttpOverrides(
        HttpClient.new,
        overrides,
      )..connectionTimeout = const Duration(seconds: 2);
      final uri = Uri.parse('http://127.0.0.1:${origin.port}/image.png');
      try {
        expect(await _read(client, uri), 'direct');
        route = 'PROXY 127.0.0.1:${proxy.port}';
        expect(await _read(client, uri), 'proxied');
        route = 'DIRECT';
        expect(await _read(client, uri), 'direct');
        expect(originRequests, 2);
        expect(proxiedUris, [uri]);
      } finally {
        client.close(force: true);
        await origin.close(force: true);
        await proxy.close(force: true);
      }
    },
  );

  test(
    'explicit direct clients bypass the image route for core and bootstrap',
    () async {
      final origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      origin.listen((request) async {
        request.response.write('controller-direct');
        await request.response.close();
      });
      final client = ProxyHttpOverrides(
        findProxy: (_) => 'PROXY 127.0.0.1:1',
      ).createHttpClient(null)..findProxy = (_) => 'DIRECT';
      try {
        expect(
          await _read(client, Uri.parse('http://127.0.0.1:${origin.port}/')),
          'controller-direct',
        );
      } finally {
        client.close(force: true);
        await origin.close(force: true);
      }
    },
  );
}
