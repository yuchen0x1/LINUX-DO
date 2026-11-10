import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:cookie_jar/cookie_jar.dart' as cookie_jar;

class CloudflareTimingsService extends StatefulWidget {
  final VoidCallback onCookiesLoaded;

  const CloudflareTimingsService({
    super.key,
    required this.onCookiesLoaded,
  });

  @override
  CloudflareTimingsServiceState createState() =>
      CloudflareTimingsServiceState();
}

class CloudflareTimingsServiceState extends State<CloudflareTimingsService>
    with ToastMixin {
  final CloudflareController cloudflareController =
      Get.find<CloudflareController>();

  @override
  Widget build(BuildContext context) {
    final csrfToken = StorageManager.getString(AppConst.identifier.csrfToken);
    return InAppWebView(
      key: UniqueKey(),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        cacheEnabled: true,
        userAgent: NetClient.userAgent,
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: true,
        allowsInlineMediaPlayback: true,
        allowFileAccess: true,
        allowContentAccess: true,
        useShouldInterceptRequest: true,
        transparentBackground: true,
        mediaPlaybackRequiresUserGesture: false,
        thirdPartyCookiesEnabled: true,
        blockNetworkImage: false,
        blockNetworkLoads: false,
        supportZoom: true,
        builtInZoomControls: true,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        safeBrowsingEnabled: true,
        isFraudulentWebsiteWarningEnabled: true,
        hardwareAcceleration: true,
        algorithmicDarkeningAllowed: true,
        sharedCookiesEnabled: true,
        useHybridComposition: true,
        iframeAllow: 'script; form',
        iframeAllowFullscreen: true,
        contentBlockers: const [],
        useShouldOverrideUrlLoading: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        isInspectable: true,
      ),
      initialUrlRequest: URLRequest(
        url: WebUri(cloudflareController.resultUrl),
        headers: {
          'User-Agent': NetClient.userAgent,
          if (csrfToken != null) 'X-CSRF-Token': csrfToken,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'zh-CN,zh-Hans;q=0.9'
        },
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        cloudflareController.webViewController = controller;
        cloudflareController.setupCookies(controller);
      },
      onLoadStart: (controller, url) {
        //l.d('开始加载: $url');
        if (url.toString().contains('cloudflare') ||
            url.toString().contains('challenge')) {
          //l.d('检测到 Cloudflare 验证页面');
          cloudflareController.isCloudflareDetected = true;
        }
      },
      onLoadStop: (controller, url) async {
        await cloudflareController.syncCookies();
        cloudflareController.injectScript();
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';
        if (url.contains('cloudflare') || url.contains('challenge')) {
          l.d('拦截到 Cloudflare 验证请求: $url');
          cloudflareController.isCloudflareDetected = true;
        } else if (url.contains('login')) {
          l.d('检测到登录页面，清除 Cloudflare 标志');
          cloudflareController.isCloudflareDetected = false;
          cloudflareController.retryTimer?.cancel(); // 取消重试
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        l.e('WebView 加载错误: $error');
        cloudflareController.scheduleRetry();
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (consoleMessage.message.contains($URTA)) {
          if (consoleMessage.message.contains('Success')) {
            cloudflareController.scrollByLength(0);
          }
        }
      },
      gestureRecognizers: const {},
    );
  }
}

class CloudflareController extends BaseController {
  CloudflareController();

  InAppWebViewController? webViewController;
  final RxBool isLoggedIn = false.obs;
  bool isCloudflareDetected = false;
  String resultUrl = '';
  Timer? retryTimer;
  late int topicId;

  // 防抖相关
  Timer? _scrollDebounceTimer;
  bool _isScrolling = false;
  static const _scrollDebounceTime = Duration(milliseconds: 500);

  // 7秒时间窗口限制
  Timer? _scrollWindowTimer;
  static const _scrollTimeWindow = Duration(seconds: 7);

  @override
  void onInit() {
    super.onInit();
    topicId = Get.arguments;
    resultUrl = '${HttpConfig.baseUrl}t/topic/$topicId';
  }

