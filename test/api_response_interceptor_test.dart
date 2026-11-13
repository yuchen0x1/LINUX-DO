import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' show Cookie;
import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/api_response_interceptor.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/cloudflare_clearance_service.dart';
import 'package:linux_do/net/retry_interceptor.dart';

class _ScriptAdapter implements HttpClientAdapter {
  _ScriptAdapter(this.script);
  final List<ResponseBody Function()> script;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = calls++;
    return script[index < script.length ? index : script.length - 1]();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(
  String value, {
  int status = 200,
  String type = 'text/html',
}) => ResponseBody.fromString(
  value,
  status,
  headers: {
    Headers.contentTypeHeader: [type],
  },
);

Dio _client(
  _ScriptAdapter adapter, {
  bool acceptClientErrors = true,
  Future<bool> Function(String?)? requestClearance,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://linux.do/',
      validateStatus: (status) =>
          status != null &&
          status >= 200 &&
          status < (acceptClientErrors ? 500 : 300),
    ),
  )..httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: 2,
      initialDelay: Duration.zero,
      maxDelay: Duration.zero,
      requestClearance: requestClearance ?? (_) async => false,
    ),
  );
  dio.interceptors.add(ApiResponseInterceptor());
  return dio;
}

void main() {
  group('接口响应边界与重试', () {
    test('Retrofit 可解析 text/plain 标记的 JSON 对象', () async {
      final adapter = _ScriptAdapter([
        () => _body('{"topic_list":{"topics":[]}}', type: 'text/plain'),
      ]);
      final response = await ApiService(_client(adapter)).getTopics('latest');
      expect(response.topicList!.topics, isEmpty);
      expect(adapter.calls, 1);
    });

    test('JSON 数组保持数组契约', () async {
      final adapter = _ScriptAdapter([
        () => _body('[{"id":1}]', type: 'text/plain'),
      ]);
      final response = await _client(adapter)
          .get<List<dynamic>>('/groups.json');
      expect(response.data, [
        {'id': 1},
      ]);
      expect(adapter.calls, 1);
    });

    test('200 空读取响应给出明确错误，空写响应与 204 保持兼容', () async {
      final emptyGet = _ScriptAdapter([
        () => _body('', type: 'application/json'),
      ]);
      await expectLater(
        ApiService(_client(emptyGet)).getTopics('latest'),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('空内容'),
          ),
        ),
      );
      expect(emptyGet.calls, 1);

      final emptyPost = _ScriptAdapter([
        () => _body('', type: 'application/json'),
      ]);
      expect(
        (await _client(emptyPost).post<void>('/topics/timings')).statusCode,
        200,
      );
      final noContent = _ScriptAdapter([
        () => _body('', status: 204, type: 'application/json'),
      ]);
      expect(
        (await _client(noContent).get<dynamic>('/no-content')).data,
        isNull,
      );
    });

    test('HTML 重试耗尽给出中文网络错误，不再强转 Map', () async {
      final adapter = _ScriptAdapter([() => _body('<html>Proxy error</html>')]);
      await expectLater(
        ApiService(_client(adapter)).getTopics('latest'),
        throwsA(
          isA<DioException>()
              .having(
                (error) => error.type,
                'type',
                DioExceptionType.badResponse,
              )
              .having((error) => error.message, 'message', contains('代理线路')),
        ),
      );
      expect(adapter.calls, 3);
    });

    test('POST 收到 HTML 仅报错，不重复发帖', () async {
      final adapter = _ScriptAdapter([() => _body('<html>Proxy error</html>')]);
      await expectLater(
        _client(adapter)
            .post<Map<String, dynamic>>('/posts.json', data: {'raw': 'hi'}),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('非 JSON'),
          ),
        ),
      );
      expect(adapter.calls, 1);
    });

    test('错误链上的 403 挑战也会验证，并只验证一次', () async {
      final adapter = _ScriptAdapter([
        () => _body('<html>Just a moment</html>', status: 403),
        () => _body('{"topic_list":{"topics":[]}}', type: 'application/json'),
      ]);
      var verifications = 0;
      String? rejected;
      final dio = _client(
        adapter,
        acceptClientErrors: false,
        requestClearance: (value) async {
          verifications++;
          rejected = value;
          return true;
        },
      );
      dio.options.headers['Cookie'] = 'a=1; cf_clearance=rejected-fixture; b=2';
      final response = await ApiService(dio).getTopics('latest');
      expect(response.topicList!.topics, isEmpty);
      expect(verifications, 1);
      expect(rejected, 'rejected-fixture');
      expect(adapter.calls, 2);
    });

    test('持续挑战有固定重试上限，不把网页返回模型解析', () async {
      final adapter = _ScriptAdapter([
        () => _body('<html>Just a moment</html>', status: 403),
      ]);
      var verifications = 0;
      final dio = _client(
        adapter,
        requestClearance: (_) async {
          verifications++;
          return false;
        },
      );
      await expectLater(
        ApiService(dio).getTopics('latest'),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('网页验证'),
          ),
        ),
      );
      expect(verifications, 1);
      expect(adapter.calls, 3);
    });

    test('连接恢复后仍返回 HTML，也经过最终响应校验', () async {
      final adapter = _ScriptAdapter([
        () => _body('<html>Bad gateway</html>', status: 502),
        () => _body('<html>Proxy error</html>'),
      ]);
      await expectLater(
        ApiService(_client(adapter)).getTopics('latest'),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('代理线路'),
          ),
        ),
      );
      expect(adapter.calls, 3);
    });

    test('普通 404 JSON 不重试、不改变原有响应', () async {
      final adapter = _ScriptAdapter([
        () =>
            _body('{"error":"missing"}', status: 404, type: 'application/json'),
      ]);
      final response = await _client(adapter)
          .get<Map<String, dynamic>>('/missing.json');
      expect(response.statusCode, 404);
      expect(response.data, {'error': 'missing'});
      expect(adapter.calls, 1);
    });

    test('显式文本响应可以正常读取 HTML，且不被当成 JSON 重试', () async {
      final adapter = _ScriptAdapter([() => _body('<html>Document</html>')]);
      final response = await _client(adapter).get<String>('/document');
      expect(response.data, '<html>Document</html>');
      expect(adapter.calls, 1);
    });

    test('字节响应保持原始数据，不受 JSON 校验影响', () async {
      final adapter = _ScriptAdapter([() => _body('image-fixture')]);
      final response = await _client(adapter).get<List<int>>(
        '/image',
        options: Options(responseType: ResponseType.bytes),
      );
      expect(String.fromCharCodes(response.data!), 'image-fixture');
      expect(adapter.calls, 1);
    });

    test('流响应保持原始数据，不受 JSON 校验影响', () async {
      final adapter = _ScriptAdapter([() => _body('stream-fixture')]);
      final response = await _client(adapter).get<ResponseBody>(
        '/stream',
        options: Options(responseType: ResponseType.stream),
      );
      final bytes = await response.data!.stream
          .expand((chunk) => chunk)
          .toList();
      expect(String.fromCharCodes(bytes), 'stream-fixture');
      expect(adapter.calls, 1);
    });
  });

  group('网页验证凭据筛选', () {
    test('拒绝旧、过期、空凭据，允许新凭据与未知过期时间', () {
      expect(
        CloudflareClearanceService.isUsableClearance(
          Cookie(name: 'cf_clearance', value: 'old'),
          rejectedValue: 'old',
        ),
        false,
      );
      expect(
        CloudflareClearanceService.isUsableClearance(
          Cookie(name: 'cf_clearance', value: 'expired', expiresDate: 1000),
          nowMilliseconds: 1000,
        ),
        false,
      );
      expect(
        CloudflareClearanceService.isUsableClearance(
          Cookie(name: 'cf_clearance', value: ''),
        ),
        false,
      );
      expect(
        CloudflareClearanceService.isUsableClearance(
          Cookie(name: 'cf_clearance', value: 'new', expiresDate: 2000),
          rejectedValue: 'old',
          nowMilliseconds: 1000,
        ),
        true,
      );
      expect(
        CloudflareClearanceService.isUsableClearance(
          Cookie(name: 'cf_clearance', value: 'new'),
          rejectedValue: 'old',
        ),
        true,
      );
    });

    test('通过 cf-mitigated 标头或 503 挑战正文识别验证', () {
      final options = RequestOptions(path: '/latest.json');
      expect(
        CloudflareClearanceService.isChallenge(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 403,
            data: '<html>challenge</html>',
            headers: Headers.fromMap({
              'cf-mitigated': ['challenge'],
            }),
          ),
        ),
        true,
      );
      expect(
        CloudflareClearanceService.isChallenge(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 503,
            data: '<html>Just a moment</html>',
          ),
        ),
        true,
      );
      expect(
        CloudflareClearanceService.isChallenge(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 403,
            data: {'error': 'forbidden'},
          ),
        ),
        false,
      );
    });
  });
}
