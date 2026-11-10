import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/about.dart';
import 'package:linux_do/utils/device_util.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import 'about_controller.dart';

class AboutPage extends GetView<AboutController> with ToastMixin {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppConst.settings.about,
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: DisRefreshLoading());
        }

        final aboutData = controller.aboutData.value;
        if (aboutData == null) {
          return DisRefresh(onRefresh: controller.refreshData);
        }

        return DisRefresh(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildLogo(context),
                // 16.vGap,
                _buildHeader(context, aboutData.about),

                16.vGap,

                _buildStats(context, aboutData.about.stats),

                16.vGap,

                _buildAdminSection(context, aboutData),

                16.vGap,

                _buildTeamSection(context, aboutData),

                16.vGap,

                _buildWebsiteActivity(context, aboutData),

                16.vGap,

                _buildContactUs(context, aboutData),

                16.vGap,

                _buildVersionInfo(context, aboutData),

                16.vGap,
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, About about) {
    return SizedBox(
      height: 220.w,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.w),
                topRight: Radius.circular(16.w),
              ),
              child: Image.network(
                about.bannerImage,
                height: 100.w,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 100.w,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ).w,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.w),
                  bottomRight: Radius.circular(8.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    about.description,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      height: 1.5,
                    ),
                  ),
                  HtmlWidget(
                    html: about.extendedSiteDescription,
                    fontSize: 11.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, Stats stats) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLable(
                context,
                CupertinoIcons.chart_bar_square,
                AppConst.settings.communityData,
              ),
            ],
          ),
          6.vGap,
          Row(
            children: [
              _buildStatItem(
                context,
                icon: Icons.people_rounded,
                title: AppConst.settings.userActivity,
                value: '${stats.usersCount}',
                subtitle: '今日新增 ${stats.usersLastDay}',
                color: const Color(0xFF4CAF50),
              ),
              Container(
                height: 45.w,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).dividerColor.withValues(alpha: 0),
                      Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      Theme.of(context).dividerColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              _buildStatItem(
                context,
                icon: Icons.forum_rounded,
                title: '话题总数',
                value: '${stats.topicsCount}',
                subtitle: '今日新增 ${stats.topicsLastDay}',
                color: const Color(0xFF2196F3),
              ),
              Container(
                height: 45.w,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).dividerColor.withValues(alpha: 0),
                      Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      Theme.of(context).dividerColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              _buildStatItem(
                context,
                icon: Icons.chat_rounded,
                title: '消息互动',
                value: '${stats.chatMessagesCount}',
                subtitle: '今日新增 ${stats.chatMessagesLastDay}',
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildLable(BuildContext context, IconData icon, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: Theme.of(context).primaryColor),
          6.hGap,
          Text(
            title,
            style: TextStyle(
              fontSize: 12.w,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          // Container(
          //   width: 48.w,
          //   height: 48.w,
          //   decoration: BoxDecoration(
          //     color: color.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(12.w),
          //   ),
          //   child: Icon(
          //     icon,
          //     size: 24.w,
          //     color: color,
          //   ),
          // ),
          // 12.vGap,
          Text(
            controller.formattedNumber(value),
            style: TextStyle(
              fontSize: 24.w,
              fontWeight: FontWeight.w700,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          8.vGap,
          Text(
            title,
            style: TextStyle(
              fontSize: 10.w,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          6.vGap,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.w,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontFamily.dinPro,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, AboutResponse data) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLable(
            context,
            CupertinoIcons.shield_lefthalf_fill,
            AppConst.settings.ourModerators,
          ),
          16.vGap,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.w,
              crossAxisSpacing: 8.w,
              childAspectRatio: 2.4,
            ),
            itemCount: data.about.moderatorIds.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return _buildModeratorCard(
                context,
                data,
                data.about.moderatorIds[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeratorCard(
    BuildContext context,
    AboutResponse data,
    int moderatorId,
  ) {
    final user = data.findUserById(moderatorId);
    final name = user?.name == null || user?.name == ''
        ? user?.username ?? ''
        : user?.name ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8).w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4).w,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8.w,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 头像
          Row(
            children: [
              AvatarWidget(
                avatarUrl: user?.avatarUrl ?? '',
                size: 36.w,
                username: user?.username ?? '',
                circle: user?.id != 1,
                borderColor: Theme.of(context).primaryColor,
              ),
              6.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: name.length > 12 ? 10.w : 12.w,
                        fontFamily: AppFontFamily.dinPro,
                        fontWeight: user?.id != 1
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: user?.id != 1
                            ? Theme.of(context).textTheme.titleMedium?.color
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      user?.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.w,
                        fontFamily: AppFontFamily.dinPro,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, AboutResponse data) {
    final user = data.findUserById(1);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLable(
            context,
            CupertinoIcons.person_fill,
            AppConst.settings.ourAdmin,
          ),
          12.vGap,
          Row(
            children: [
              AvatarWidget(
                avatarUrl: data.avatarUrl,
                circle: false,
                username: user?.username ?? '',
                borderColor: Theme.of(context).primaryColor,
              ),
              12.hGap,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '',
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
                  4.vGap,
                  Text(
                    user?.title ?? '',
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteActivity(BuildContext context, AboutResponse aboutData) {
    final stats = aboutData.about.stats;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLable(
            context,
            CupertinoIcons.square_favorites_alt_fill,
            AppConst.settings.websiteActivity,
          ),
          16.vGap,

          // 用户活跃
          Text(
            AppConst.settings.userActivity,
            style: TextStyle(
              fontSize: 11.w,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          8.vGap,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              _buildActivityTag(
                context,
                '日活跃用户',
                '${stats.activeUsersLastDay}',
                const Color(0xFF4CAF50),
              ),
              _buildActivityTag(
                context,
                '周活跃用户',
                '${stats.activeUsers7Days}',
                const Color(0xFF2196F3),
              ),
              _buildActivityTag(
                context,
                '月活跃用户',
                '${stats.activeUsers30Days}',
                const Color(0xFF9C27B0),
              ),
            ],
          ),

          16.vGap,
          // 内容创作
          Text(
            AppConst.settings.contentCreation,
            style: TextStyle(
              fontSize: 11.w,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          8.vGap,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              _buildActivityTag(
                context,
                '今日发帖',
                '${stats.postsLastDay}',
                const Color(0xFFFF9800),
              ),
              _buildActivityTag(
                context,
                '周发帖量',
                '${stats.posts7Days}',
                const Color(0xFF00BCD4),
              ),
              _buildActivityTag(
                context,
                '月发帖量',
                '${stats.posts30Days}',
                const Color(0xFF673AB7),
              ),
            ],
          ),

          16.vGap,
          // 互动数据
          Text(
            AppConst.settings.interactionData,
            style: TextStyle(
              fontSize: 11.w,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          8.vGap,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              _buildActivityTag(
                context,
                '今日点赞',
                '${stats.likesLastDay}',
                const Color(0xFFE91E63),
              ),
              _buildActivityTag(
                context,
                '周点赞量',
                '${stats.likes7Days}',
                const Color(0xFF795548),
              ),
              _buildActivityTag(
                context,
                '总点赞量',
                '${stats.likesCount}',
                const Color(0xFF607D8B),
              ),
            ],
          ),

          16.vGap,
          // 聊天数据
          Text(
            AppConst.settings.chatData,
            style: TextStyle(
              fontSize: 11.w,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          8.vGap,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              _buildActivityTag(
                context,
                '今日消息',
                '${stats.chatMessagesLastDay}',
                const Color(0xFF3F51B5),
              ),
              _buildActivityTag(
                context,
                '活跃频道',
                '${stats.chatChannelsLastDay}',
                const Color(0xFF009688),
              ),
              _buildActivityTag(
                context,
                '聊天用户',
                '${stats.chatUsersLastDay}',
                const Color(0xFFFF5722),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTag(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.w, color: color),
          ),
          4.hGap,
          Text(
            controller.formattedNumber(value),
            style: TextStyle(
              fontSize: 10.w,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontFamily.dinPro,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUs(BuildContext context, AboutResponse data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLable(
            context,
            CupertinoIcons.chat_bubble_text_fill,
            AppConst.settings.contactUs,
          ),
          16.vGap,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 20.w,
                    color: AppColors.error,
                  ),
                ),
                12.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConst.settings.emergencyIssues,
                        style: TextStyle(
                          fontSize: 13.w,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      4.vGap,
                      Text(
                        AppConst.settings.contactForCriticalIssues,
                        style: TextStyle(
                          fontSize: 10.w,
                          color: AppColors.error.withValues(alpha: 0.8),
                        ),
                      ),
                      4.vGap,
                      // 添加下划线
                      Text(
                        data.about.contactEmail,
                        style: TextStyle(
                          fontSize: 12.w,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFontFamily.dinPro,
                          color: AppColors.error,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          16.vGap,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Icon(
                    CupertinoIcons.shield_fill,
                    size: 20.w,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                12.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConst.settings.inappropriateContentReport,
                        style: TextStyle(
                          fontSize: 13.w,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      4.vGap,
                      Text(
                        AppConst.settings.reportInappropriateContent,
                        style: TextStyle(
                          fontSize: 10.w,
                          height: 1.5,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context, AboutResponse aboutData) {
    return GestureDetector(
      onLongPress: () {
        showInputDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.w),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLable(
              context,
              CupertinoIcons.info_circle_fill,
              AppConst.settings.versionInfo,
            ),
            16.vGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConst.settings.webVersion,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                Text(
                  aboutData.about.version,
                  style: TextStyle(
                    fontSize: 12.w,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontFamily.dinPro,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            12.vGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConst.settings.appVersion,
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Text(
                    '${DeviceUtil.version} + ${DeviceUtil.buildNumber}',
                    style: TextStyle(
                      fontSize: 10.w,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showInputDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6).w,
              ),
              title: Text(
                '请输入密码',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.w),
              ),
              content: SizedBox(
                height: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '该功能为测试功能，输入密码后,下次进入话题详情,会自动滚动刷帖子阅读数量,帖子阅读数目前测试只有在模拟器上生效,重启app后失效(如果打开后未登录,则先登录即可)',
                      style: TextStyle(
                        fontSize: 10.w,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    16.vGap,
                    Expanded(
                      child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: '请输入密码',
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(top: 12).w,
                          prefixIcon: Icon(
                            CupertinoIcons.lock_fill,
                            color: Theme.of(context).primaryColor,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  height: 32.w,
                  child: DisButton(
                    onPressed: () {
                      if (passwordController.text == 'linux.do') {
                        Get.find<GlobalController>().setShowHiddenContent(true);
                        showSuccess('已开启');
                      } else {
                        showError('密码错误');
                      }
                      Get.back();
                    },
                    text: '确定',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
