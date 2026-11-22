import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'update_checker.dart';

class UpdateDownloader {
  UpdateDownloader({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              followRedirects: false,
              validateStatus: (s) =>
                  s == 200 || [301, 302, 303, 307, 308].contains(s),
            ),
          );
  final Dio _dio;
  static const channel = MethodChannel('com.linux.linuxdo/updater');
  static const redirectHosts = {
    'github.com',
    'release-assets.githubusercontent.com',
    'objects.githubusercontent.com',
    'github-releases.githubusercontent.com',
  };
  static bool isTrustedRedirect(Uri uri) =>
      uri.scheme == 'https' &&
      uri.port == 443 &&
      uri.userInfo.isEmpty &&
      redirectHosts.contains(uri.host);

  Future<File> download(
    ReleaseUpdate update, {
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
    Directory? cacheDirectory,
  }) async {
    if (!UpdateChecker.isTrustedDownload(update.downloadUrl!) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(update.sha256) ||
        update.size <= 0 ||
        update.size > 150 * 1024 * 1024)
      throw const FormatException('更新包信息无效');
    final directory = Directory(
      '${(cacheDirectory ?? await getTemporaryDirectory()).path}/linuxdo-updates',
    );
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}/update-${DateTime.now().microsecondsSinceEpoch}.apk',
    );
    final partial = File('${file.path}.part');
    IOSink? sink;
    try {
      var uri = Uri.parse(update.downloadUrl!);
      Response<ResponseBody>? response;
      for (var redirects = 0; redirects <= 5; redirects++) {
        if (!isTrustedRedirect(uri)) throw const FormatException('下载来源不可信');
        response = await _dio.get<ResponseBody>(
          uri.toString(),
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            followRedirects: false,
          ),
        );
        if (response.statusCode == 200) break;
        final location = response.headers.value('location');
        await response.data!.stream.drain<void>();
        if (location == null || redirects == 5)
          throw const FormatException('更新下载重定向异常');
        uri = uri.resolve(location);
      }
      sink = partial.openWrite();
      var received = 0;
      await for (final chunk in response!.data!.stream) {
        if (cancelToken.isCancelled) throw cancelToken.cancelError!;
        received += chunk.length;
        if (received > update.size) throw const FormatException('下载大小不匹配');
        sink.add(chunk);
        await sink.flush();
        onProgress(received, update.size);
      }
      await sink.close();
      sink = null;
      if (cancelToken.isCancelled) throw cancelToken.cancelError!;
      if (received != update.size ||
          (await sha256.bind(partial.openRead()).first).toString() !=
              update.sha256) {
        throw const FormatException('更新包完整性校验失败，请重新下载');
      }
      return await partial.rename(file.path);
    } catch (_) {
      await sink?.close();
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  static Future<void> install(File apk) =>
      channel.invokeMethod<void>('install', {'path': apk.path});
  void close() => _dio.close(force: true);
}
