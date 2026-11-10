import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/pages/profile/connect_controller.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/utils/expand/string_expand.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/glowing_text_wweep.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ConnectPage extends GetView<ConnectController> {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: AppFontFamily.dinPro,
          ),
        ),
      ),
      body: Column(
        children: [
          _webView(),

          // 显示解析后的数据
          Expanded(
            child: Obx(() {
              final data = controller.connectData.value;
              if (data == null) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Data acquisition in progress ... ',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFontFamily.dinPro,
                        ),
                      ),
                      6.hGap,
                      SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                children: [
                  const FlipCard(),
                  ConnectDataWidget(data: data),
                  // 先不做了
                  // PopularColorsWidget(data: data),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Center _webView() {
    return Center(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          width: double.infinity,
          height: 1,
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse('https://connect.linux.do/')),
            ),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              cacheEnabled: true,
              useHybridComposition: true,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (webViewController) {
              controller.webViewController = webViewController;

              // 设置cookie
              controller.setupCookies(webViewController);
            },
            onLoadStop: (controller, url) {
              if (url.toString().contains('connect.linux.do')) {
                controller
                    .evaluateJavascript(
                      source: "document.documentElement.outerHTML",
                    )
                    .then((value) {
                      if (value != null && value is String) {
                        Get.find<ConnectController>().updateContent(value);
                      }
                    });
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
        ),
      ),
    );
  }
}

class FlipCard extends StatefulWidget {
  const FlipCard({super.key});

