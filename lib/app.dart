import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:linux_do/utils/log.dart';

import 'controller/global_controller.dart';
import 'net/api_service.dart';
import 'net/http_client.dart';
import 'net/http_config.dart';
import 'utils/inject.dart';
import 'utils/storage_manager.dart';
import 'utils/device_util.dart';
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
    // 初始化SharedPreferences
    await StorageManager.init();

    // 初始化GetStorage
    await GetStorage.init();

    // 初始化设备信息
    await DeviceUtil.init();

    // 初始化屏幕适配
    await ScreenUtil.ensureScreenSize();

    // 初始化HTTP客户端
    await NetClient.getInstance().init();

    // 初始化API服务
    Inject.put<ApiService>(
        ApiService(NetClient.getInstance().dio, baseUrl: HttpConfig.baseUrl));

    Inject.put<GlobalController>(GlobalController());

    // Tag的颜色
    Tag.init();

    L.setDebug(kDebugMode);
  }
}
