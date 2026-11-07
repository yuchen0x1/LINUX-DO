import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../net/http_client.dart';
import '../net/proxy_service.dart';

/// 弹出 HTTP 代理（网络线路）编辑对话框
///
/// 用法：手机已运行 Clash / v2rayNG 等 App 并导入节点订阅后，
/// 将本 App 指向其本地 HTTP 端口（如 Clash 的 127.0.0.1:7890）。
Future<void> showProxySettingsDialog(BuildContext context) async {
  final proxy = ProxyService();
  var enabled = proxy.isEnabled;
  final hostCtrl = TextEditingController(text: proxy.host);
  final portCtrl = TextEditingController(text: proxy.port);

  await Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.antenna_radiowaves_left_right,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                  8.hGap,
                  Text(
                    '网络线路 / HTTP 代理',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              4.vGap,
              Text(
                '国内网络直连 linux.do 不通时，请先在手机上运行'
                ' Clash / v2rayNG 等代理 App 并导入节点订阅，'
                '然后把本 App 指向其本地 HTTP 端口。',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.4,
                ),
              ),
              12.vGap,
              Row(
                children: [
                  Text(
                    '启用代理',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  const Spacer(),
                  Switch(
                    value: enabled,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (v) => setState(() => enabled = v),
                  ),
                ],
              ),
              8.vGap,
              TextField(
                controller: hostCtrl,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: '代理主机',
                  hintText: '127.0.0.1',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
              ),
              10.vGap,
              TextField(
                controller: portCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'HTTP 端口',
                  hintText: '7890（Clash）/ 10809（v2rayNG）',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
              ),
              16.vGap,
              SizedBox(
                width: double.infinity,
                height: 40.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                  ),
                  onPressed: () async {
                    final h = ProxyService.sanitizeHost(hostCtrl.text);
                    final p = portCtrl.text.trim();
                    if (enabled &&
                        (h.isEmpty ||
                            p.isEmpty ||
                            int.tryParse(p) == null ||
                            int.parse(p) <= 0 ||
                            int.parse(p) > 65535)) {
                      Get.snackbar('提示', '请填写正确的代理主机与端口',
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    await ProxyService().save(
                        enabled: enabled, host: h, port: p);
                    // 立即应用到 Dio 网络层
                    try {
                      NetClient.getInstance().applyProxy();
                    } catch (_) {}
                    Get.back();
                    Get.snackbar(
                        '已保存', enabled ? '代理已生效：$h:$p' : '已恢复直连',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  child: Text(
                    '保存并生效',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 可复用的「网络线路」入口行（登录页与网络设置页共用）
class ProxyEntryTile extends StatelessWidget {
  const ProxyEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final proxy = ProxyService();
    final active = proxy.hasValidRule;
    return InkWell(
      borderRadius: BorderRadius.circular(10.w),
      onTap: () => showProxySettingsDialog(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.globe,
              size: 16.w,
              color: active
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
            ),
            6.hGap,
            Text(
              '网络线路与代理',
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            Text(
              active ? '代理 ${proxy.host}:${proxy.port}' : '直连',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: active
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
              ),
            ),
            2.hGap,
            Icon(
              CupertinoIcons.chevron_right,
              size: 14.w,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}

extension on int {
  Widget get hGap => SizedBox(width: toDouble().w);
  Widget get vGap => SizedBox(height: toDouble().w);
}