  @override
  void onClose() {
    retryTimer?.cancel();
    super.onClose();
  }

  void injectScript() {
    if (webViewController == null) return;

    webViewController!.evaluateJavascript(source: """
    document.querySelector('meta[name=viewport]').setAttribute('content', 'width=device-width, initial-scale=0.5, maximum-scale=2.0, user-scalable=yes');
    
    // 隐藏头像和昵称
    (function() {
      // 添加自定义CSS
      const style = document.createElement('style');
      style.innerHTML = `
        /* 隐藏头像 */
        .topic-avatar, img.avatar, .avatar {
          display: none !important;
        }
        
        /* 隐藏昵称和用户信息 */
        .topic-meta-data .names, .topic-meta-data .name, .username, .user-title, 
        .topic-meta-data .badges, .badge-wrapper, .badge {
          display: none !important;
        }
        
        /* 隐藏分割线 */
        hr, .post-notice, .topic-post:not(:last-child), .topic-body:after, .topic-body:before,
        .separator, .row:after, .row:before, .topic-post + .topic-post, .topic-status-info {
          border: none !important;
          border-top: none !important;
          border-bottom: none !important;
          box-shadow: none !important;
        }
        
        /* 隐藏点赞、回复等交互按钮 */
        .post-menu-area, .post-controls, .actions, .like-button, .reply-button, 
        .bookmark-button, .show-replies, .reply-details, .like-count, 
        .reaction-button, .reaction-list, .share-button, .flag-button, 
        .topic-footer-buttons, .topic-notifications-button, .double-button {
          display: none !important;
        }

        .cooked::after {
          display: none !important;
        }
        
        /* 放大已读/未读圆点并增加间距 */
        .fa.d-icon-circle, svg.d-icon-circle, .d-icon.d-icon-circle, .read-icon {
          transform: scale(3) !important;
          margin-right: 20px !important;
          display: inline-block !important;
        }
        
        /* 确保圆点容器有足够空间 */
        .topic-post .read-state {
          display: inline-block !important;
          min-width: 10px !important;
          min-height: 10px !important;
          margin-right: 25px !important;
          position: relative !important;
        } 
      `;
      document.head.appendChild(style);
      
      console.log('已隐藏头像、昵称、分割线和交互按钮');
    })();
    """);

    webViewController!.evaluateJavascript(source: """
    // 监听 topics/timings 接口调用
    (function() {
      // 拦截 XMLHttpRequest
      const originalXhrOpen = XMLHttpRequest.prototype.open;
      const originalXhrSend = XMLHttpRequest.prototype.send;
      
      XMLHttpRequest.prototype.open = function(method, url, ...args) {
        this._url = url;
        this._method = method;
        return originalXhrOpen.apply(this, [method, url, ...args]);
      };
      
      XMLHttpRequest.prototype.send = function(body) {
        if (this._url && this._url.includes('topics/timings')) {
          const originalOnLoad = this.onload;
          this.onload = function() {
            if (this.status >= 200 && this.status < 300) {
              console.log('${$URTA} Success');
            }else{
              console.log('${$URTA} Failed');
            }
            
            if (originalOnLoad) {
              originalOnLoad.apply(this, arguments);
            }
          };
        }
        return originalXhrSend.apply(this, arguments);
      };
      
      // 拦截 fetch API
      const originalFetch = window.fetch;
      window.fetch = function(resource, init) {
        const url = (typeof resource === 'string') ? resource : resource.url;
        if (url && url.includes('topics/timings')) {
          return originalFetch(resource, init).then(response => {
            if (response.ok) {
              console.log('${$URTA} Success');
            }else{
              console.log('${$URTA} Failed');
            }
            return response;
          });
        }
        return originalFetch(resource, init);
      };
      
      console.log('已设置 topics/timings 接口监听');
    })();
    """);
  }

