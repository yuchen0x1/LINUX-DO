import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../utils/log.dart';
import 'cloudflare_clearance_service.dart';

class RateLimitExhaustedException extends DioException {
  final int retryAfter;

  RateLimitExhaustedException({
    required RequestOptions requestOptions,
    required this.retryAfter,
  }) : super(requestOptions: requestOptions);
}

// 应该是NEO对服务的API 新增了速率限制 😭处理429
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final Random _random = Random();

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3, // 减少最大重试次数
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 5),
  });

  bool _isValidResponse(Response? response) {
    if (response == null) return false;
    
    if (response.statusCode == 429) {
      final retryAfter = int.tryParse(response.headers.value('Retry-After') ?? '60') ?? 60;
      l.e('速率限制: $retryAfter 秒');
      return false;
    }
    
    final contentType = response.headers.value('content-type') ?? '';
    if (contentType.toLowerCase().contains('text/html')) {
      return false;
    }
    
    return true;
  }

  /// 每个请求只过一次盾（防止无限循环）
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

  Duration _calculateDelay(int retryCount) {
    // 使用指数退避算法，并添加随机抖动
    final exponentialDelay = initialDelay * (1 << retryCount);
    final jitter = Duration(milliseconds: _random.nextInt(1000));
    final delay = exponentialDelay + jitter;
    return delay > maxDelay ? maxDelay : delay;
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (!_isValidResponse(response)) {
      // CF 挑战页：先无头过盾拿 cf_clearance，再走重试
      if (CloudflareClearanceService.isChallenge(response)) {
        await _ensureCfClearanceOnce(response.requestOptions);
      }
      final retryCount = response.requestOptions.extra['retryCount'] as int? ?? 0;
      
      if (retryCount < maxRetries) {
        final delay = _calculateDelay(retryCount);
        l.d('重试请求 (${retryCount + 1}/$maxRetries)，等待 ${delay.inSeconds} 秒');
        
        await Future.delayed(delay);
        final options = Options(
          method: response.requestOptions.method,
          headers: response.requestOptions.headers,
        );
        
        options.extra = {
          ...response.requestOptions.extra,
          'retryCount': retryCount + 1,
        };
        
        try {
          final newResponse = await dio.request(
            response.requestOptions.path,
            data: response.requestOptions.data,
            queryParameters: response.requestOptions.queryParameters,
            options: options,
          );
          
          if (_isValidResponse(newResponse)) {
            return handler.next(newResponse);
          } else {
            return onResponse(newResponse, handler);
          }
        } catch (e) {
          if (e is DioException) {
            return handler.reject(e);
          }
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: e,
            ),
          );
        }
      } else {
        l.e('达到最大重试次数 ($maxRetries)');
        final retryAfter = int.tryParse(
          response.headers.value('Retry-After') ?? '60'
        ) ?? 60;
        
        final rateLimitErr = RateLimitExhaustedException(
          requestOptions: response.requestOptions,
          retryAfter: retryAfter,
        );
        return handler.reject(rateLimitErr);
      }
    }
    
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429 || !_isValidResponse(err.response)) {
      // CF 挑战页：先无头过盾拿 cf_clearance，再走重试
      if (CloudflareClearanceService.isChallenge(err.response)) {
        await _ensureCfClearanceOnce(err.requestOptions);
      }
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
      
      if (retryCount < maxRetries) {
        final delay = _calculateDelay(retryCount);
        l.d('重试请求 (${retryCount + 1}/$maxRetries)，等待 ${delay.inSeconds} 秒');
        
        await Future.delayed(delay + const Duration(seconds: 2));
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );
        
        options.extra = {
          ...err.requestOptions.extra,
          'retryCount': retryCount + 1,
        };
        
        try {
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: options,
          );
          
          if (_isValidResponse(response)) {
            return handler.resolve(response);
          } else {
            return onError(
              DioException(
                requestOptions: err.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
              handler,
            );
          }
        } catch (e) {
          if (e is DioException) {
            return onError(e, handler);
          }
          return handler.next(err);
        }
      } else {
        final retryAfter = int.tryParse(
          err.response?.headers.value('Retry-After') ?? '60'
        ) ?? 60;
        
        final rateLimitErr = RateLimitExhaustedException(
          requestOptions: err.requestOptions,
          retryAfter: retryAfter,
        );
        return handler.next(rateLimitErr);
      }
    }
    return handler.next(err);
  }
} 