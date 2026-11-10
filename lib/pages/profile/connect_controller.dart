import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:linux_do/net/http_client.dart';

class ConnectData {
  final String username;
  final String userLevel;
  final String apiKey;
  final Map<String, TrustLevelItem> trustLevelStats;
  final bool meetsTrustRequirements;

  ConnectData({
    required this.username,
    required this.userLevel,
    required this.apiKey,
    required this.trustLevelStats,
    required this.meetsTrustRequirements,
  });
}

class TrustLevelItem {
  final String current;
  final String required;
  final bool isMet;

  TrustLevelItem({
    required this.current,
    required this.required,
    required this.isMet,
  });
}

class ConnectController extends BaseController {
  final connectData = Rxn<ConnectData?>();
  final isEmailVisible = false.obs;
  InAppWebViewController? webViewController;

  void toggleEmailVisibility() {
    isEmailVisible.value = !isEmailVisible.value;
  }

  String getDisplayEmail(String? email) {
    if (email == null || email.isEmpty) return '';

    if (isEmailVisible.value) {
      return email;
    } else {
      final atIndex = email.indexOf('@');
      if (atIndex <= 4) {
        return '****${email.substring(atIndex)}';
      } else {
        final visibleStart = email.substring(0, 4);
        final hiddenPart = '*' * (atIndex - 4);
        final domainPart = email.substring(atIndex);
        return '$visibleStart$hiddenPart$domainPart';
      }
    }
  }

  /// 设置WebView的Cookie
  Future<void> setupCookies(InAppWebViewController controller) async {
    try {
      await CookieManager.instance().deleteAllCookies();

      final mainCookies = await NetClient.getInstance().cookieJar
          .loadForRequest(Uri.parse('https://linux.do/'));
      final connectCookies = await NetClient.getInstance().cookieJar
          .loadForRequest(Uri.parse('https://connect.linux.do/'));

      final allCookies = [...mainCookies, ...connectCookies];

      for (final cookie in allCookies) {
        await CookieManager.instance().setCookie(
          url: WebUri('https://connect.linux.do/'),
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain ?? '.linux.do',
          path: cookie.path ?? '/',
          isHttpOnly: cookie.httpOnly,
          isSecure: cookie.secure,
        );
      }
    } catch (e, s) {
      l.e('设置WebView Cookie失败: $e\n$s');
    }
  }

  void updateContent(String? html) {
    if (html == null || html.isEmpty) {
      l.w('连接页面内容为空');
      return;
    }

    try {
      final document = html_parser.parse(html);

      // 解析用户名和级别
      final titleText = document.querySelector('h1')?.text ?? '';
      final userMatch = RegExp(
        r'你好，(.*?) \((.*?)\) (\d+)级用户',
      ).firstMatch(titleText);
      final username = userMatch?.group(1) ?? '';
      final userLevel = userMatch?.group(3) ?? '';

      final apiKey = document.querySelector('strong')?.text ?? '';

      final trustStats = <String, TrustLevelItem>{};
      final table = document.querySelector('table');
      final rows = table?.querySelectorAll('tr') ?? [];

      for (var row in rows.skip(1)) {
        final cells = row.querySelectorAll('td');
        if (cells.length >= 3) {
          final item = cells[0].text.trim();
          final current = cells[1].text.trim();
          final required = cells[2].text.trim();
          final isMet = cells[1].classes.contains('text-green-500');

          trustStats[item] = TrustLevelItem(
            current: current,
            required: required,
            isMet: isMet,
          );
        }
      }

      final meetsTrustRequirements =
          document.querySelector('p.text-green-500')?.text.contains('符合信任级别') ??
          false;

      // 更新数据
      connectData.value = ConnectData(
        username: username,
        userLevel: userLevel,
        apiKey: apiKey,
        trustLevelStats: trustStats,
        meetsTrustRequirements: meetsTrustRequirements,
      );
    } catch (e, s) {
      l.e('解析连接页面内容失败: $e\n$s');
    } finally {
      isLoading.value = false;
    }
  }
}