  Future<void> updateTopicTiming(Map<String, dynamic> timings) async {
    if (webViewController == null) return;

    final csrfToken = StorageManager.getString(AppConst.identifier.csrfToken);

    final Map<String, dynamic> requestData = {
      'topic_id': timings['topic_id'],
      'topic_time': timings['topic_time'],
      'timings': timings['timings']
    };

    final isLoggedInResult = await webViewController?.evaluateJavascript(
        source: 'document.querySelector(".current-user") !== null');

    if (isLoggedInResult != true) {
      l.e('用户未登录，无法更新阅读时间');
      return;
    }

    // 获取当前页面的所有 cookies
    final cookiesResult =
        await webViewController?.evaluateJavascript(source: '''
        document.cookie
      ''');

    l.d('当前页面 cookies: $cookiesResult');

    final js = '''
      (function() {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', '${HttpConfig.baseUrl}topics/timings', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('X-CSRF-Token', '${csrfToken ?? ''}');
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.setRequestHeader('Accept', '*/*');
        xhr.setRequestHeader('Accept-Language', 'zh-CN,zh;q=0.9,en;q=0.8');
        xhr.setRequestHeader('Discourse-Present', 'true');
        xhr.setRequestHeader('Discourse-Background', 'true');
        xhr.setRequestHeader('discourse-logged-in', 'true');
        xhr.setRequestHeader('X-SILENCE-LOGGER', 'true');
        xhr.setRequestHeader('priority', 'u=1, i');
        xhr.setRequestHeader('User-Agent', '${NetClient.userAgent}');
        xhr.setRequestHeader('Origin', '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}');
        xhr.setRequestHeader('Referer', '${HttpConfig.baseUrl}t/topic/${requestData['topic_id']}');
        
        xhr.onload = function() {
          if (xhr.status === 200) {
            console.log('${$URTA} Success');
          } else {
            console.error('${$URTA} Failed: {length: ${requestData['topic_time']}}');
          }
        };
        
        xhr.onerror = function() {
          console.error('${$URTA} Failed: {length: ${requestData['topic_time']}}');
        };
        
        xhr.send(JSON.stringify(${jsonEncode(requestData)}));
      })()
    ''';

    try {
      await webViewController?.evaluateJavascript(source: js);
    } catch (e, stack) {
      l.e('执行脚本失败: $e\n$stack');
    }
  }

  Future<void> setupCookies(InAppWebViewController controller) async {
    try {
      await CookieManager.instance().deleteAllCookies();

      final cookieList = await NetClient.getInstance()
          .cookieJar
          .loadForRequest(Uri.parse(HttpConfig.baseUrl));

      final token = StorageManager.getString(AppConst.identifier.token) ?? '';
      final cfClearance =
          StorageManager.getString(AppConst.identifier.cfClearance) ?? '';
      final sessionCookie =
          StorageManager.getString(AppConst.identifier.sessionCookie) ?? '';
      if (cookieList.isNotEmpty) {
        for (final cookie in cookieList) {
          if (cookie.name == '_t' && cookie.value.isEmpty) {
            cookie.value = token;
          }
          if (cookie.name == '_cf_clearance' && cookie.value.isNotEmpty) {
            cookie.value = cfClearance;
          }
          if (cookie.name == '_forum_session' && cookie.value.isNotEmpty) {
            cookie.value = sessionCookie;
          }
          await CookieManager.instance().setCookie(
            url: WebUri(HttpConfig.baseUrl),
            name: cookie.name,
            value: cookie.value,
            domain: cookie.domain ?? HttpConfig.domain,
            path: cookie.path ?? '',
            isHttpOnly: cookie.httpOnly,
            isSecure: cookie.secure,
            expiresDate: cookie.expires != null
                ? (cookie.expires!.millisecondsSinceEpoch ~/ 1000)
                : null,
          );
        }
        l.d('已同步 cookies 到 CookieManager: ${cookieList.length} 个');
      } else {
        l.w('未收到 cookies，跳过设置');
      }

      controller.addJavaScriptHandler(
        handlerName: 'checkLoginStatus',
        callback: (args) {
          l.d('登录状态检查结果: $args');
          if (args.isNotEmpty && args[0]['isLoggedIn'] == true) {
            isLoggedIn.value = true;
          }
          return null;
        },
      );

      final allCookiesJs = cookieList.map((cookie) {
        return "document.cookie='${cookie.name}=${cookie.value}; domain=${cookie.domain ?? HttpConfig.domain}; path=${cookie.path ?? '/'}'";
      }).join(';');

      controller.evaluateJavascript(source: '''
        $allCookiesJs;
        window.addEventListener('load', function() {
          const isLoggedIn = document.querySelector('.current-user') !== null;
          window.flutter_inappwebview.callHandler('checkLoginStatus', {
            isLoggedIn: isLoggedIn,
            cookies: document.cookie,
            elements: {
              userMenu: !!document.querySelector('.current-user'),
              loginButton: !!document.querySelector('.login-button')
            }
          });
        });
      ''');
    } catch (e, stack) {
      l.e('设置 cookies 失败: $e\n$stack');
    }
  }

