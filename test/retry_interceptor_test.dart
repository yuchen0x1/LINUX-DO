import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/retry_interceptor.dart';

/// 记录每个请求最终命中服务端的次数，用来验证「写操作不会被重复提交」。
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  /// 依次返回的响应；用完后重复最后一个
  final List<ResponseBody Function(RequestOptions)> script;

  _RecordingAdapter(this.script);

  int get calls => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = requests.length - 1;
    final factory = script[index < script.length ? index : script.length - 1];
    return factory(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, {Map<String, String>? headers}) {
  return ResponseBody.fromString(
    '{"ok":true}',
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      for (final entry in (headers ?? const <String, String>{}).entries)
        entry.key: [entry.value],
    },
  );
}

ResponseBody _html(int status) {
  return ResponseBody.fromString(
    '<html>Just a moment</html>',
    status,
    headers: {
      Headers.contentTypeHeader: ['text/html'],
    },
  );
}

Dio _dioWith(_RecordingAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test/',
      validateStatus: (status) =>
          status != null && status >= 200 && status < 500,
    ),
  );
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: 2,
      initialDelay: Duration.zero,
      maxDelay: Duration.zero,
    ),
  );
  return dio;
}

void main() {
  group('RetryInterceptor 幂等性', () {
    test('GET 遇到 429 会重试，并在成功后返回 200', () async {
      final adapter = _RecordingAdapter([
        (_) => _json(429, headers: {'retry-after': '0'}),
        (_) => _json(200),
      ]);
      final response = await _dioWith(adapter).get<dynamic>('/latest.json');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('POST 遇到 429 也会重试（服务端已拒绝，未做处理）', () async {
      final adapter = _RecordingAdapter([
        (_) => _json(429, headers: {'retry-after': '0'}),
        (_) => _json(200),
      ]);
      final response = await _dioWith(
        adapter,
      ).post<dynamic>('/posts.json', data: {'raw': 'hi'});

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('POST 收到网关 HTML 错误页时不重试，避免重复发帖', () async {
      final adapter = _RecordingAdapter([(_) => _html(200)]);

      final response = await _dioWith(
        adapter,
      ).post<dynamic>('/posts.json', data: {'raw': 'hi'});

      // 放行给业务层处理，不擅自重发
      expect(response.statusCode, 200);
      expect(adapter.calls, 1);
    });

    test('写操作在连接失败时允许重试（请求未到达服务端）', () async {
      var first = true;
      final adapter = _RecordingAdapter([
        (_) {
          if (first) {
            first = false;
            throw DioException(
              requestOptions: RequestOptions(path: '/posts.json'),
              type: DioExceptionType.connectionError,
              message: 'no network',
            );
          }
          return _json(200);
        },
      ]);

      final response = await _dioWith(
        adapter,
      ).post<dynamic>('/posts.json', data: {'raw': 'hi'});

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('持续 429 达到上限后抛出 RateLimitExhaustedException', () async {
      final adapter = _RecordingAdapter([
        (_) => _json(429, headers: {'retry-after': '0'}),
      ]);

      await expectLater(
        _dioWith(adapter).get<dynamic>('/latest.json'),
        throwsA(isA<RateLimitExhaustedException>()),
      );
      // 首次请求 + maxRetries(2) 次重试
      expect(adapter.calls, 3);
    });

    test('重试次数不会因拦截器重复注册而指数级放大', () async {
      final adapter = _RecordingAdapter([
        (_) => _json(429, headers: {'retry-after': '0'}),
      ]);
      final dio = _dioWith(adapter);
      // 模拟历史 bug：同一条链上再加一个 RetryInterceptor
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: Duration.zero,
          maxDelay: Duration.zero,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/latest.json'),
        throwsA(isA<DioException>()),
      );
      // 单层重试：1 次原始 + 2 次重试 = 3
      expect(adapter.calls, 3);
    });
  });

  group('RetryInterceptor 基础行为', () {
    test('200 响应不做任何重试', () async {
      final adapter = _RecordingAdapter([(_) => _json(200)]);
      final response = await _dioWith(adapter).get<dynamic>('/latest.json');

      expect(response.statusCode, 200);
      expect(adapter.calls, 1);
    });

    test('404 不重试', () async {
      final adapter = _RecordingAdapter([(_) => _json(404)]);
      final response = await _dioWith(adapter).get<dynamic>('/missing.json');

      expect(response.statusCode, 404);
      expect(adapter.calls, 1);
    });
  });
}
