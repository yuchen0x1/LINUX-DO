import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controller/base_controller.dart';
import '../../models/chat_message.dart';
import '../../net/api_service.dart';
import '../../routes/app_pages.dart';
import '../../utils/log.dart';

class ChatListController extends BaseController {
  final ApiService apiService = Get.find();

  // 深色模式
  final RxBool isDarkMode = false.obs;
  // 字体大小
  final RxDouble fontSize = 14.0.obs;
  // 主题颜色
  final RxInt themeColorIndex = 0.obs;
  // 消息通知
  final RxBool enableNotification = true.obs;
  // 声音
  final RxBool enableSound = true.obs;
  // 震动
  final RxBool enableVibration = true.obs;

  // 搜索控制器
  final searchController = TextEditingController();

  // 消息列表
  final _messages = <ChatMessage>[].obs;

  final refreshController = RefreshController();

  // 机器人ID
  static const int robotId = -1;

  List<ChatMessage> get messages => _messages;

  // 创建机器人聊天项
  ChatMessage _createRobotChatItem() {
    // 创建机器人用户
    final robotUser = ChatUser(
      id: robotId,
      username: 'linux_assistant',
      name: 'LUNIX DO Bot',
      avatarTemplate: null,
    );

    final chatableData = ChatableData(
      group: false,
      users: [robotUser],
      uploadedLogo: null,
    );

    final meta = Meta(
      messageBusLastIds: MessageBusLastIds(
        channelMessageBusLastId: 0,
        newMessages: 0,
        newMentions: 0,
      ),
      canJoinChatChannel: true,
      canFlag: false,
      userSilenced: false,
      canModerate: false,
      canDeleteSelf: false,
      canDeleteOthers: false,
    );

    return ChatMessage(
      id: robotId,
      allowChannelWideMentions: false,
      chatable: chatableData,
      chatableId: robotId,
      chatableType: 'direct',
      title: 'LUNIX DO Bot',
      meta: meta,
    );
  }

  @override
  void onInit() {
    super.onInit();
    // 加载聊天列表
    loadChannels();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // 切换深色模式
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  // 设置字体大小
  void setFontSize(double size) {
    fontSize.value = size;
  }

  // 设置主题颜色
  void setThemeColor(int index) {
    themeColorIndex.value = index;
  }

  // 切换消息通知
  void toggleNotification() {
    enableNotification.value = !enableNotification.value;
  }

  // 切换声音
  void toggleSound() {
    enableSound.value = !enableSound.value;
  }

  // 切换震动
  void toggleVibration() {
    enableVibration.value = !enableVibration.value;
  }

  // 清除缓存
  Future<void> clearCache() async {}

  // 加载聊天列表
  Future<void> loadChannels() async {
    try {
      isLoading.value = true;

      final response = await apiService.getChannels();

      _messages.clear();

      _messages.add(_createRobotChatItem());

      _messages.addAll(response.publicChannels ?? []);
      _messages.addAll(response.directMessageChannels ?? []);
    } catch (e, s) {
      l.e('加载聊天列表失败 $e $s');
      showError(e.toString());

      if (_messages.isEmpty || !_messages.any((m) => m.id == robotId)) {
        _messages.clear();
        _messages.add(_createRobotChatItem());
      }
    } finally {
      isLoading.value = false;
      refreshController.refreshCompleted();
    }
  }

  // 搜索变化
  void onSearchChanged(String value) {}

  // 判断是否是机器人聊天
  bool isRobotChat(ChatMessage message) {
    return message.id == robotId;
  }

  // 点击消息
  void onMessageTap(ChatMessage message) async {
    if (message.id == robotId) {
      await Get.toNamed(Routes.ROBOT_CHAT);
      return;
    }

    // 使用 await 等待导航返回结果
    await Get.toNamed(Routes.CHAT_DETAIL, arguments: message);

    // 直接刷新 因为进入后标记已读
    loadChannels();
  }
}