  @override
  FlipCardState createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller)
      ..addListener(() {
        setState(() {
          _isFront = _controller.value < 0.5;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userinfo = Get.find<GlobalController>().userInfo?.user;
    return Padding(
      padding: const EdgeInsets.all(16.0).w,
      child: GestureDetector(
        onTap: _toggleCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value),
              alignment: Alignment.center,
              child: _isFront ? _buildFront(userinfo) : _buildBack(userinfo),
            );
          },
        ),
      ),
    );
  }

  // 正面卡片
  Widget _buildFront(CurrentUser? userinfo) {
    final connectController = Get.find<ConnectController>();
    return Container(
      width: double.infinity,
      height: 200.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8).w,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧信息区域
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0).w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.vGap,
                  Container(
                    height: 43.w,
                    margin: const EdgeInsets.symmetric(horizontal: 16).w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: .6),
                          Theme.of(context).primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(25).w,
                        right: const Radius.circular(25).w,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1).w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25).w,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .6),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Image.asset(
                              AppImages.logoCircle,
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GlowingTextSweep(
                            text: userinfo?.username ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  26.vGap,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).w,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.person,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        6.hGap,
                        Expanded(
                          child: Text(
                            '${userinfo?.name}',
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 13,
                              fontFamily: AppFontFamily.dinPro,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.vGap,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).w,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.mail,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        6.hGap,
                        Expanded(
                          child: Obx(
                            () => Text(
                              connectController.getDisplayEmail(
                                userinfo?.email,
                              ),
                              maxLines: 1,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontSize: 13,
                                fontFamily: AppFontFamily.dinPro,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: connectController.toggleEmailVisibility,
                          child: Obx(
                            () => Icon(
                              connectController.isEmailVisible.value
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                              color: Theme.of(context).primaryColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.vGap,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).w,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        8.hGap,
                        Expanded(
                          child: Text(
                            userinfo!.createdAt!
                                    .toDateTime()
                                    ?.friendlyDateTime3 ??
                                '无',
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 13,
                              fontFamily: AppFontFamily.dinPro,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.vGap,
                  Center(
                    child: Text(
                      AppConst.sloganEn,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: .6),
                        fontFamily: AppFontFamily.dinPro,
                        fontSize: 10.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(4).w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: .6),
                  ],
                ),
                borderRadius: BorderRadius.circular(8).w,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppConst.siteName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                  const Text(
                    'Where possible begins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: QrImageView(
                      data:
                          '${HttpConfig.baseUrl}u/${userinfo.username}/summary',
                      version: QrVersions.auto,
                      gapless: false,
                      errorStateBuilder: (context, error) {
                        return const Text(
                          'Invalid QR code data',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 背面卡片
  Widget _buildBack(CurrentUser? userinfo) {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi),
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: 200.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8).w,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 250.w,
                height: 250.w,
                margin: const EdgeInsets.symmetric(vertical: 2).w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: .6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(2).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 10).w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: QrImageView(
                          data:
                              '${HttpConfig.baseUrl}u/${userinfo?.username}/summary',
                          version: QrVersions.auto,
                          gapless: false,
                          errorStateBuilder: (context, error) {
                            return const Text(
                              'Invalid QR code data',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                      ),
                      const Text(
                        AppConst.siteName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFontFamily.dinPro,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'ID: ${userinfo?.id}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.w,
                          fontFamily: AppFontFamily.dinPro,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10).w,
                      //   child: Divider(
                      //     color: Colors.white.withValues(alpha: .6),
                      //     height: 2,
                      //   ),
                      // ),
                      Text(
                        'BIRTHDAY: ${userinfo?.birthdate ?? '2024-01-17'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.w,
                          fontFamily: AppFontFamily.dinPro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectDataWidget extends StatelessWidget with ToastMixin {
  final ConnectData data;

  const ConnectDataWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).w,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4).w,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0).w,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: data.userLevel,
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: AppFontFamily.dinPro,
                      ),
                    ),
                    TextSpan(
                      text: ' 级用户${data.username}',
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFontFamily.dinPro,
                      ),
                    ),
                    TextSpan(
                      text: '   (过去 100 天内):',
                      style: TextStyle(
                        fontSize: 11.w,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFontFamily.dinPro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildHeader(context),
            ...data.trustLevelStats.entries.toList().asMap().entries.map(
              (entry) => _buildStatRow(
                context,
                entry.value.key,
                entry.value.value.current,
                entry.value.value.required,
                entry.value.value.isMet,
                entry.key % 2 == 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0).w,
              child: Row(
                children: [
                  Text(
                    "DeepLX Api Key: ${data.apiKey}",
                    style: TextStyle(
                      fontSize: 8.w,
                      color: data.meetsTrustRequirements
                          ? Colors.green.shade500
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                  6.hGap,
                  SizedBox(
                    height: 26.w,
                    child: DisButton(
                      text: '复制',
                      fontSize: 11,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data.apiKey));
                        showSuccess('拷贝成功');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 34.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: .7),
          ],
        ),
        borderRadius: BorderRadius.circular(4).w,
      ),
      margin: const EdgeInsets.only(bottom: 4).w,
      padding: const EdgeInsets.symmetric(horizontal: 16.0).w,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '项目',
              style: TextStyle(
                fontSize: 12.w,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '当前',
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: AppFontFamily.dinPro,
                ),
              ),
            ),
          ),
          20.hGap,
          Expanded(
            flex: 1,
            child: Text(
              '要求',
              style: TextStyle(
                fontSize: 12.w,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String title,
    String current,
    String required,
    bool isMet,
    bool isOdd,
  ) {
    //l.e('title: $title, current: $current, required: $required, isMet: $isMet, isOdd: $isOdd');

    return Container(
      height: 34.w,
      margin: const EdgeInsets.only(bottom: 4).w,
      decoration: BoxDecoration(
        color: isOdd ? Colors.grey.shade100 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: .5.w,
          ),
        ),
        borderRadius: BorderRadius.circular(4).w,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0).w,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.w,
                color: Colors.black87,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                current,
                style: TextStyle(
                  fontSize: 11.w,
                  color: isMet ? Colors.green.shade500 : Colors.black87,
                  fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
                  fontFamily: AppFontFamily.dinPro,
                ),
              ),
            ),
          ),
          20.hGap,
          Expanded(
            flex: 1,
            child: Text(
              required,
              style: TextStyle(
                fontSize: 11.w,
                color: Colors.black87,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularColorsWidget extends StatelessWidget {
  final ConnectData data;

  const PopularColorsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      '浏览天数': Colors.orange,
      '浏览帖子': Colors.teal,
      '阅读时长': Colors.blue,
      '点赞': Colors.purple,
      '回复': Colors.pink,
      '主题数': Colors.green,
    };

    return Padding(
      padding: const EdgeInsets.all(16.0).w,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12).w,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0).w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '过去 100 天内',
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: AppFontFamily.dinPro,
                ),
              ),
              16.vGap,
              ...data.trustLevelStats.entries
                  .map((entry) {
                    final title = entry.key;
                    final current = entry.value.current;
                    final required = entry.value.required;
                    final color = colorMap[title] ?? Colors.grey;

                    //l.w('current: $current, required: $required, title: $title, color: $color');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0).w,
                      child: _buildColorBar(current, required, title, color),
                    );
                  })
                  .toList()
                  .sublist(0, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBar(
    String current,
    String required,
    String statName,
    Color color,
  ) {
    double currentValue = 0;
    double requiredValue = 0;

    try {
      currentValue = double.parse(current.replaceAll(RegExp(r'[^0-9.]'), ''));
      requiredValue = double.parse(required.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      currentValue = 0;
      requiredValue = 1;
    }

    final double percentage = (currentValue / requiredValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current of $required',
              style: TextStyle(
                fontSize: 12.w,
                color: Colors.black87,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
            Text(
              statName,
              style: TextStyle(
                fontSize: 12.w,
                color: color,
                fontFamily: AppFontFamily.dinPro,
              ),
            ),
          ],
        ),
        8.vGap,
        ClipRRect(
          borderRadius: BorderRadius.circular(2).w,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4.w,
          ),
        ),
      ],
    );
  }
}
