import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/pages/topics/details/web_post_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/widgets/cloudflare_timings_service.dart';

class WebPostReadPage extends GetView<WebPostReadController> {
  const WebPostReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auto Read',
          style: TextStyle(fontSize: 16, fontFamily: AppFontFamily.dinPro),
        ),
      ),
      body: CloudflareTimingsService(onCookiesLoaded: () {}),
    );
  }
}
