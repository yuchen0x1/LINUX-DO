import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';

class WebPostReadController extends BaseController {
  final topicId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    topicId.value = Get.arguments as int;
  }
}
