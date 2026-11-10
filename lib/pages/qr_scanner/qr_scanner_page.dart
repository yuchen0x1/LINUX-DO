import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:flutter/cupertino.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  bool hasPermission = false;
  bool isLoading = false;
  String? error;
  bool isTorchEnabled = false;

  late final MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 初始化扫描控制器
    controller = MobileScannerController(
      // 使用正常速度进行扫描
      detectionSpeed: DetectionSpeed.normal,
      // 使用后置摄像头
      facing: CameraFacing.back,
      // 初始关闭闪光灯
      torchEnabled: false,
      // 只扫描QR码
      formats: [BarcodeFormat.qrCode],
      // 启用自动对焦
      autoStart: true,
    );

    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!hasPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  Future<void> _checkPermission() async {
    try {
      setState(() => isLoading = true);

      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() => hasPermission = true);
        await _startScanner();
      } else {
        final result = await Permission.camera.request();
        setState(() => hasPermission = result.isGranted);
        if (result.isGranted) {
          await _startScanner();
        }
      }
    } catch (e) {
      l.e('检查相机权限失败: $e');
      setState(() => error = '检查相机权限失败: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _startScanner() async {
    try {
      await controller.start();
      l.d('扫描器启动成功');
    } catch (e) {
      l.e('启动扫描器失败: $e');
      setState(() => error = '启动扫描器失败: $e');
    }
  }

  void _toggleTorch() async {
    try {
      await controller.toggleTorch();
      setState(() => isTorchEnabled = !isTorchEnabled);
      l.d('切换闪光灯: ${isTorchEnabled ? '开' : '关'}');
    } catch (e) {
      l.e('切换闪光灯失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '扫码登录',
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w600,
            fontFamily: AppFontFamily.dinPro,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, size: 24.w),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTorchEnabled
                  ? CupertinoIcons.lightbulb_fill
                  : CupertinoIcons.lightbulb,
              size: 24.w,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: Icon(CupertinoIcons.camera_rotate, size: 24.w),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: DisSquareLoading())
          : error != null
          ? Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.w),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 12.w,
                      offset: Offset(0, 4.w),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 48.w,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    16.vGap,
                    Text(
                      error!,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    24.vGap,
                    SizedBox(
                      width: 120.w,
                      child: DisButton(
                        text: '重试',
                        type: ButtonType.primary,
                        onPressed: () {
                          setState(() => error = null);
                          _checkPermission();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : !hasPermission
          ? Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.w),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 12.w,
                      offset: Offset(0, 4.w),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.camera,
                      size: 48.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    16.vGap,
                    Text(
                      '需要相机权限来扫描二维码',
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFontFamily.dinPro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    8.vGap,
                    Text(
                      '请在设置中允许访问相机',
                      style: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    24.vGap,
                    SizedBox(
                      width: 120.w,
                      child: DisButton(
                        text: '去设置',
                        type: ButtonType.primary,
                        onPressed: () async {
                          if (await openAppSettings()) {
                            await Future.delayed(const Duration(seconds: 1));
                            _checkPermission();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    l.d('检测到条码: ${capture.barcodes.length}个');
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      l.d('条码类型: ${barcode.format}, 内容: ${barcode.rawValue}');
                      if (barcode.rawValue != null) {
                        Get.back(result: barcode.rawValue);
                        break;
                      }
                    }
                  },
                  errorBuilder: (context, error) {
                    l.e('相机错误: ${error.errorCode}');
                    return Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.w),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withValues(alpha: 0.1),
                              blurRadius: 12.w,
                              offset: Offset(0, 4.w),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.camera_fill,
                              size: 48.w,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            16.vGap,
                            Text(
                              '相机初始化失败: ${error.errorCode}',
                              style: TextStyle(
                                fontSize: 14.w,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            24.vGap,
                            SizedBox(
                              width: 120.w,
                              child: DisButton(
                                text: '重试',
                                type: ButtonType.primary,
                                onPressed: _startScanner,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                CustomPaint(painter: ScannerOverlay(), child: Container()),
              ],
            ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutoutSize = size.width * 0.7;
    final cutoutPosition = (size.width - cutoutSize) / 2;

    // Draw the semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              cutoutPosition,
              (size.height - cutoutSize) / 2,
              cutoutSize,
              cutoutSize,
            ),
            const Radius.circular(12),
          ),
        ),
      ),
      paint,
    );

    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutoutPosition,
          (size.height - cutoutSize) / 2,
          cutoutSize,
          cutoutSize,
        ),
        const Radius.circular(12),
      ),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
