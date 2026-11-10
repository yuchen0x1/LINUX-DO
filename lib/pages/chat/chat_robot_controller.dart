import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/log.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatRobotController extends BaseController {
  final ApiService apiService = Get.find();
  // 用户信息
  final Rxn<CurrentUser> _user = Rxn<CurrentUser>();

  // 聊天消息列表
  final RxList<types.Message> messages = <types.Message>[].obs;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  // 用户和机器人类型
  late types.User currentUser;
  late types.User robotUser;

  // 输入控制器
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // 机器人思考状态
  final RxBool isThinking = false.obs;

  // 是否显示欢迎提示
  final RxBool showHints = true.obs;

  // 是否隐藏了键盘
  final RxBool isHideKeyboard = false.obs;
  // 建议的问题列表
  final RxList<String> suggestedQuestions = <String>[
    '什么是LINUX DO?',
    '如何在LINUX DO 秀一波 Linux 骚操作',
    'LINUX DO中有什么内容?',
    '怎么在LINUX DO中使用Bot?',
    '什么是白嫖?',
    'LINUX文件权限如何管理?',
    '如何远程连接LINUX服务器?',
    '怎么买便宜的VPS?',
    'SHELL脚本编程基础?',
    'Neo是谁?',
    'LINUX系统优化技巧?'
  ].obs;

  // 存储当前对话的topic_id
  int? _currentTopicId;

  final RxString targetRecipients = 'gpt-4o_bot'.obs;

  // 表情选择器相关
  final RxBool isShowEmojiPicker = false.obs;

  ChatRobotController() {
    _user.value = Get.find<GlobalController>().userInfo?.user;
  }

  @override
  void onInit() {
    super.onInit();
    _initUsers();
    _loadInitialMessages();
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        isShowEmojiPicker.value = false;
        isHideKeyboard.value = false;
      }
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initUsers() {
    // 初始化当前用户
    currentUser = types.User(
      id: _user.value?.id.toString() ?? '0',
      firstName: _user.value?.name,
      lastName: '',
    );

    // 初始化机器人用户
    robotUser = const types.User(
      id: 'robot',
      firstName: 'LINUX DO Bot',
      lastName: '',
    );
  }

  void _loadInitialMessages() {
    // 添加欢迎消息
    final welcomeMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: robotUser,
      text: '您好！我是 Linux DO 的 AI 助手，可以回答您关于 Linux 和开源技术的问题。请问有什么我可以帮您的吗？',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    messages.add(welcomeMessage);
  }

  // 发送消息
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (text.trim().length < 3) {
      showError('问题太短了,请输入至少3个字符');
      return;
    }

    try {
      // 隐藏提示
      showHints.value = false;

      // 创建用户消息
      final userMessage = types.TextMessage(
        id: const Uuid().v4(),
        author: currentUser,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // 添加到消息列表
      messages.add(userMessage);

      // 清空输入框
      inputController.clear();

      // 滚动到底部
      _scroll2Bottom();

      isThinking.value = true;

      // 发送消息到API并获取回复
      final robotReply = await _sendMessageToAPI(text);

      // 添加机器人回复
      messages.add(robotReply);

      _scroll2Bottom();
    } catch (e, s) {
      l.e('发送消息失败: $e\n$s');
      showError('发送失败，请重试');
    } finally {
      isThinking.value = false;
    }
  }

  void _scroll2Bottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 发送消息到API并获取回复
  Future<types.TextMessage> _sendMessageToAPI(String content) async {
    try {
      String aiReply = '';
      const maxRetry = 30;
      if (_currentTopicId == null) {
        // 首次发送消息，创建新的私信主题
        final createResponse = await apiService.createPost(
          title: '[无标题 AI 机器人私信 (App)]',
          content: content,
          unlistTopic: false,
          isWarning: false,
          archetype: 'private_message',
          nestedPost: true,
          targetRecipients: targetRecipients.value,
          aiPersonaId: 8,
        );

        _currentTopicId = createResponse.post.topicId;

        // 等待AI回复
        await Future.delayed(const Duration(seconds: 20));

        TopicDetail? topicDetail;

        for (var i = 0; i < maxRetry; i++) {
          topicDetail = await getRobotReply();
          final posts = topicDetail?.postStream?.posts;
          if (posts == null || posts.isEmpty || posts.length < 2) {
            continue;
          }
          if (posts.last.cooked == null || posts.last.cooked == '') {
            continue;
          }
          aiReply = posts.last.cooked ?? '';
          break;
        }
      }

      /// 继续回复
      else {
        final createResponse = await apiService.createPost(
          content: content,
          topicId: _currentTopicId,
        );

        final nextPistId = createResponse.post.id + 1;

        // 等待AI回复
        await Future.delayed(const Duration(seconds: 20));

        // 添加重试
        for (var i = 0; i < maxRetry; i++) {
          final post = await getContent(nextPistId);
          if (post == null || post.cooked == null || post.cooked == '') {
            continue;
          }

          aiReply = post.cooked ?? '';
          break;
        }
      }

      return types.TextMessage(
        id: const Uuid().v4(),
        author: robotUser,
        text: aiReply,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e, s) {
      l.e('API请求失败: $e\n$s');
      // 返回一个错误信息作为机器人的回复
      return types.TextMessage(
        id: const Uuid().v4(),
        author: robotUser,
        text: '很抱歉，我当前无法回答您的问题。请稍后再试。',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<TopicDetail?> getRobotReply() async {
    await Future.delayed(const Duration(seconds: 5));
    return await apiService.getRobotTopicDetail(_currentTopicId.toString());
  }

  Future<Post?> getContent(int nextPistId) async {
    await Future.delayed(const Duration(seconds: 5));
    return await apiService.getPostContent(nextPistId.toString());
  }

  // 使用建议的问题
  void useSuggestedQuestion(String question) {
    sendMessage(question);
  }

  // 切换表情选择器
  void toggleEmojiPicker() {
    if (isShowEmojiPicker.value) {
      // 关闭表情选择器，显示键盘
      isShowEmojiPicker.value = false;
      isHideKeyboard.value = false;
      FocusScope.of(Get.context!).requestFocus(focusNode);
    } else {
      // 关闭键盘，显示表情选择器
      FocusManager.instance.primaryFocus?.unfocus();
      // 等待键盘动画完成
      Future.delayed(const Duration(milliseconds: 300), () {
        isShowEmojiPicker.value = true;
        isHideKeyboard.value = true;
      });
    }
  }
}
