import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controller/global_controller.dart';
import '../../models/chat_detail_message.dart';
import '../../models/chat_message.dart';
import '../../net/api_service.dart';
import '../../utils/log.dart';

import 'dart:async';

import 'package:linux_do/models/user.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import 'chat_list_controller.dart';

class ChatDetailController extends BaseController {
  final ApiService apiService = Get.find();
  late ChatMessage channel = Get.arguments;
  final Rxn<CurrentUser> _user = Rxn<CurrentUser>();
  final isRobotChat = false.obs;

  ChatDetailController() {
    _user.value = Get.find<GlobalController>().userInfo?.user;
  }

  // 输入控制器
  final inputController = TextEditingController();
  final focusNode = FocusNode();

  // 消息列表 - 原始数据
  final RxList<ChatDetailMessage> messages = <ChatDetailMessage>[].obs;

  // flutter_chat_ui 使用的消息列表
  final RxList<types.Message> chatMessages = <types.Message>[].obs;

  // 当前用户 - flutter_chat_ui 格式
  late types.User currentUser;
  late types.User robotUser;

  // 是否可以加载更多历史消息
  bool canLoadMorePast = false;
  // 是否可以加载更多新消息
  bool canLoadMoreFuture = false;

  // 是否正在加载更多
  bool isLoadingMore = false;
  // 防抖计时器
  Timer? _scrollDebounce;

  final refreshController = RefreshController();

  // MessageBus 相关
  Timer? _messageBusTimer;

  // 机器人思考状态
  final robotThinking = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 检查是否是机器人聊天
    isRobotChat.value = channel.id == ChatListController.robotId;

    // 初始化当前用户
    _initCurrentUser();

    // 初始化机器人用户
    _initRobotUser();

