import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/proxy_service.dart';
import 'package:linux_do/pages/common/webview_controller.dart';

class _Proxy extends Fake implements ProxyService {
  int recoveries = 0;
  Completer<bool>? pending;
  @override
  bool get isEnabled => true;
  @override
  bool get isSubscription => true;
  @override
  int get nodeCount => 2;
  @override
  String get selectedNodeId => 'node_1';
  @override
  String? get errorMessage => null;
  @override
  Future<void> applyToWebView() async {}
  @override
  Future<bool> recover({bool avoidCurrent = true, String? failedNodeId}) {
    recoveries++;
    return pending?.future ?? Future.value(true);
  }
}

class _WebView extends Fake implements InAppWebViewController {
  final loaded = <String>[];
  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    WebUri? allowingReadAccessTo,
    Uri? iosAllowingReadAccessTo,
  }) async {
    loaded.add(urlRequest.url.toString());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final failedUrl = WebUri('https://tool.example.invalid/');
  WebResourceRequest request({String method = 'GET', WebUri? url}) =>
      WebResourceRequest(
        url: url ?? failedUrl,
        method: method,
        isForMainFrame: true,
      );
  final error = WebResourceError(
    type: WebResourceErrorType.HOST_LOOKUP,
    description: 'fixture network failure',
  );

  test('工具页读取失败可沿用代理换线后重新加载', () async {
    final proxy = _Proxy();
    final view = _WebView();
    final controller = WebViewController(proxy: proxy);
    controller.onLoadStart(view, failedUrl);
    await controller.onReceivedError(view, request(), error);
    expect(proxy.recoveries, 1);
    expect(view.loaded, [failedUrl.toString()]);
  });

  test('工具表单失败不自动重放，非网络地址不触发换线', () async {
    final proxy = _Proxy();
    final view = _WebView();
    final controller = WebViewController(proxy: proxy);
    controller.onLoadStart(view, failedUrl);
    await controller.onReceivedError(view, request(method: 'POST'), error);
    final localUrl = WebUri('file:///fixture.html');
    controller.onLoadStart(view, localUrl);
    await controller.onReceivedError(view, request(url: localUrl), error);
    expect(proxy.recoveries, 0);
    expect(view.loaded, isEmpty);
  });

  test('换线期间新导航不会被旧网页错误覆盖', () async {
    final proxy = _Proxy()..pending = Completer<bool>();
    final view = _WebView();
    final controller = WebViewController(proxy: proxy);
    controller.onLoadStart(view, failedUrl);
    final recovery = controller.onReceivedError(view, request(), error);
    controller.onLoadStart(view, WebUri('https://other.example.invalid/'));
    proxy.pending!.complete(true);
    await recovery;
    expect(proxy.recoveries, 1);
    expect(view.loaded, isEmpty);
    expect(controller.hasError.value, false);
  });

  test('工具页网关错误也通过同一线路恢复', () async {
    final proxy = _Proxy();
    final view = _WebView();
    final controller = WebViewController(proxy: proxy);
    controller.onLoadStart(view, failedUrl);
    await controller.onReceivedHttpError(
      view,
      request(),
      WebResourceResponse(statusCode: 502),
    );
    expect(proxy.recoveries, 1);
    expect(view.loaded, [failedUrl.toString()]);
  });
}
