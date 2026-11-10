import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志工具类
/// 使用方式：l.d('debug'); l.e('error'); l.i('info'); l.w('warning')
class L {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  /// 是否启用调试模式
  static bool _isDebug = kDebugMode;

  /// 设置调试模式
  static void setDebug(bool isDebug) {
    _isDebug = isDebug;
  }

  /// Debug日志
  void d(dynamic message) {
    if (_isDebug) _logger.d(message);
  }

  /// Info日志
  void i(dynamic message) {
    if (_isDebug) _logger.i(message);
  }

  /// Warning日志
  void w(dynamic message) {
    if (_isDebug) _logger.w(message);
  }

  /// Error日志
  void e(dynamic message) {
    if (_isDebug) _logger.e(message);
  }
}

/// 全局日志对象
final l = L();