  Future<bool> simulateUserInteraction() async {
    if (webViewController == null) {
      l.w('WebViewController 未初始化');
      return false;
    }

    try {
      // 检查 Turnstile 是否存在
      final hasTurnstile =
          await webViewController!.evaluateJavascript(source: '''
      !!document.querySelector('div.cf-turnstile')
    ''') ?? false;

      if (!hasTurnstile) {
        isCloudflareDetected = false;
        return true;
      }

      final turnstileInfo =
          await webViewController!.evaluateJavascript(source: '''
      const turnstile = document.querySelector('div.cf-turnstile');
      ({
        sitekey: turnstile?.getAttribute('data-sitekey') || 'unknown',
        action: turnstile?.getAttribute('data-action') || 'unknown',
        iframeSrc: document.querySelector('div.cf-turnstile iframe')?.src || 'none'
      })
    ''') ?? {'sitekey': 'unknown', 'action': 'unknown', 'iframeSrc': 'none'};
      l.d('Turnstile 配置: $turnstileInfo');

      await webViewController!.evaluateJavascript(source: '''
      const turnstile = document.querySelector('div.cf-turnstile iframe');
      if (turnstile) {
        // 模拟鼠标轨迹
        const moveEvents = [
          new MouseEvent('mousemove', { bubbles: true, clientX: 100, clientY: 100 }),
          new MouseEvent('mousemove', { bubbles: true, clientX: 150, clientY: 120 }),
          new MouseEvent('mousemove', { bubbles: true, clientX: 200, clientY: 150 })
        ];
        moveEvents.forEach(event => turnstile.dispatchEvent(event));

        // 模拟点击
        const clickEvent = new MouseEvent('click', { bubbles: true, clientX: 200, clientY: 150 });
        turnstile.dispatchEvent(clickEvent);

        // 触发 Turnstile 执行
        if (typeof window.turnstile !== 'undefined') {
          window.turnstile.render(turnstile, {
            sitekey: '${turnstileInfo['sitekey']}',
            callback: function(token) {
              console.log('Turnstile token: ' + token);
              window.flutter_inappwebview.callHandler('turnstileCallback', token);
            }
          });
        }
      }
    ''');

      webViewController!.addJavaScriptHandler(
        handlerName: 'turnstileCallback',
        callback: (args) async {
          final token = args[0];
          l.d('收到 Turnstile token: $token');
          await webViewController!.evaluateJavascript(source: '''
          document.querySelector('input[name="cf-turnstile-response"]').value = '$token';
        ''');
        },
      );

      // 轮询验证状态
      for (int i = 0; i < 12; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final verification =
            await webViewController!.evaluateJavascript(source: '''
        const response = document.querySelector('input[name="cf-turnstile-response"]')?.value;
        const cookies = document.cookie;
        const location = window.location.href;
        ({
          isValid: response !== undefined && response !== '',
          response: response || '',
          cookies: cookies || '',
          location: location
        })
      ''') ?? {'isValid': false, 'response': '', 'cookies': '', 'location': ''};

        if (verification['isValid']) {
          isCloudflareDetected = false;

          // 同步 cookies
          final webCookies = await CookieManager.instance()
              .getCookies(url: WebUri(HttpConfig.baseUrl));
          await NetClient.getInstance().cookieJar.saveFromResponse(
                Uri.parse(HttpConfig.baseUrl),
                webCookies
                    .map((c) => cookie_jar.Cookie(c.name, c.value)
                      ..domain = HttpConfig.domain
                      ..path = '/'
                      ..secure = true
                      ..httpOnly = c.isHttpOnly ?? false)
                    .toList(),
              );

          if (verification['response'].isNotEmpty) {
            await webViewController!.evaluateJavascript(source: '''
            const form = document.querySelector('form');
            if (form) {
              form.submit();
            }
          ''');
          }

          // 重新加载目标页面
          await webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri('')),
          );
          return true;
        }
      }

