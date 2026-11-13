import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'net/message_bus_service.dart';
import 'net/proxy_service.dart';

import 'package:get_storage/get_storage.dart';
import 'package:linux_do/utils/log.dart';

import 'controller/global_controller.dart';
import 'net/api_service.dart';
import 'net/http_client.dart';
import 'net/http_config.dart';
import 'utils/inject.dart';
import 'utils/storage_manager.dart';
import 'utils/device_util.dart';
import 'utils/secure_store.dart';
import 'net/user_api_key_auth_service.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'utils/tag.dart';

class App {
  static final App _instance = App.singleton();

  App.singleton();

  static App get instance {
    return _instance;
  }

  /// 初始化App
  Future<void> initial() async {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(
        ['mihomo 1.19.34 (standalone proxy core)'],
        '${await rootBundle.loadString('assets/licenses/network-core-NOTICE.txt')}\n\n'
        '${await rootBundle.loadString('assets/licenses/mihomo-GPL-3.0.txt')}',
      );
    });
    // 初始化SharedPreferences
    await StorageManager.init();

    // 敏感数据进系统密钥库，并迁移旧版明文（必须早于 NetClient，拦截器要用 API Key）
    await SecureStore.init(UserApiKeyAuthService.secureKeys);

    // 初始化GetStorage
    await GetStorage.init();

    // 初始化设备信息
    await DeviceUtil.init();

    // 初始化屏幕适配
    await ScreenUtil.ensureScreenSize();

    // Restore the app-only route before any API or login WebView requests.
    ProxyService().onAllNodesFailed = (message) {
      if (Get.context != null) {
        Get.snackbar('节点异常', message, snackPosition: SnackPosition.BOTTOM);
      }
    };
    await ProxyService().initialize();

    // 初始化HTTP客户端
    await NetClient.getInstance().init();

    // 初始化API服务
    Inject.put<ApiService>(
      ApiService(NetClient.getInstance().dio, baseUrl: HttpConfig.baseUrl),
    );

    Inject.put<GlobalController>(GlobalController());

    // Tag的颜色
    Tag.init();

    // 前后台切换时启停实时推送（后台持续长轮询会明显耗电）
    WidgetsBinding.instance.addObserver(_LifecycleBridge());

    L.setDebug(kDebugMode);
  }
}

/// 把 App 生命周期转发给 MessageBusService。
/// 单独抽类而不是让 App 实现 Observer，保持 App 只做一次性初始化。
class _LifecycleBridge with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    MessageBusService().handleLifecycle(state);
  }
}
