import 'dart:typed_data';

import 'package:cronet_http/cronet_http.dart' as cronet;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// 基于 Chromium Cronet 网络栈的 Dio 适配器
///
/// Dart 原生 HttpClient 的 TLS 指纹（JA3）会被 Cloudflare 识别并强制挑战，
/// 即使携带有效 cf_clearance 也会被 403。Cronet 即 Chromium 的网络栈，
/// 指纹与 Chrome 一致，可以从根上解决纯 API 请求过不了盾的问题。
class CronetHttpClientAdapter implements HttpClientAdapter {
  http.Client? _client;
  bool _closed = false;

  CronetHttpClientAdapter() {
    _client = cronet.CronetClient.defaultCronetEngine();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) {
      throw StateError('CronetHttpClientAdapter already closed');
    }

    final request = http.Request(options.method, options.uri);

    options.headers.forEach((k, v) {
      if (v != null) request.headers[k] = v.toString();
    });

    if (requestStream != null) {
      request.bodyBytes = await readByteStream(requestStream);
    }

    final streamed = await _client!.send(request);

    final headers = <String, List<String>>{};
    streamed.headers.forEach((k, v) {
      headers[k] = [v];
    });

    return ResponseBody(
      streamed.stream.cast<Uint8List>(),
      streamed.statusCode,
      headers: headers,
      isRedirect: streamed.isRedirect,
    );
  }

  @override
  void close({bool force = false}) {
    _closed = true;
    _client?.close();
    _client = null;
  }
}

/// 把任意 body 流读成字节（Cronet 桥接用）
Future<Uint8List> readByteStream(Stream<Uint8List> stream) async {
  final builder = BytesBuilder();
  await for (final chunk in stream) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