      l.w('Turnstile 验证超时未通过，稍后重试');
      scheduleRetry();
      return false;
    } catch (e, stack) {
      l.e('模拟用户交互失败: $e\n$stack');
      scheduleRetry();
      return false;
    }
  }

  Future<void> syncCookies() async {
    final domains = [
      WebUri(HttpConfig.baseUrl),
      WebUri('https://challenges.cloudflare.com'),
    ];
    for (final domain in domains) {
      final cookies = await CookieManager.instance().getCookies(url: domain);
      if (cookies.isNotEmpty) {
        await NetClient.getInstance().cookieJar.saveFromResponse(
              Uri.parse(domain.toString()),
              cookies
                  .map((c) => cookie_jar.Cookie(c.name, c.value)
                    ..domain = domain.host
                    ..path = '/'
                    ..secure = true
                    ..httpOnly = c.isHttpOnly ?? false)
                  .toList(),
            );
        l.d('从 $domain 同步 cookies: ${cookies.map((c) => "${c.name}=${c.value}")}');
      }
    }
  }

  void scheduleRetry() {
    const maxRetries = 3;
    int retryCount = 0;

    if (retryCount >= maxRetries) {
      l.w('达到最大重试次数 ($maxRetries)，停止重试');
      return;
    }

    retryTimer?.cancel();
    retryTimer = Timer(const Duration(seconds: 5), () async {
      if (webViewController != null) {
        final currentUrl = await webViewController!.getUrl();
        if (currentUrl.toString().contains('login')) {
          l.d('当前页面为登录页面，停止重试');
          return;
        }

        l.d('重试加载页面... (第 ${retryCount + 1} 次)');
        retryCount++;
        webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(resultUrl)),
        );
      }
    });
  }

  // 原计划根据请求参数的长度 也就是一次读多少条,发现没什么用
  void scrollByLength(double length) {
    // 如果正在滚动中，取消本次操作
    if (_isScrolling) {
      return;
    }

    // 取消之前设置的定时器
    _scrollDebounceTimer?.cancel();

    // 这保证了5秒内只有最后一个调用会被执行
    if (_scrollWindowTimer == null || !_scrollWindowTimer!.isActive) {
      _scrollDebounceTimer = Timer(_scrollDebounceTime, () {
        _performScroll(length);
      });
    } else {
      // 已有窗口定时器在运行，等待最后一个操作
      _scrollDebounceTimer = Timer(_scrollTimeWindow, () {
        _performScroll(length);
      });
    }
  }

  void _performScroll(double length) {
    if (webViewController == null) return;

    _isScrolling = true;

    final screenHeight = MediaQuery.of(Get.context!).size.height * 0.9;
    webViewController?.scrollBy(x: 0, y: screenHeight.toInt()).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _isScrolling = false;
      });

      // 设置窗口定时器，在这段时间内的请求都会被延迟
      _scrollWindowTimer?.cancel();
      _scrollWindowTimer = Timer(_scrollTimeWindow, () {
        // 时间窗口结束
      });
    }).catchError((error) {
      _isScrolling = false;
    });
  }
}

const $URTA = 'updateReadingTimeApp';
