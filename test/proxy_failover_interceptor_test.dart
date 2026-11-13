import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/proxy_failover_interceptor.dart';
import 'package:linux_do/net/retry_interceptor.dart';

class FailureAdapter implements HttpClientAdapter {
  int calls = 0;
  bool alwaysFail = false;
  int failures = 1;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls <= failures || alwaysFail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString('ok', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('two failed nodes advance to the third without stopping or replaying old nodes', () async {
    final dio = Dio();
    final adapter = FailureAdapter()..failures = 2;
    var recoveries = 0;
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      ProxyFailoverInterceptor(
        dio: dio,
        enabled: () => true,
        maxAttempts: () => 3,
        recover: () async {
          recoveries++;
          return true;
        },
      ),
    );
    dio.interceptors.add(
      RetryInterceptor(dio: dio, initialDelay: Duration.zero),
    );
    expect((await dio.get<String>('https://example.invalid')).data, 'ok');
    expect(adapter.calls, 3);
    expect(recoveries, 2);
    dio.close();
  });

  test(
    'all-node exhaustion stops the request instead of entering general retry',
    () async {
      final dio = Dio();
      final adapter = FailureAdapter()..alwaysFail = true;
      var recoveries = 0;
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        ProxyFailoverInterceptor(
          dio: dio,
          enabled: () => true,
          maxAttempts: () => 3,
          recover: () async => ++recoveries < 3,
        ),
      );
      dio.interceptors.add(
        RetryInterceptor(dio: dio, initialDelay: Duration.zero),
      );
      await expectLater(
        dio.get<String>('https://example.invalid'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 3);
      expect(recoveries, 3);
      dio.close();
    },
  );
  test('GET switches and replays once', () async {
    final dio = Dio();
    final adapter = FailureAdapter();
    var recoveries = 0;
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      ProxyFailoverInterceptor(
        dio: dio,
        enabled: () => true,
        recover: () async {
          recoveries++;
          return true;
        },
      ),
    );
    expect((await dio.get<String>('https://example.invalid')).data, 'ok');
    expect(adapter.calls, 2);
    expect(recoveries, 1);
    dio.close();
  });

  test(
    'a second failure is returned without an infinite recovery loop',
    () async {
      final dio = Dio();
      final adapter = FailureAdapter()..alwaysFail = true;
      var recoveries = 0;
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        ProxyFailoverInterceptor(
          dio: dio,
          enabled: () => true,
          recover: () async {
            recoveries++;
            return true;
          },
        ),
      );
      await expectLater(
        dio.get<String>('https://example.invalid'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
      expect(recoveries, 1);
      dio.close();
    },
  );

  test(
    'POST is not replayed by either failover or the existing retry interceptor',
    () async {
      final dio = Dio();
      final adapter = FailureAdapter();
      var recoveries = 0;
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        ProxyFailoverInterceptor(
          dio: dio,
          enabled: () => true,
          recover: () async {
            recoveries++;
            return true;
          },
        ),
      );
      dio.interceptors.add(
        RetryInterceptor(dio: dio, initialDelay: Duration.zero),
      );
      await expectLater(
        dio.post<String>('https://example.invalid', data: 'draft'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
      expect(recoveries, 1);
      dio.close();
    },
  );
}
