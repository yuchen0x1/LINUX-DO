import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log.dart';

/// 崩溃与未捕获异常的本地记录。
///
/// 设计取舍：
/// - **只写本地文件，不上传**。用户要求不把项目数据发往第三方，崩溃日志里可能
///   带 cookie、帖子内容、用户名，更不能默认外发。留出 [readRecent] 供将来
///   「导出诊断信息」由用户主动分享。
/// - **绝不让记录本身成为新的崩溃源**。所有 IO 都包在 try/catch 里，失败只打
///   一条本地日志就返回。
/// - **有大小上限**。超过 [maxBytes] 时只保留尾部 [keepBytes]，避免长期运行后
///   日志文件无限增长。
class CrashReporter {
  CrashReporter._();

  static const String _fileName = 'crash.log';
  static const int maxBytes = 256 * 1024;
  static const int keepBytes = 128 * 1024;

  static bool _installed = false;
  static File? _logFile;

  /// 挂载全局异常处理。必须在 runApp 之前调用。
  static void install() {
    if (_installed) return;
    _installed = true;

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // 保留 Flutter 默认行为（debug 下红屏+控制台）
      previousOnError?.call(details);
      unawaited(
        record(
          details.exception,
          details.stack,
          source: details.library ?? 'flutter',
          context: details.context?.toDescription(),
        ),
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      unawaited(record(error, stack, source: 'platform'));
      // 返回 false 让系统继续走默认处理（debug 下会打印）
      return false;
    };

    // 异步 zone 之外的漏网错误
    runZonedGuarded(() {}, (error, stack) {
      unawaited(record(error, stack, source: 'zone'));
    });
  }

  /// 记录一条异常。[source] 用于区分来源，便于排查。
  static Future<void> record(
    Object error,
    StackTrace? stack, {
    String source = 'app',
    String? context,
  }) async {
    try {
      final file = await _resolveFile();
      if (file == null) return;

      final buffer = StringBuffer()
        ..writeln('===== ${DateTime.now().toIso8601String()} [$source] =====')
        ..writeln(error.toString());
      if (context != null && context.isNotEmpty) {
        buffer.writeln('context: $context');
      }
      if (stack != null) {
        buffer.writeln(stack.toString());
      }
      buffer.writeln();

      await file.writeAsString(buffer.toString(), mode: FileMode.append);
      await _trimIfNeeded(file);
    } catch (e) {
      // 记录失败只能降级为一条普通日志，绝不 rethrow
      l.w('写入崩溃日志失败: $e');
    }
  }

  /// 读取最近的崩溃记录，供「导出诊断信息」使用。
  static Future<String?> readRecent({int maxChars = 20000}) async {
    try {
      final file = await _resolveFile();
      if (file == null || !await file.exists()) return null;
      final text = await file.readAsString();
      if (text.length <= maxChars) return text;
      return text.substring(text.length - maxChars);
    } catch (e) {
      l.w('读取崩溃日志失败: $e');
      return null;
    }
  }

  /// 清空崩溃记录。
  static Future<void> clear() async {
    try {
      final file = await _resolveFile();
      if (file != null && await file.exists()) {
        await file.writeAsString('');
      }
    } catch (e) {
      l.w('清空崩溃日志失败: $e');
    }
  }

  static Future<File?> _resolveFile() async {
    final cached = _logFile;
    if (cached != null) return cached;

    final dir = await getApplicationSupportDirectory();
    final logDir = Directory('${dir.path}${Platform.pathSeparator}logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    final file = File('${logDir.path}${Platform.pathSeparator}$_fileName');
    _logFile = file;
    return file;
  }

  /// 超过上限时截断为尾部内容。
  static Future<void> _trimIfNeeded(File file) async {
    final length = await file.length();
    if (length <= maxBytes) return;

    final content = await file.readAsString();
    final start = content.length > keepBytes ? content.length - keepBytes : 0;
    await file.writeAsString('... 早期日志已截断 ...\n${content.substring(start)}');
  }
}
