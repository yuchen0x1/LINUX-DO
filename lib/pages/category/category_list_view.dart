import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/pages/category/category_list_controller.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_item.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/state_view.dart';

class CategoryListView extends GetView<CategoryListController> {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  return TopicItem(
                    topic: topic,
                    avatarUrl: controller.getLatestPosterAvatar(topic),
                    nickName: controller.getNickName(topic),
                    username: controller.getUserName(topic),
                    avatarUrls: controller.getAvatarUrls(topic),
                    onTap: () => controller.toTopicDetail(topic.id),
                    onDoNotDisturb: (topic) =>
                        controller.doNotDisturb(topic.id),
                    onDelete: (topic) => controller.deleteTopic(topic.id),
                    avatarActions: AvatarActions.openCard,
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
