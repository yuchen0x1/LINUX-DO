import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/message.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/net/http_config.dart';

import '../../../utils/log.dart';

class MessageController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();
  final RxList<Topic> messages = <Topic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() async {
    if (isUserEmpty()) return;
    isLoading.value = true;

    try {
      final data = await _apiService.getMessages(userName);
      final users = data.users;
      final topics = data.topicList?.topics ?? [];

      // 遍历消息，为每条消息匹配发送者的头像
      for (var message in topics) {
        try {
          // 查找最后发帖用户的头像
          if (message.posters?.isNotEmpty == true) {
            final lastPostUser = users.firstWhereOrNull(
                (user) => user.id == message.posters?[0].userId);
            if (lastPostUser != null) {
              if (lastPostUser.avatarTemplate.startsWith('http://') ||
                  lastPostUser.avatarTemplate.startsWith('https://')) {
                message.avatarUrl = lastPostUser.avatarTemplate;
              } else {
                message.avatarUrl =
                    '${HttpConfig.baseUrl}${lastPostUser.avatarTemplate.replaceFirst('{size}', '70')}';
              }
              l.d('lastPostUserId: ${message.posters?[0].userId}, found user: ${lastPostUser.username}');
            }
          }
        } catch (e) {
          l.e('处理消息头像失败: ${message.id}, error: $e');
        }
      }

      messages.value = topics;
    } catch (e, stackTrace) {
      l.e('获取消息失败: $e');
      l.e('堆栈信息: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }
}
