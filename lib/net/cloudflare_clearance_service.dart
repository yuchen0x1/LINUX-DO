import 'dart:async';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response;

import '../const/app_const.dart';
import '../utils/log.dart';
import '../utils/storage_manager.dart';
import 'http_client.dart';
import 'http_config.dart';
import 'proxy_service.dart';

/// Cloudflare 过盾服务
///
/// 国内网络下，纯 API 请求即使走对了代理，仍会被 CF 5 秒盾拦截（403 + Just a moment）。
/// 检测到挑战页时，自动弹出一个小型可见 WebView 完成 Turnstile 人机验证，
/// 拿到 cf_clearance 后同步进 Dio 的持久 CookieJar 并自动关闭，实现静默过盾。
class CloudflareClearanceService {
  static Completer<bool>? _completer;
  static bool _dialogOpen = false;
  static void Function()? _cleanup;

  /// 判断响应是否为 CF 挑战页
  static bool isChallenge(Response? response) {
    if (response == null) return false;
    if (response.headers.value('cf-mitigated')?.toLowerCase() == 'challenge') {
      return true;
    }
    if (response.statusCode != 403 && response.statusCode != 503) return false;
    final body = response.data;
    if (body is! String) return false;
    final text = body.toLowerCase();
    return text.contains('just a moment') ||
        text.contains('challenge-platform') ||
        text.contains('cf-mitigated');
  }

  /// 确保拿到 cf_clearance（并发调用共享同一个流程）
  static Future<bool> ensureClearance({String? rejectedClearance}) {
    if (_completer != null) return _completer!.future;
    final completer = Completer<bool>();
    _completer = completer;
    _run(completer, rejectedClearance: rejectedClearance);
    return completer.future;
  }

  static void finish(Completer<bool> completer, bool ok) {
    // 旧定时器或异步回调不能结束下一轮验证、关闭其他轮次的弹窗。
    if (!identical(_completer, completer)) return;
    _cleanup?.call();
    _cleanup = null;
    _completer = null;
    if (_dialogOpen) {
      _dialogOpen = false;
      try {
        if (Get.isDialogOpen == true) Get.back();
      } catch (_) {}
    }
    if (!completer.isCompleted) completer.complete(ok);
    l.i('CF 过盾${ok ? '成功' : '失败'}');
  }

  /// 忽略被接口拒绝的旧凭据，避免轮询一开始便误报验证成功。
  static bool isUsableClearance(
    Cookie cookie, {
    String? rejectedValue,
    int? nowMilliseconds,
  }) =>
      cookie.name == 'cf_clearance' &&
      cookie.value.isNotEmpty &&
      cookie.value != rejectedValue &&
      (cookie.expiresDate == null ||
          cookie.expiresDate! >
              (nowMilliseconds ?? DateTime.now().millisecondsSinceEpoch));

  static Future<void> _run(
    Completer<bool> completer, {
    String? rejectedClearance,
  }) async {
    Timer? poll;
    Timer? deadline;
    var polling = false;
    _cleanup = () {
      poll?.cancel();
      deadline?.cancel();
    };

    try {
      // 验证窗口和登录、帖子请求使用同一条应用内线路。
      await ProxyService().applyToWebView();
      final uri = Uri.parse(HttpConfig.baseUrl);
      final jar = NetClient.getInstance().cookieJar;
      if (rejectedClearance == null) {
        final previous = await jar.loadForRequest(uri);
        for (final cookie in previous) {
          if (cookie.name == 'cf_clearance') rejectedClearance = cookie.value;
        }
      }
      if (!identical(_completer, completer)) return;
      poll = Timer.periodic(const Duration(seconds: 2), (t) async {
        if (polling || !identical(_completer, completer)) return;
        polling = true;
        try {
          final cookies = await CookieManager.instance().getCookies(
            url: WebUri(HttpConfig.baseUrl),
          );
          if (!identical(_completer, completer)) return;
          final cf = cookies
              .where(
                (cookie) =>
                    isUsableClearance(cookie, rejectedValue: rejectedClearance),
              )
              .toList();
          if (cf.isNotEmpty) {
            // 更新 NetClient 正在读取的同一个内存/持久 CookieJar。
            // 另建一个 jar 只会写磁盘，已加载的旧值仍可能被继续发出。
            await jar.saveFromResponse(
              uri,
              cf
                  .map(
                    (e) => io.Cookie(e.name, e.value)
                      ..domain = HttpConfig.domain
                      ..path = '/'
                      ..secure = true
                      ..httpOnly = true
                      ..expires = e.expiresDate == null
                          ? null
                          : DateTime.fromMillisecondsSinceEpoch(e.expiresDate!),
                  )
                  .toList(),
            );
            if (!identical(_completer, completer)) return;
            await StorageManager.setData(
              AppConst.identifier.cfClearance,
              cf.first.value,
            );
            finish(completer, true);
          }
        } catch (e) {
          l.e('CF clearance 轮询异常: $e');
        } finally {
          polling = false;
        }
      });

      // 可见的小窗 WebView（Turnstile 需要可见渲染才能通过）
      _dialogOpen = true;
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            width: 320.w,
            height: 430.w,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '正在通过 Cloudflare 验证，请稍候…',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(HttpConfig.baseUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      cacheEnabled: true,
                      userAgent: NetClient.userAgent,
                      thirdPartyCookiesEnabled: true,
                      safeBrowsingEnabled: false,
                      transparentBackground: false,
                      blockNetworkImage: true,
                    ),
                    onLoadStop: (controller, url) async {
                      await controller.evaluateJavascript(
                        source: '''
                        function autoClickTurnstile() {
                          const buttons = document.querySelectorAll('button, input[type=submit], input[type=checkbox]');
                          for (const el of buttons) {
                            const t = (el.textContent || el.value || '').toString();
                            if (t.indexOf('Verify') >= 0 || t.indexOf('验证') >= 0 || el.type === 'checkbox') {
                              try { el.click(); } catch (e) {}
                            }
                          }
                        }
                        setInterval(autoClickTurnstile, 1500);
                      ''',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 最长等待 60 秒
      deadline = Timer(const Duration(seconds: 60), () {
        finish(completer, false);
      });
    } catch (e) {
      l.e('CF 过盾异常: $e');
      poll?.cancel();
      finish(completer, false);
    }
  }
}
