import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../widgets/dis_loading.dart';
import 'webview_controller.dart';

class WebViewPage extends GetView<WebViewController> {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Obx(() {
            if (controller.loadingProgress < 1.0) {
              return LinearProgressIndicator(
                value: controller.loadingProgress.value,
                backgroundColor: Colors.white70,
              );
            }
            return const SizedBox();
          }),
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => InAppWebView(
              initialUrlRequest: controller.isHtml.value
                  ? null
                  : URLRequest(url: WebUri(controller.content.value)),
              initialData: controller.isHtml.value
                  ? InAppWebViewInitialData(data: controller.content.value)
                  : null,
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                useOnLoadResource: true,
                javaScriptEnabled: true,
                supportZoom: true,
                allowsInlineMediaPlayback: true,
                disableContextMenu: false,
              ),
              onWebViewCreated: controller.onWebViewCreated,
              onLoadStart: controller.onLoadStart,
              onProgressChanged: controller.onProgressChanged,
              onLoadStop: controller.onLoadStop,
              onTitleChanged: controller.onTitleChanged,
              shouldOverrideUrlLoading: controller.shouldOverrideUrlLoading,
            ),
          ),
          Obx(() {
            if (controller.loadingProgress < 0.5) {
              return Center(child: DisRefreshLoading());
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
