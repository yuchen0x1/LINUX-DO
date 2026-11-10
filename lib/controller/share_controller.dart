import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:share_plus/share_plus.dart';

class ShareController extends BaseController {
  void copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    showSuccess('链接已复制到剪贴板');
  }

  Future<void> share(
    String title,
    String description,
    String url,
    RenderBox? box,
  ) async {
    await Share.share(url, subject: title);
  }
}
