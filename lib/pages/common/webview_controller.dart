import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../controller/base_controller.dart';

class WebViewController extends BaseController {
  final loadingProgress = 0.0.obs;
  final title = ''.obs;
  final content = ''.obs;
  final isHtml = false.obs;
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
    loadingProgress.value = 0;
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