    // 加载消息
    if (isRobotChat.value) {
      _loadRobotMessages();
    } else {
      loadMessages();
    }
  }

  void _initCurrentUser() {
    String? avatarUrl;
    if (_user.value?.avatarTemplate != null) {
      final template = _user.value!.avatarTemplate;
      if (template != null) {
        if (template.startsWith('http://') || template.startsWith('https://')) {
          avatarUrl = template;
        } else {
          avatarUrl =
              '${HttpConfig.baseUrl}${template.replaceAll('{size}', '100')}';
        }
      }
    }

    currentUser = types.User(
      id: _user.value?.id.toString() ?? '0',
      firstName: _user.value?.name,
      lastName: '',
      imageUrl: avatarUrl,
    );
  }

  void _initRobotUser() {
    robotUser = const types.User(
      id: 'robot',
      firstName: 'LUNIX DO Bot',
      lastName: '',
      imageUrl: AppImages.robot,
    );
  }

  // 加载机器人消息
  void _loadRobotMessages() {
    isLoading.value = false;

    // 添加欢迎消息
    final welcomeMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: robotUser,
      text: '您好，现在我还无法回答您的问题,因为我还没有开发完成🙂‍↔️',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    chatMessages.add(welcomeMessage);
  }

  @override
  void onClose() {
    inputController.dispose();
    focusNode.dispose();
    _scrollDebounce?.cancel();
    _messageBusTimer?.cancel();
    super.onClose();
  }

  // 发送消息
  Future<void> sendMessage(types.PartialText message) async {
    final content = message.text.trim();
    if (content.isEmpty) return;

    try {
      // 生成一个临时ID
      final messageId = const Uuid().v4();

      // 创建用户消息
      final userChatMessage = types.TextMessage(
        id: messageId,
        author: currentUser,
        text: content,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: types.Status.delivered,
      );

      // 先添加到消息列表
      chatMessages.add(userChatMessage);

      // 清空输入框
      inputController.clear();

      if (isRobotChat.value) {
        // 处理机器人聊天
        await _handleRobotChat(content);
      } else {
        // 正常聊天处理
        await _sendRegularMessage(content, messageId);
      }
    } catch (e, s) {
      l.e('发送消息失败: $e $s');
      showError('发送失败，请重试');
    }
  }

  // 处理机器人聊天
  Future<void> _handleRobotChat(String content) async {
    try {
      robotThinking.value = true;

      await Future.delayed(const Duration(seconds: 2));

      final robotReply = types.TextMessage(
        id: const Uuid().v4(),
        author: robotUser,
        text: _generateRobotResponse(content),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // 添加到消息列表
      chatMessages.add(robotReply);
    } finally {
      robotThinking.value = false;
    }
  }

  String _generateRobotResponse(String userMessage) {
    return '作为 LINUX DO 的 AI 助手，我可以帮助您解答任何问题。只要和Linux 无关即可 😁';
  }

  // 发送普通消息
  Future<void> _sendRegularMessage(String content, String messageId) async {
    try {
      // 生成一个临时ID
      final stagedId = DateTime.now().millisecondsSinceEpoch.toString();

      // 创建一个临时消息对象 - 原始格式
      final tempMessage = ChatDetailMessage(
        id: null, // 服务器会返回真实ID
        message: content,
        cooked: content,
        createdAt: DateTime.now().toIso8601String(),
        channelId: channel.id,
        streaming: false,
        user: ChatMessageUser(
          id: _user.value?.id ?? 0,
          username: _user.value?.username ?? '',
          name: _user.value?.name ?? '',
          avatarTemplate: _user.value?.avatarTemplate ?? '',
        ),
      );

      // 先添加到消息列表
      messages.add(tempMessage);

      // 发送消息到服务器
      final response = await apiService.sendMessage(
        channel.id,
        content,
        stagedId,
      );

      // 如果发送成功，更新消息的状态
      if (response['success'] == 'OK' && response['message_id'] != null) {
        // 标记新发送的消息为已读
        if (response['message_id'] != null) {
          markMessageAsRead(response['message_id']);
        }
      }
    } catch (e, s) {
      l.e('发送消息失败: $e $s');
      showError('发送失败，请重试');

      // 从消息列表中移除失败的消息
      final index = chatMessages.indexWhere((msg) {
        if (msg is types.TextMessage) {
          return msg.text == content;
        }
        return false;
      });
      if (index != -1) {
        final updatedMessage = (chatMessages[index] as types.TextMessage)
            .copyWith(status: types.Status.error);
        chatMessages[index] = updatedMessage;
      }
    }
  }

  // 加载消息
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;

      final response = await apiService.getChannelMessages(
        channel.id,
        pageSize: 50,
        position: 'end',
      );

      messages.clear();
      messages.addAll(response.messages.reversed);

      // 转换为 flutter_chat_ui 格式
      _convertMessages();

      canLoadMorePast = response.meta.canLoadMorePast;
      canLoadMoreFuture = response.meta.canLoadMoreFuture;

      // 标记最后一条消息为已读
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        if (lastMessage.id != null) {
          markMessageAsRead(lastMessage.id!);
        }
      }
    } catch (e, s) {
      l.e('加载消息失败 $e $s');
      showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 标记消息为已读
  Future<void> markMessageAsRead(int messageId) async {
    try {
      // 调用标记已读API
      await apiService.markChannelAsRead(channel.id, messageId);
    } catch (e, s) {
      l.e('标记消息已读失败: $e $s');
    }
  }

  // 转换消息 格式
  void _convertMessages() {
    chatMessages.clear();

    for (final message in messages) {
      String? avatarUrl;
      if (message.user?.avatarTemplate != null) {
        final template = message.user!.avatarTemplate;
        if (template != null) {
          avatarUrl =
              '${HttpConfig.baseUrl}${template.replaceAll('{size}', '100')}';
        }
      }

      final author = types.User(
        id: message.user?.id.toString() ?? '0',
        firstName: message.user?.name,
        lastName: '',
        imageUrl: avatarUrl,
      );

      final isCurrentUser = message.user?.id == _user.value?.id;
      final messageId = message.id?.toString() ?? const Uuid().v4();

      // 处理创建时间
      int createdAt = DateTime.now().millisecondsSinceEpoch;
      if (message.createdAt != null) {
        createdAt = DateTime.parse(message.createdAt!).millisecondsSinceEpoch;
      }

      // 检查是否有上传的图片
      if (message.uploads != null && message.uploads!.isNotEmpty) {
        for (final upload in message.uploads!) {
          String url = '';
          if (upload['url'] != null) {
            url = upload['url'].toString();
          }

          // 创建图片消息
          final imageMessage = types.ImageMessage(
            id: '${messageId}_img_${const Uuid().v4()}',
            author: author,
            name: upload['original_filename']?.toString() ?? 'image',
            size: (upload['filesize'] as int?) ?? 0,
            uri: url,
            createdAt: createdAt,
            status: isCurrentUser ? types.Status.delivered : null,
          );

          chatMessages.add(imageMessage);
        }
      }

      // 如果有文本消息
      if (message.message != null && message.message!.isNotEmpty) {
        final textMessage = types.TextMessage(
          id: messageId,
          author: author,
          text: message.message!,
          createdAt: createdAt,
          status: isCurrentUser ? types.Status.delivered : null,
        );

        chatMessages.add(textMessage);
      }
    }

    // // 按时间排序
    // chatMessages.sort((a, b) {
    //   final aTime = a.createdAt ?? 0;
    //   final bTime = b.createdAt ?? 0;
    //   return aTime.compareTo(bTime);
    // });
  }

  // 加载更多历史消息
  Future<void> loadMorePastMessages() async {
    if (!canLoadMorePast || isLoadingMore) return;

    isLoadingMore = true;

    try {
      if (messages.isEmpty) {
        return;
      }

      final firstMessage = messages.first;

      final response = await apiService.getChannelMessages(
        channel.id,
        targetMessageId: firstMessage.id,
        direction: 'past',
        pageSize: 50,
      );

      if (response.messages.isEmpty) {
        canLoadMorePast = false;
        return;
      }

      // 添加到原始消息列表
      messages.insertAll(0, response.messages.reversed);

      // 转换新消息并插入到列表前部
      _convertAndPrependMessages(response.messages);

      // 强制刷新UI - 重要
      chatMessages.refresh();

      // 使用返回值更新加载状态
      canLoadMorePast = response.meta.canLoadMorePast;
    } catch (e, s) {
      l.e('加载更多历史消息失败: $e $s');
      showError(e.toString());
    } finally {
      isLoadingMore = false;
      refreshController.refreshCompleted();
    }
  }

  // 专门用于处理历史消息的转换和添加
  void _convertAndPrependMessages(List<ChatDetailMessage> newMessages) {
    if (newMessages.isEmpty) {
      l.d('没有新的历史消息需要转换');
      return;
    }

    final newChatMessages = <types.Message>[];

    // 按时间排序 - 确保消息是按时间顺序
    // newMessages.sort((a, b) {
    //   final aTime = a.createdAt != null ? DateTime.parse(a.createdAt!).millisecondsSinceEpoch : 0;
    //   final bTime = b.createdAt != null ? DateTime.parse(b.createdAt!).millisecondsSinceEpoch : 0;
    //   return aTime.compareTo(bTime);
    // });

    for (final message in newMessages.reversed) {
      String? avatarUrl;
      if (message.user?.avatarTemplate != null) {
        final template = message.user!.avatarTemplate;
        if (template != null) {
          avatarUrl =
              '${HttpConfig.baseUrl}${template.replaceAll('{size}', '100')}';
        }
      }

      final author = types.User(
        id: message.user?.id.toString() ?? '0',
        firstName: message.user?.name,
        lastName: '',
        imageUrl: avatarUrl,
      );

      final isCurrentUser = message.user?.id == _user.value?.id;
      final messageId = message.id?.toString() ?? const Uuid().v4();

      // 处理创建时间
      int createdAt = DateTime.now().millisecondsSinceEpoch;
      if (message.createdAt != null) {
        createdAt = DateTime.parse(message.createdAt!).millisecondsSinceEpoch;
      }

      // 检查是否有上传的图片
      if (message.uploads != null && message.uploads!.isNotEmpty) {
        for (final upload in message.uploads!) {
          String url = '';
          if (upload['url'] != null) {
            url = upload['url'].toString();
          }

          // 创建图片消息
          final imageMessage = types.ImageMessage(
            id: '${messageId}_img_${const Uuid().v4()}',
            author: author,
            name: upload['original_filename']?.toString() ?? 'image',
            size: (upload['filesize'] as int?) ?? 0,
            uri: url,
            createdAt: createdAt,
            status: isCurrentUser ? types.Status.delivered : null,
          );

          newChatMessages.add(imageMessage);
        }
      }

      // 如果有文本消息
      if (message.message != null && message.message!.isNotEmpty) {
        final textMessage = types.TextMessage(
          id: messageId,
          author: author,
          text: message.message!,
          createdAt: createdAt,
          status: isCurrentUser ? types.Status.delivered : null,
        );

        newChatMessages.add(textMessage);
      }
    }

    if (newChatMessages.isEmpty) {
      return;
    }

    // 将新消息插入到现有消息列表的前面
    chatMessages.insertAll(0, newChatMessages.reversed);
  }

  void handleImageSelection() async {}

  void handleFileSelection() async {}
}
