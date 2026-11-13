import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/proxy_subscription.dart';

void main() {
  test('imports all protocol types in the supplied subscription format', () {
    final text = jsonEncode({
      'proxies': [
        for (final type in [
          'http',
          'vless',
          'ss',
          'socks5',
          'hysteria2',
          'anytls',
        ])
          {
            'name': 'same name',
            'type': type,
            'server': 'example.invalid',
            'port': 443,
            'password': 'fixture',
            'uuid': '00000000-0000-0000-0000-000000000001',
          },
      ],
    });
    final subscription = ProxySubscription.parse(text);
    expect(subscription.nodes.length, 6);
    expect(subscription.nodes.map((node) => node.id).toSet().length, 6);
    expect(subscription.nodes[4].configuration['password'], 'fixture');
  });

  test('remote rules, providers and listeners cannot override app routing', () {
    final subscription = ProxySubscription.parse('''
mixed-port: 9999
allow-lan: true
external-controller: 0.0.0.0:1234
proxy-providers: {remote: {url: https://example.invalid/private}}
rules: [MATCH,DIRECT]
proxies:
  - {name: DIRECT, type: http, server: example.invalid, port: 8080, dialer-proxy: remote}
''');
    final config = subscription.coreConfiguration();
    expect(config['allow-lan'], false);
    expect(config['bind-address'], '127.0.0.1');
    expect(config.containsKey('external-controller'), false);
    expect(config.containsKey('proxy-providers'), false);
    expect(config['rules'], ['MATCH,${ProxySubscription.group}']);
    expect(
      subscription.nodes.single.configuration.containsKey('dialer-proxy'),
      false,
    );
    expect(subscription.nodes.single.id, isNot('DIRECT'));
  });

  test('invalid and unsupported nodes are counted and skipped', () {
    final subscription = ProxySubscription.parse(
      jsonEncode({
        'proxies': [
          {'type': 'unknown', 'server': 'example.invalid', 'port': 80},
          {'type': 'http', 'server': 'bad host', 'port': 80},
          {'type': 'http', 'server': 'example.invalid', 'port': 65536},
          {'type': 'http', 'server': 'example.invalid', 'port': '8080'},
        ],
      }),
    );
    expect(subscription.nodes.length, 1);
    expect(subscription.skipped, 3);
    expect(subscription.nodes.single.configuration['port'], 8080);
  });

  test(
    'rejects non-subscriptions and excessive node counts with safe errors',
    () {
      for (final text in [
        '<html>password=private</html>',
        'proxies: []',
        jsonEncode({'proxies': List.filled(201, {})}),
      ]) {
        expect(
          () => ProxySubscription.parse(text),
          throwsA(isA<SubscriptionException>()),
        );
      }
    },
  );

  test('accepts subscription query tokens but rejects non-web URL schemes', () {
    expect(
      ProxySubscription.parseUrl(' https://example.invalid/sub?token=fixture ')
          .host,
      'example.invalid',
    );
    for (final url in [
      'file:///private',
      'ss://node',
      'https://u:p@example.invalid/sub',
      'http://',
    ]) {
      expect(
        () => ProxySubscription.parseUrl(url),
        throwsA(isA<SubscriptionException>()),
      );
    }
  });
}
