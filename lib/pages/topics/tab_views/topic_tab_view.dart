import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/simplified_item.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_item.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/widgets/avatar_widget.dart';

import '../../../widgets/dis_refresh.dart';
import '../../../widgets/state_view.dart';
import 'topic_tab_controller.dart';

class TopicTabView extends StatefulWidget {
  final String path;

  const TopicTabView({Key? key, required this.path}) : super(key: key);

  @override
  State<TopicTabView> createState() => _TopicTabViewState();
}

class _TopicTabViewState extends State<TopicTabView>
    with AutomaticKeepAliveClientMixin {
  late TopicTabController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TopicTabController>(tag: widget.path);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final savedSimplified = StorageManager.getBool(
      AppConst.identifier.simplified,
    );
    return Obx(() {
      final content = DisSmartRefresher(
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoading: controller.loadMore,
        enablePullDown: true,
        enablePullUp: true,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final topic = controller.topics[index];

                  if (savedSimplified == null || savedSimplified == false) {
                    return TopicItem(
                      topic: topic,
                      avatarUrl: controller.getLatestPosterAvatar(topic),
                      nickName: controller.getNickName(topic),
                      username: controller.getUserName(topic),
                      avatarUrls: controller.getAvatarUrls(topic),
                      avatarActions: AvatarActions.openCard,
                      onTap: () {
                        controller.toTopicDetail(topic.id);
                      },
                      onDoNotDisturb: (topic) {
                        controller.doNotDisturb(topic.id);
                      },
                    );
                  }

                  return SimplifiedItem(
                    topic: topic,
                    avatarUrl: controller.getLatestPosterAvatar(topic),
                    username: controller.getUserName(topic),
                    nickName: controller.getNickName(topic),
                    avatarActions: AvatarActions.openCard,
                    toPersonalPage: true,
                  );
                }, childCount: controller.topics.length),
              ),
            ),
          ],
        ),
      );

      return StateView(
        state: _getViewState(),
        errorMessage: controller.errorMessage.value,
        onRetry: controller.fetchTopics,
        child: content,
      );
    });
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    if (controller.topics.isEmpty) {
      return ViewState.empty;
    }
    return ViewState.content;
  }
}
