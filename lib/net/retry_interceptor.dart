import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../utils/log.dart';
import 'cloudflare_clearance_service.dart';
import 'proxy_failover_interceptor.dart';

/// 限流重试耗尽（429）
class RateLimitExhaustedException extends DioException {
  final int retryAfter;

  RateLimitExhaustedException({
    required RequestOptions requestOptions,
    required this.retryAfter,
  }) : super(requestOptions: requestOptions);
}

/// 一次拦截的最终结果：要么拿到响应，要么带着最后一次错误退出
class _RetryOutcome {
  final Response<dynamic>? response;
  final DioException? error;

  const _RetryOutcome._({this.response, this.error});

  factory _RetryOutcome.response(Response<dynamic> response) =>
      _RetryOutcome._(response: response);

  factory _RetryOutcome.error(DioException error) =>
      _RetryOutcome._(error: error);
}

/// 重试拦截器
///
/// 两条硬规则：
/// 1. **幂等性**：只有 GET/HEAD/OPTIONS 可以无条件重试。POST/PUT/PATCH/DELETE
///    仅在「请求确定没有到达服务端」时重试（连接失败/连接超时），否则可能造成
///    重复发帖、重复回复。
/// 2. **单层重试**：dio 的重试会重新走整条拦截器链。这里用一次性的 token 标记
///    内层请求，让「别的拦截器实例」放行，同时允许本实例继续收敛自己的重试结果
///    （否则「第一次重试依然 429」会被误判为成功）。
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final Random _random = Random();

  static const String _nestedKey = 'retryNested';
  static const String _tokenKey = 'retryToken';

  /// 幂等方法：重试不会改变服务端状态
  static const Set<String> _idempotentMethods = {'GET', 'HEAD', 'OPTIONS'};

  /// NEO 对服务端的 API 加了速率限制 😭 处理 429
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 5),
  });

  bool _isIdempotent(String method) =>
      _idempotentMethods.contains(method.toUpperCase());

  /// 连接未建立 —— 请求一定没有到达服务端，任何方法重试都安全
  bool _neverReachedServer(DioException err) {
    if (err.requestOptions.extra[ProxyFailoverInterceptor.noWriteReplayKey] ==
        true)
      return false;
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return true;
      default:
        return false;
    }
  }

  /// 该响应是否值得重试（已含方法幂等性判断）
  bool _needsRetry(Response<dynamic>? response, RequestOptions options) {
    if (response == null) {
      // 无响应：只有幂等方法可以盲重试
      return _isIdempotent(options.method);
    }

    // 限流：服务端已拒绝该请求，未做业务处理，重试安全
    if (response.statusCode == 429) return true;

    // Cloudflare 挑战页：请求被网关拦截，未达业务逻辑，重试安全
    if (CloudflareClearanceService.isChallenge(response)) return true;

    // 网关临时不可用：只对幂等方法重试
    final code = response.statusCode ?? 0;
    if (code == 502 || code == 503 || code == 504) {
      return _isIdempotent(options.method);
    }

    // 非预期 HTML（挑战页变体）：仅幂等方法重试。写操作直接放行，
    // 避免把「已成功的写入 + 网关返回错页」误判成失败并重复提交。
    final contentType = response.headers.value('content-type') ?? '';
    if (contentType.toLowerCase().contains('text/html')) {
      return _isIdempotent(options.method);
    }

    return false;
  }

  /// 一次错误是否值得重试。
  /// - 有响应：按响应规则判断（429 / 挑战页 / 网关错误）
  /// - 无响应：连接未建立则任何方法都安全；其余（如 receiveTimeout）
  ///   只有幂等方法可以重试
  bool _shouldRetryError(DioException err) {
    final response = err.response;
    if (response != null) {
      return _needsRetry(response, err.requestOptions);
    }
    return _neverReachedServer(err) || _isIdempotent(err.requestOptions.method);
  }

  /// 对每个请求至多启动一次过盾流程
  Future<void> _ensureCfClearanceOnce(RequestOptions options) async {
    if (options.extra['cfTried'] == true) return;
    options.extra['cfTried'] = true;
    l.d('检测到 Cloudflare 挑战，启动无头过盾...');
    try {
      await CloudflareClearanceService.ensureClearance();
    } catch (e) {
      l.e('CF 过盾流程异常: $e');
    }
  }

  Duration _calculateDelay(int attempt) {
    final exponentialDelay = initialDelay * (1 << attempt);
    final jitter = Duration(milliseconds: _random.nextInt(1000));
    final delay = exponentialDelay + jitter;
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Retry-After 可能是秒数，也可能是 HTTP date；解析失败时退回指数退避
  Duration _resolveDelay(Response<dynamic>? response, int attempt) {
    final retryAfter = response?.headers.value('Retry-After');
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter.trim());
      if (seconds != null && seconds > 0) {
        return seconds > 30
            ? const Duration(seconds: 30)
            : Duration(seconds: seconds);
      }
    }
    return _calculateDelay(attempt);
  }

  /// 发起一次重试。内层请求带 token + nested 标记，让拦截器链上的实例放行，
  /// 由发起重试的 [_drain] 继续判断结果。
  Future<Response<dynamic>> _retry(RequestOptions options, Object token) {
    return dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      cancelToken: options.cancelToken,
      options: Options(
        method: options.method,
        headers: Map<String, dynamic>.from(options.headers),
        contentType: options.contentType,
        responseType: options.responseType,
        followRedirects: options.followRedirects,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        validateStatus: options.validateStatus,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: <String, dynamic>{
          ...options.extra,
          _nestedKey: true,
          _tokenKey: token,
        },
      ),
    );
  }

  /// 反复重试直到「响应不再需要重试」或「达到上限」。
  /// 同一时刻只有一个重试在路上，不会嵌套。
  Future<_RetryOutcome> _drain({
    required Object token,
    Response<dynamic>? response,
    DioException? error,
  }) async {
    var currentResponse = response;
    var currentError = error;
    var attempt = 0;

    while (true) {
      final options =
          currentResponse?.requestOptions ?? currentError!.requestOptions;

      final shouldRetry = currentResponse != null
          ? _needsRetry(currentResponse, options)
          : _shouldRetryError(currentError!);

      if (!shouldRetry) {
        return currentResponse != null
            ? _RetryOutcome.response(currentResponse)
            : _RetryOutcome.error(currentError!);
      }

      if (CloudflareClearanceService.isChallenge(currentResponse)) {
        await _ensureCfClearanceOnce(options);
      }

      if (attempt >= maxRetries) {
        l.e('达到最大重试次数 ($maxRetries)');
        if (currentResponse?.statusCode == 429) {
          final retryAfter =
              int.tryParse(
                currentResponse?.headers.value('Retry-After') ?? '60',
              ) ??
              60;
          return _RetryOutcome.error(
            RateLimitExhaustedException(
              requestOptions: options,
              retryAfter: retryAfter,
            ),
          );
        }
        return currentResponse != null
            ? _RetryOutcome.response(currentResponse)
            : _RetryOutcome.error(currentError!);
      }

      final delay = _resolveDelay(currentResponse, attempt);
      l.d('重试请求 (${attempt + 1}/$maxRetries)，等待 ${delay.inMilliseconds}ms');
      await Future<void>.delayed(delay);

      attempt++;
      try {
        currentResponse = await _retry(options, token);
        currentError = null;
      } on DioException catch (e) {
        currentError = e;
        currentResponse = null;
      }
    }
  }

  /// 入口守卫：内层请求若属于别的拦截器实例，则直接放行
  bool _isForeignRetry(RequestOptions options, Object token) =>
      options.extra[_nestedKey] == true &&
      !identical(options.extra[_tokenKey], token);

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final token = Object();
    if (_isForeignRetry(response.requestOptions, token)) {
      return handler.next(response);
    }

    final outcome = await _drain(token: token, response: response);
    if (outcome.error != null) {
      return handler.reject(outcome.error!);
    }
    return handler.next(outcome.response!);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra[ProxyFailoverInterceptor.retriedKey] == true &&
        ProxyFailoverInterceptor.isRouteFailure(err)) {
      return handler.next(err);
    }
    final token = Object();
    if (_isForeignRetry(err.requestOptions, token)) {
      return handler.next(err);
    }

    final outcome = await _drain(token: token, error: err);
    if (outcome.error != null) {
      return handler.next(outcome.error!);
    }
    return handler.resolve(outcome.response!);
  }
}
