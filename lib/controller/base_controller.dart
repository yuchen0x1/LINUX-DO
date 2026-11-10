import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';

import '../utils/mixins/toast_mixin.dart';
import '../widgets/state_view.dart';

class BaseController extends GetxController with ToastMixin {
  // 页面加载状态
  final RxBool isLoading = false.obs;

  // 错误信息
  final RxString errorMessage = ''.obs;

  // 是否显示错误
  final RxBool hasError = false.obs;

  // 是否显示空页面
  final RxBool isEmpty = false.obs;

  // 设置加载状态
  void setLoading(bool value) {
    isLoading.value = value;
  }

  // 设置错误信息
  void setError(String message) {
    errorMessage.value = message;
    hasError.value = message.isNotEmpty;
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  // 通用的异步任务包装器
  Future<T?> handleAsync<T>(Future<T> Function() task) async {
    try {
      setLoading(true);
      clearError();
      return await task();
    } catch (e) {
      setError(AppConst.stateHint.error);
      return null;
    } finally {
      setLoading(false);
    }
  }

  ViewState getViewState() {
    if (isLoading.value) {
      return ViewState.loading;
    }
    if (hasError.value) {
      return ViewState.error;
    }
    if (isEmpty.value) {
      return ViewState.empty;
    }
    return ViewState.content;
  }
}

class BaseSuperController extends SuperController {
  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
