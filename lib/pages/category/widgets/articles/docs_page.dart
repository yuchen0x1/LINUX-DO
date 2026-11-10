import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_item.dart';

import '../../../../widgets/dis_refresh.dart';
import '../../../../widgets/state_view.dart';
import 'docs_controller.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage>
    with AutomaticKeepAliveClientMixin {
  late DocsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find(tag: 'docs');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    username: controller.getNickName(topic),
                    onTap: () => controller.toTopicDetail(topic.id),
                    avatarUrls: controller.getAvatarUrls(topic),
                    onDoNotDisturb: (topic) {
                      controller.doNotDisturb(topic.id);
                    },
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
        onRetry: controller.fetchDocs,
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

  @override
  bool get wantKeepAlive => true;
}
