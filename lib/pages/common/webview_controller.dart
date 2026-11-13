import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../controller/base_controller.dart';
import '../../net/proxy_service.dart';

class WebViewController extends BaseController {
  WebViewController({ProxyService? proxy}) : _proxy = proxy ?? ProxyService();

  final loadingProgress = 0.0.obs;
  final title = ''.obs;
  final content = ''.obs;
  final isHtml = false.obs;
  final proxyReady = false.obs;
  final ProxyService _proxy;
  bool _closed = false;
  bool _recovering = false;
  int _recoveries = 0;
  String? _loadNode;
  String? _loadUrl;
  int _loadGeneration = 0;
  Rx<InAppWebViewController?> webViewController = Rx<InAppWebViewController?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    // 获取传递的参数，可以是URL或HTML内容
    content.value = Get.arguments as String;
    // 简单判断是否为HTML内容
    isHtml.value = content.value.trim().startsWith('<');
    prepareProxy();
  }

  Future<void> prepareProxy() async {
    clearError();
    try {
      // 工具页和帖子内链接同样要等待登录页使用的代理生效。
      await _proxy.applyToWebView();
      if (!_closed) proxyReady.value = true;
    } catch (_) {
      if (!_closed) {
        loadingProgress.value = 1;
        setError('无法应用代理，请检查网络线路后重试');
      }
    }
  }

  Future<void> retry() async {
    _recoveries = 0;
    if (!proxyReady.value) {
      await prepareProxy();
    } else {
      clearError();
      await webViewController.value?.reload();
    }
  }

  @override
  void onClose() {
    _closed = true;
    super.onClose();
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController.value = controller;
    // 注入JavaScript代码以启用文本选择
    controller.evaluateJavascript(
      source: '''
      document.documentElement.style.webkitUserSelect = 'text';
      document.documentElement.style.userSelect = 'text';
      document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
        return false;
      });
    ''',
    );
  }

  void onLoadStart(InAppWebViewController controller, WebUri? url) {
    clearError();
    _loadGeneration++;
    _loadUrl = url?.toString();
    _loadNode = _proxy.selectedNodeId;
    loadingProgress.value = 0;
  }

  Future<void> onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) async {
    await _handleLoadFailure(controller, request);
  }

  Future<void> onReceivedHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse response,
  ) async {
    if (response.statusCode == 502 || response.statusCode == 504) {
      await _handleLoadFailure(controller, request);
    }
  }

  Future<void> _handleLoadFailure(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async {
    if (request.isForMainFrame != true ||
        _closed ||
        _recovering ||
        request.url.toString() != _loadUrl) {
      return;
    }
    final generation = _loadGeneration;
    final failedNode = _loadNode;
    // 网页表单同样不能自动重放；只为读取页面换线后重新加载。
    if (request.method?.toUpperCase() == 'GET' &&
        {'http', 'https'}.contains(request.url.scheme) &&
        _proxy.isEnabled &&
        _proxy.isSubscription &&
        _recoveries < _proxy.nodeCount) {
      _recovering = true;
      _recoveries++;
      try {
        if (await _proxy.recover(failedNodeId: failedNode) &&
            !_closed &&
            generation == _loadGeneration) {
          await _proxy.applyToWebView();
          if (_closed || generation != _loadGeneration) return;
          await controller.loadUrl(urlRequest: URLRequest(url: request.url));
          return;
        }
      } catch (_) {
        // 失败仍保留代理，不回退直连。
      } finally {
        _recovering = false;
      }
    }
    if (!_closed && generation == _loadGeneration) {
      loadingProgress.value = 1;
      setError(_proxy.errorMessage ?? '网页加载失败，请检查网络线路后重试');
    }
  }

  void onProgressChanged(InAppWebViewController controller, int progress) {
    loadingProgress.value = progress / 100;
  }

  void onLoadStop(InAppWebViewController controller, WebUri? url) {
    loadingProgress.value = 1.0;
    controller.evaluateJavascript(
      source: '''
      document.documentElement.style.webkitUserSelect = 'text';
      document.documentElement.style.userSelect = 'text';
    ''',
    );
  }

  void onTitleChanged(InAppWebViewController controller, String? titleText) {
    if (titleText != null) {
      title.value = titleText;
    }
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.CANCEL;
    if (uri.scheme == 'mailto' || uri.scheme == 'tel' || uri.scheme == 'sms') {
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }
}
