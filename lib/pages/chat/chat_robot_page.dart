import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_emoji_picker.dart';
import 'package:linux_do/widgets/dis_text_field.dart';
import 'package:linux_do/widgets/emoji_text.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';

import 'chat_robot_controller.dart';

class ChatRobotPage extends GetView<ChatRobotController> with Concatenated {
  const ChatRobotPage({Key? key}) : super(key: key);

  final List<String> modelTypes = const [
    'gpt_4.1_bot',
    'gpt-4.1_mini_bot',
    'gpt_4.1_nano_bot',
    'gpt-4o_bot',
    'gpt_4o_mini_bot',
    'o1_bot',
    'o1_mini_bot',
    'o3_mini_bot',
    'o4_mini_bot',
    'anthropic_claude-3.1',
    'anthropic_claude-3.5',
    'deepseek_deepseek-r1',
    'deepseek_deepseek-ch',
    'google_gemini-2.0-fl',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool? dialogResult = await _showHintDialog(context);
        if (dialogResult == true) {
          Get.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'LINUX DO Bot',
            style: TextStyle(fontSize: 14.w, fontFamily: AppFontFamily.dinPro),
          ),
          centerTitle: true,
          actions: [
            Container(
              height: 30.w,
              margin: const EdgeInsets.only(right: 16).w,
              padding: const EdgeInsets.symmetric(horizontal: 8).w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.w),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Obx(
                () => DropdownButton<String>(
                  value: controller.targetRecipients.value,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontFamily: AppFontFamily.dinPro,
                  ),
                  dropdownColor: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12).w,
                  menuMaxHeight: 200.w,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.targetRecipients.value = newValue;
                    }
                  },
                  items: modelTypes.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8).w,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11.w,
                            fontFamily: AppFontFamily.dinPro,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 聊天消息区域
            Expanded(child: Obx(() => _buildMessagesArea(context))),

            // 思考状态指示器
            Obx(() {
              if (controller.isThinking.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ).w,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      8.hGap,
                      Text(
                        'Bot 正在思考...',
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            // 提示问题区域
            // Obx(() {
            //   if (controller.showHints.value) {
            //     return _buildSuggestedQuestions(context);
            //   } else {
            //     return const SizedBox.shrink();
            //   }
            // }),

            // 输入区域
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  // 构建消息区域
  Widget _buildMessagesArea(BuildContext context) {
    if (controller.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60.w,
              color: Theme.of(context).primaryColor.withValues(alpha: .5),
            ),
            16.vGap,
            Text(
              '开始和 Linux DO Bot 对话吧！',
              style: TextStyle(
                fontSize: 16.w,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // 消息列表
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).w,
      itemCount: controller.messages.length,
      reverse: false,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final isRobot = message.author.id == 'robot';

        return _buildMessageItem(context, message, isRobot);
      },
    );
  }

  // 构建单个消息项
  Widget _buildMessageItem(
    BuildContext context,
    dynamic message,
    bool isRobot,
  ) {
    final messageText = message.text as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8).w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isRobot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isRobot) _buildRobotAvatar(context),
          if (isRobot) 8.hGap,
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 0.75.sw),
              padding: const EdgeInsets.all(12).w,
              decoration: BoxDecoration(
                color: isRobot
                    ? Theme.of(context).cardColor
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16).w.copyWith(
                  bottomLeft: isRobot ? const Radius.circular(0) : null,
                  bottomRight: !isRobot ? const Radius.circular(0) : null,
                ),
              ),
              child: isRobot
                  ? HtmlWidget(html: messageText, fontSize: 13)
                  : EmojiText(
                      messageText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.w,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (!isRobot) 8.hGap,
          if (!isRobot) _buildUserAvatar(context),
        ],
      ),
    );
  }

  // 构建机器人头像
  Widget _buildRobotAvatar(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.w),
        child: Image.asset(AppImages.robot, width: 24.w, height: 24.w),
      ),
    );
  }

  // 构建用户头像
  Widget _buildUserAvatar(BuildContext context) {
    final avatarUrl = Get.find<GlobalController>().userInfo?.user?.avatarUrl;
    return AvatarWidget(
      avatarUrl: avatarUrl ?? '',
      username: Get.find<GlobalController>().userInfo?.user?.username ?? '',
      circle: true,
      size: 36.w,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .2),
      borderRadius: 18.w,
      borderColor: Theme.of(context).primaryColor,
    );
  }

  // 构建输入区域
  Widget _buildInputArea(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 10, 10).w,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 输入框
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24.w),
                    border: Border.all(color: Theme.of(context).cardColor),
                  ),
                  child: Row(
                    children: [
                      Obx(() {
                        return IconButton(
                          icon: Icon(
                            controller.isShowEmojiPicker.value
                                ? CupertinoIcons.keyboard
                                : CupertinoIcons.smiley,
                            color: Theme.of(context).primaryColor,
                            size: 32.w,
                          ),
                          onPressed: () {
                            controller.toggleEmojiPicker();
                          },
                        );
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6, left: 3).w,
                          child: DisTextField(
                            controller: controller.inputController,
                            value: controller.inputController.text,
                            // onChanged: (text) {
                            //   controller.inputController.text = text;
                            // },
                            focusNode: controller.focusNode,
                            maxLines: 1,
                            hintText: '输入问题...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                            onSubmitted: (text) async {
                              if (text.isNotEmpty) {
                                await controller.sendMessage(text);
                                controller.inputController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 发送按钮
              8.hGap,
              InkWell(
                onTap: () async {
                  final text = controller.inputController.text;
                  if (text.isNotEmpty) {
                    await controller.sendMessage(text);
                    controller.inputController.clear();
                  }
                },
                borderRadius: BorderRadius.circular(24.w),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.paperplane,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          return Offstage(
            offstage: !controller.isShowEmojiPicker.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: DisEmojiPicker(
                height: 320.w,
                textEditingController: controller.inputController,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<bool?> _showHintDialog(BuildContext context) async {
    if (StorageManager.getBool(AppConst.identifier.chatHintDontShow) ?? false) {
      return true;
    }

    final result = await Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20.w),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '提示',
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '本页面的内容不会保存\n您可以在"我的->消息"中查看历史对话',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: DisButton(
                          text: '不在提醒',
                          type: ButtonType.outline,
                          onPressed: () async {
                            await StorageManager.setData(
                              AppConst.identifier.chatHintDontShow,
                              true,
                            );
                            Get.back(result: false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DisButton(
                          text: '确定',
                          onPressed: () async {
                            Get.back(result: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
    );

    return result;
  }
}
