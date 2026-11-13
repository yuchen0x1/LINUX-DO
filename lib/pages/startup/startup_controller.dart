import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';

class StartupController extends GetxController {
  late final Future<String> _destination;
  bool _isCompleting = false;

  @override
  void onInit() {
    super.onInit();
    // 登录检查与动画并行，不再根据旧的首次启动标记显示引导页。
    _destination = _resolveDestination();
  }

  Future<String> _resolveDestination() async {
    final global = Get.find<GlobalController>();
    final isAnonymous =
        StorageManager.getBool(AppConst.identifier.isAnonymousMode) ?? false;
    if (isAnonymous) {
      global.setIsAnonymousMode(true);
      return Routes.HOME;
    }
    return await global.checkLoginStatus() ? Routes.HOME : Routes.LOGIN;
  }

  Future<void> completeStartup() async {
    if (_isCompleting || isClosed) return;
    _isCompleting = true;
    final destination = await _destination;
    if (isClosed) return;
    // 清掉启动页，返回键不会重新播放动画。
    Get.offAllNamed(destination);
  }
}
