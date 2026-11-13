import 'dart:convert';

import 'package:dio/dio.dart';

import 'cloudflare_clearance_service.dart';

/// 在 Retrofit 强制转换 JSON 模型前，识别网关网页与错误的响应类型。
/// 必须放在换线和重试拦截器之后，让可恢复的请求先完成恢复。
class ApiResponseInterceptor extends Interceptor {
  static DioException? responseError(Response<dynamic> response) {
    if (response.requestOptions.responseType != ResponseType.json) return null;
    final data = response.data;
    if (data == null || (data is String && data.trim().isEmpty)) {
      final method = response.requestOptions.method.toUpperCase();
      if (response.statusCode == 204 ||
          response.statusCode == 205 ||
          method != 'GET') {
        // 无响应体的写操作（例如更新阅读时间）不需要 JSON 模型。
        response.data = null;
        return null;
      }
      return DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: '接口返回了空内容，请检查代理线路后重试',
      );
    }
    if (data is! String) return null;

    final text = data.trim();
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic> || decoded is List) {
        // 有些网关会把合法 JSON 标成 text/plain，Dio 因而没有解码。
        response.data = decoded;
        return null;
      }
    } on FormatException {
      // HTML 和普通文本必须在模型转换之前作为网络错误返回。
    }

    final challenge = CloudflareClearanceService.isChallenge(response);
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: challenge
          ? '网页验证未完成，请使用当前代理完成验证后重试'
          : '接口返回了网页或非 JSON 内容，请检查代理线路后重试',
    );
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final error = responseError(response);
    if (error != null) {
      handler.reject(error);
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (err.type == DioExceptionType.badResponse && response != null) {
      handler.next(responseError(response) ?? err);
      return;
    }
    handler.next(err);
  }
}
