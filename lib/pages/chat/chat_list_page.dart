import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import '../../const/app_const.dart';
import '../../const/app_images.dart';
import '../../models/chat_message.dart';
import 'chat_list_controller.dart';

class ChatPage extends GetView<ChatListController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(CupertinoIcons.ellipsis_circle_fill,
        //         size: 24.w,
        //         color: Theme.of(context).textTheme.bodyLarge?.color),
        //   ),
        //   6.hGap
        // ],
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Center(
            child: Text(AppConst.chat.title,
                style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
        ),
      ),
      body: Column(
        children: [
          //_buildSearchBar(context),
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    AppConst.chat.noMessages,
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                );
              }

              return DisSmartRefresher(
                controller: controller.refreshController,
                enablePullDown: true,
                enablePullUp: false,
                onRefresh: controller.loadChannels,
                child: ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageItem(context, message);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessage message) {
    // 判断是否是机器人聊天
    final isRobot = controller.isRobotChat(message);

    return InkWell(
      onTap: () => controller.onMessageTap(message),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                if (isRobot)
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19.w),
                      child: Image.asset(
                        AppImages.robot,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 38.w,
                    height: 38.w,
                    child: AvatarWidget(
                      avatarUrl: message.getAvatarUrl(),
                      circle: !message.isWebMaster(),
                      username: message.chatable.users?.first.username ?? '',
                      borderRadius: 4.w,
                      backgroundColor: Theme.of(context).cardColor,
                      borderColor: Theme.of(context).dividerColor,
                    ),
                  ),
                if ((message.chatableType == 'DirectMessage' &&
                        message.chatable.users?.first.status != null) ||
                    isRobot)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isRobot ? Colors.blue : Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            12.hGap,
            // 消息内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (isRobot)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.w),
                                margin: EdgeInsets.only(right: 6.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 10.w,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                isRobot
                                    ? 'LUNIX DO Bot'
                                    : (message.title ?? ''),
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFontFamily.dinPro,
                                  color: isRobot
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (message.lastMessage != null && !isRobot)
                        Text(
                          message.lastMessage!.friendlyTime,
                          style: TextStyle(
                            fontSize: 10.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                    ],
                  ),
                  4.hGap,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isRobot
                              ? '我是LUNIX DO Bot, 随时解答你的问题'
                              : (message.lastMessage?.message ??
                                  message.description ??
                                  ''),
                          style: TextStyle(
                            fontSize: 11.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: isRobot
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: .8)
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 这个未读消息数量没有找到对应的字段,暂时找个占位吧
                      if (message.meta.messageBusLastIds.newMessages > 0 &&
                          !isRobot)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .8),
                            borderRadius: BorderRadius.circular(100.w),
                          ),
                          child: Text(
                            '${message.meta.messageBusLastIds.newMessages}',
                            style: TextStyle(
                              fontSize: 9.w,
                              fontFamily: AppFontFamily.dinPro,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
