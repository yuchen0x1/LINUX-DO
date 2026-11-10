import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/group.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/state_view.dart';

import '../../../utils/mixins/toast_mixin.dart';
import 'group_controller.dart';

class GroupPage extends GetView<GroupController> with ToastMixin {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.group.title,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              size: 24.w,
            ),
          ),
        ],
      ),
      body: Obx(() => StateView(
            state: _getViewState(),
            onRetry: controller.fetchGroups,
            child: DisSmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: controller.onRefresh,
              onLoading: controller.loadMore,
              controller: controller.refreshController,
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.groups.length,
                separatorBuilder: (context, index) => 12.vGap,
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return _buildGroupCard(context, group);
                },
              ),
            ),
          )),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.w),
        child: InkWell(
          // onTap: () {
          //   showSuccess('开发中...');
          // },
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (group.flairUrl != null)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: CachedImage(
                          imageUrl: group.flairUrl!,
                          width: 24.w,
                          height: 24.w,
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        group.displayName ?? group.fullName ?? '',
                        style: TextStyle(
                          fontSize: 16.w,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildGroupButton(context, group),
                  ],
                ),
                if (group.bioExcerpt.isNotEmpty) ...[
                  8.vGap,
                  Text(
                    group.bioExcerpt,
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).hintColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                12.vGap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16.w,
                      color: Theme.of(context).hintColor,
                    ),
                    4.hGap,
                    Text(
                      '${group.userCount} ${AppConst.group.members}',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    8.hGap,
                    group.automatic == true
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.w),
                            child: Text(
                              group.automatic == true ? '自动' : '',
                              style: TextStyle(
                                  fontSize: 8.w, color: AppColors.white),
                            ))
                        : const SizedBox.shrink(),
                    const Spacer(),
                    Icon(
                      group.visibilityLevel == 0
                          ? Icons.lock_outline
                          : Icons.public,
                      size: 16.w,
                      color: Theme.of(context).hintColor,
                    ),
                    4.hGap,
                    Text(
                      group.visibilityLevel == 0
                          ? AppConst.group.privateGroup
                          : AppConst.group.publicGroup,
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupButton(BuildContext context, Group group) {
    if (group.publicAdmission == false) {
      return const SizedBox.shrink();
    }

    final isJoined = group.isGroupUser ?? false;
    return TextButton(
      onPressed: () => isJoined
          ? controller.leaveGroup(group.id)
          : controller.joinGroup(group.id),
      style: TextButton.styleFrom(
        backgroundColor:
            isJoined ? Colors.transparent : Theme.of(context).primaryColor,
        foregroundColor:
            isJoined ? Theme.of(context).primaryColor : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
          side: isJoined
              ? BorderSide(color: Theme.of(context).primaryColor)
              : BorderSide.none,
        ),
      ),
      child: Text(
        isJoined ? AppConst.group.leave : AppConst.group.join,
        style: TextStyle(
          fontSize: 14.w,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    if (controller.groups.isEmpty) {
      return ViewState.empty;
    }
    return ViewState.content;
  }
}
