import 'dart:async';

import 'package:dio/dio.dart';

/// Try each remaining node until a safe read succeeds or every node fails.
class ProxyFailoverInterceptor extends Interceptor {
  ProxyFailoverInterceptor({
    required this.dio,
    required this.enabled,
    required this.recover,
    this.currentNode,
    this.recoverFrom,
    int Function()? maxAttempts,
  }) : maxAttempts = maxAttempts ?? _oneAttempt;
  final Dio dio;
  final bool Function() enabled;
  final Future<bool> Function() recover;
  final String? Function()? currentNode;
  final Future<bool> Function(String? failedNodeId)? recoverFrom;
  final int Function() maxAttempts;
  static int _oneAttempt() => 1;
  static const retriedKey = 'subscription_proxy_retried';
  static const noWriteReplayKey = 'subscription_proxy_no_write_replay';
  static const nodeKey = 'subscription_proxy_node';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled() && currentNode != null)
      options.extra[nodeKey] = currentNode!() ?? '';
    handler.next(options);
  }

  Future<bool> _recover(DioException error) => recoverFrom == null
      ? recover()
      : recoverFrom!(error.requestOptions.extra[nodeKey] as String?);

  static bool isRouteFailure(DioException error) =>
      {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      }.contains(error.type) ||
      {502, 504}.contains(error.response?.statusCode);

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    if (!enabled() ||
        !isRouteFailure(error) ||
        request.extra[retriedKey] == true ||
        request.cancelToken?.isCancelled == true) {
      handler.next(error);
      return;
    }
    if (!{'GET', 'HEAD', 'OPTIONS'}.contains(request.method.toUpperCase())) {
      // A reset after writing through a proxy does not prove the origin never
      // received the post. Also keep the general retry interceptor from replaying it.
      request.extra[noWriteReplayKey] = true;
      unawaited(_recover(error).catchError((_) => false));
      handler.next(error);
      return;
    }
    request.extra[retriedKey] = true;
    var lastError = error;
    for (var attempt = 0; attempt < maxAttempts().clamp(1, 200); attempt++) {
      if (request.cancelToken?.isCancelled == true ||
          !isRouteFailure(lastError))
        break;
      try {
        if (!await _recover(lastError) ||
            request.cancelToken?.isCancelled == true)
          break;
        final response = await dio.fetch<dynamic>(
          request.copyWith(extra: {...request.extra, retriedKey: true}),
        );
        handler.resolve(response);
        return;
      } on DioException catch (nextError) {
        lastError = nextError;
      } catch (_) {
        break;
      }
    }
    handler.next(lastError);
  }
}
