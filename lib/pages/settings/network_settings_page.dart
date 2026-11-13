import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';

import '../../net/doh_service.dart';
import '../../net/http_client.dart';
import '../../net/proxy_service.dart';
import '../../utils/log.dart';
import '../../widgets/dis_switch.dart';
import '../../widgets/proxy_settings_dialog.dart';

class NetworkSettingsController extends GetxController {
  final dohService = DohService();
  final isDohEnabled = true.obs;
  final currentServerId = ''.obs;
  final isTesting = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDohEnabled.value = dohService.isEnabled;
    currentServerId.value = dohService.currentServerId;
  }

  void toggleDoh(bool value) {
    isDohEnabled.value = value;
    dohService.isEnabled = value;
    _rebuildNetworkClient();
  }

  void selectServer(String id) {
    currentServerId.value = id;
    dohService.currentServerId = id;
    _rebuildNetworkClient();
  }

  /// DoH 是在 HttpClient 创建时注入的，改配置后必须重建 Dio 适配器才生效。
  void _rebuildNetworkClient() {
    try {
      NetClient.getInstance().applyProxy();
    } catch (e) {
      l.e('应用 DoH 配置失败: $e');
    }
  }

  Future<void> testSpeed() async {
    isTesting.value = true;
    try {
      await dohService.pingAll();
    } finally {
      isTesting.value = false;
      update();
    }
  }
}

class NetworkSettingsPage extends GetView<NetworkSettingsController> {
  const NetworkSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '网络与 DoH 设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.shield_fill,
                    color: Theme.of(context).primaryColor,
                    size: 24.w,
                  ),
                  12.hGap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '启用 DoH 抗网络污染',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.vGap,
                        Text(
                          '通过加密通道解析域名，对标 iOS 1.0.4 防污染设计',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DisSwitch(
                    value: controller.isDohEnabled.value,
                    onChanged: controller.toggleDoh,
                  ),
                ],
              ),
            ),
            16.vGap,
            if (controller.isDohEnabled.value) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DoH 节点选择',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.isTesting.value
                        ? null
                        : controller.testSpeed,
                    icon: controller.isTesting.value
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(CupertinoIcons.speedometer, size: 16),
                    label: Text(controller.isTesting.value ? '测速中...' : '测试延迟'),
                  ),
                ],
              ),
              8.vGap,
              GetBuilder<NetworkSettingsController>(
                builder: (_) {
                  return Column(
                    children: controller.dohService.servers.map((server) {
                      final isSelected =
                          controller.currentServerId.value == server.id;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.w),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => controller.selectServer(server.id),
                          leading: Icon(
                            isSelected
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                          ),
                          title: Text(
                            server.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            server.ip,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          trailing: server.pingMs != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (server.pingMs! < 0)
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6.w),
                                  ),
                                  child: Text(
                                    server.pingMs! < 0
                                        ? '超时'
                                        : '${server.pingMs} ms',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: server.pingMs! < 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
            16.vGap,
            // HTTP 代理（网络线路）
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: ListTile(
                onTap: () => showProxySettingsDialog(context),
                leading: Icon(
                  CupertinoIcons.globe,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  '订阅与自动选线',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: AnimatedBuilder(
                  animation: ProxyService(),
                  builder: (context, _) => Text(
                    ProxyService().isEnabled
                        ? ProxyService().statusLabel
                        : '导入订阅，自动选择可用节点',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
              ),
            ),
          ],
        );
      }),
    );
  }
}
