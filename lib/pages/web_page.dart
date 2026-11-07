import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io' as dart_io;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/utils/device_util.dart';
import '../../net/http_config.dart';
import '../controller/global_controller.dart';
import '../widgets/dis_loading.dart';
import '../../const/app_const.dart';
import '../../const/app_sizes.dart';
import '../../utils/log.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../net/http_client.dart';
import '../net/proxy_service.dart';
import '../net/user_api_key_auth_service.dart';
import '../widgets/state_view.dart';
import '../utils/mixins/toast_mixin.dart';
import '../utils/storage_manager.dart';

/// 很无奈,解决不了CF验证的问题,
/// 跳转系统浏览器由于无法共享cookie,目前唯一能想到方法
/// 使用webview加载,然后检查cookie,如果cookie存在,则认为登录成功
class WebPage extends StatefulWidget {
  final String? initialUrl;

  const WebPage({super.key, this.initialUrl});

  /// 清理所有 WebView 缓存
  static Future<void> clearCache() async {
    try {
      // 清理 Cookies
      await CookieManager.instance().deleteAllCookies();

      // 清理缓存和存储
      await InAppWebViewController.clearAllCache();

      l.d('WebView 缓存已清理');
    } catch (e) {
      l.e('清理 WebView 缓存失败: $e');
    }
  }

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> with ToastMixin {
  InAppWebViewController? _controller;
  bool isLoading = true;
  String? _error;
  late final CookieJar _cookieJar;
  String _userAgent = '';

  @override
  void initState() {
    super.initState();
    // WebView 也要走同样的代理线路（登录授权页需可达 linux.do）
    ProxyService().applyToWebView();
    _initCookieJar();
    _initUserAgent();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _initUserAgent() async {
    setState(() {});
    _userAgent = await DeviceUtil.getUserAgent();
  }

  Future<void> _initCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';
    _cookieJar =
        PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
    setState(() {});
  }

  Future<void> _checkAndSaveCookies() async {
    try {
      final uri = Uri.parse('${HttpConfig.baseUrl}login');
      final webUri = WebUri(uri.toString());

      // 获取所有 Cookie
      final cookieManager = CookieManager.instance();
      List<Cookie> inAppCookies = await cookieManager.getCookies(url: webUri);

      bool hasTokenCookie = false;
      bool hasSessionCookie = false;
      bool hasCfCookie = false;
      bool needsCfVerification = false; // 添加标志位判断是否需要 CF 验证

      // 检查是否需要 Cloudflare 验证
      // 网站使用了 Cloudflare 的 DDoS 保护才需要获取这个
      for (var cookie in inAppCookies) {
        if (cookie.name == 'cf_clearance') {
          needsCfVerification = true;
          break;
        }
      }

      for (var cookie in inAppCookies) {
        final name = cookie.name;
        final value = cookie.value;

        // 根据 Cookie 名称保存特定的 Cookie
        if (name == NetClient.tokenKey) {
          hasTokenCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
          await StorageManager.setData(
              AppConst.identifier.token, value);
        } else if (name == NetClient.forumSession) {
          hasSessionCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
          await StorageManager.setData(
              AppConst.identifier.sessionCookie, value);
        } else if (name == NetClient.cfClearance && needsCfVerification) {
          hasCfCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
          await StorageManager.setData(
              AppConst.identifier.cfClearance, value);
        }
      }

      // 根据是否需要 CF 验证来判断登录条件
      bool isLoginSuccess = hasTokenCookie &&
          hasSessionCookie &&
          (!needsCfVerification || (needsCfVerification && hasCfCookie));

      if (isLoginSuccess) {
        await Future.delayed(const Duration(milliseconds: 500));

        int maxRetries = 5;
        var result;

        for (int i = 0; i < maxRetries; i++) {
          // 首先尝试从 meta 标签获取
          result = await _controller?.evaluateJavascript(source: '''
            (function() {
              const meta = document.querySelector('meta[name="csrf-token"]');
              return meta ? meta.getAttribute('content') : null;
            })();
        ''');

          // 如果 meta 标签获取失败，尝试通过 API 获取
          if (result == null ||
              result.toString() == '{}' ||
              result.toString().isEmpty) {
            result = await _controller?.evaluateJavascript(source: '''
              fetch('${HttpConfig.baseUrl}session/csrf', {
                credentials: 'include',
                headers: {
                  'Accept': 'application/json',
                  'X-Requested-With': 'XMLHttpRequest',
                  'User-Agent': '$_userAgent'
                }
              })
              .then(response => response.text())
              .then(text => {
                try {
                  const data = JSON.parse(text);
                  return data.csrf;
                } catch (e) {
                  console.error('解析响应失败:', e);
                  return null;
                }
              })
              .catch(error => {
                console.error('请求失败:', error);
                return null;
              });
      ''');
          }

          // 检查是否获取到有效的 token
          if (result != null &&
              result.toString() != '{}' &&
              result.toString().isNotEmpty) {

            // 更新请求头
            NetClient.getDio.options.headers['x-csrf-token'] = result.toString();

            await StorageManager.setData(
                AppConst.identifier.csrfToken, result.toString());
            break;
          } else {
            if (i < maxRetries - 1) {
              // 在重试之前等待一段时间
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }

        if (result == null ||
            result.toString() == '{}' ||
            result.toString().isEmpty) {
          return;
        }

        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            Get.back(result: true);
          });
        }
      } else {
        // 如果没有获取到所需的 cookies，尝试请求相关接口
        await _controller?.evaluateJavascript(source: '''
          fetch('${HttpConfig.baseUrl}session/csrf', {
            credentials: 'include',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
          }).then(() => {
            return fetch('${HttpConfig.baseUrl}top.json', {
              credentials: 'include'
            });
          }).catch(error => {
            console.error('请求失败:', error);
          });
        ''');
      }
    } catch (e) {
      l.e('检查 cookies 失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.login.webTitle,
          style: TextStyle(fontSize: AppSizes.fontNormal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
                url: WebUri(widget.initialUrl ?? HttpConfig.baseUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              userAgent: _userAgent,
              cacheEnabled: true,
              clearCache: false,
              allowFileAccess: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              supportMultipleWindows: true,
              incognito: false,
              javaScriptCanOpenWindowsAutomatically: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              resourceCustomSchemes: ['cloudflare-challenge'],
              useWideViewPort: true,
              loadWithOverviewMode: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              applicationNameForUserAgent: 'Version/8.0.2 Safari/605.1.15',
              preferredContentMode: UserPreferredContentMode.RECOMMENDED,
              useShouldInterceptAjaxRequest: false,
              thirdPartyCookiesEnabled: true,
              allowContentAccess: true,
              safeBrowsingEnabled: false,
              disableContextMenu: false,
              useOnLoadResource: true,
              geolocationEnabled: false,
              transparentBackground: true,
              verticalScrollBarEnabled: true,
              horizontalScrollBarEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() => isLoading = false);
              await _checkAndSaveCookies();

              // 注入辅助脚本
              await controller.evaluateJavascript(source: '''
                // 自动点击验证按钮
                function autoClickTurnstile() {
                  const buttons = document.querySelectorAll('button, input[type="submit"]');
                  for (const button of buttons) {
                    if (button.textContent.includes('Verify') || 
                        button.value?.includes('Verify')) {
                      button.click();
                    }
                  }
                }
                setInterval(autoClickTurnstile, 1000);
              ''');
            },
            // ignore: deprecated_member_use
            onLoadError: (controller, url, code, message) {
              setState(() {
                _error = message;
                isLoading = false;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url!;

              // 拦截官方 User API Key 授权回跳
              if (uri.scheme == 'linuxdo' && uri.host == 'auth') {
                final payload = uri.queryParameters['payload'];
                if (payload != null && payload.isNotEmpty) {
                  try {
                    final decrypted =
                        UserApiKeyAuthService().decryptPayload(payload);
                    final data =
                        decrypted.startsWith('{') ? decrypted : '{"key":"$decrypted"}';
                    final Map<String, dynamic> decoded = jsonDecode(data);
                    final key = decoded['key'] as String?;
                    if (key != null && key.isNotEmpty) {
                      await UserApiKeyAuthService().saveApiKey(key);
                      await StorageManager.setData(
                          AppConst.identifier.isLogin, true);
                      Get.find<GlobalController>().setIsLogin(true);
                      showSuccess('官方 API Key 授权成功');
                      Get.back(result: true);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } catch (e) {
                    l.e('User API Key 授权回跳处理失败: $e');
                  }
                }
                showError('API Key 授权失败');
                return NavigationActionPolicy.CANCEL;
              }

              if (['about', 'data', 'javascript'].contains(uri.scheme)) {
                return NavigationActionPolicy.ALLOW;
              }

              final allowedDomains = [
                HttpConfig.domain,
                'challenges.cloudflare.com',
                'js.stripe.com',
                'cloudflareinsights.com',
                'stripe.network',
                'stripe.com',
                'turnstile.com',
                'cloudflare.com',
                'hcaptcha.com',
                'gstatic.com',
                'google.com',
                'recaptcha.net',
              ];

              bool isAllowed =
                  allowedDomains.any((domain) => uri.host.endsWith(domain));

              if (isAllowed) {
                return NavigationActionPolicy.ALLOW;
              }

              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (isLoading) const Center(child: DisSquareLoading()),
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '加载失败',
                    style: TextStyle(
                      fontSize: AppSizes.fontMedium,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  8.vGap,
                  TextButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _controller?.reload();
                    },
                    child: const StateViewError(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
