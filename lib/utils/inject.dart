import 'package:get/get.dart';

class Inject extends GetxService {
  /// 延迟注入，在第一次使用时才创建实例
  static lazy<T>(dynamic dependency) {
    Get.lazyPut<T>(() => dependency, fenix: true);
  }

  /// 立即注入，立即创建实例
  static put<T>(T dependency) {
    Get.put<T>(dependency, permanent: true);
  }
}
