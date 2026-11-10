import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/expandable.dart';
import 'package:linux_do/widgets/video_player_widget.dart';
import 'dart:ui';
import '../cached_image.dart';
import '../image_preview_dialog.dart';
import '../code_preview_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 自定义PageStorageBucket，用于防止滚动位置恢复错误
// type 'ItemPosition' is not a subtype of type 'double?' in type cast ???????????????
// https://github.com/railson-ferreira/scrollable_list_tab_scroller/issues/16
class CustomPageStorageBucket extends PageStorageBucket {
  @override
  dynamic readState(BuildContext context, {Object? identifier}) {
    // 避免读取ItemPosition类型的状态和double类型不兼容
    return null;
  }
}

class HtmlWidget extends GetView<HtmlController> with ToastMixin {
  final String html;
  final Function(String?)? onLinkTap;
  final double? fontSize;
  final Widget Function(dom.Element)? customWidgetBuilder;
  final GlobalKey anchorKey = GlobalKey();
  final horizontalController = ScrollController();
  final verticalController = ScrollController();
  final CustomPageStorageBucket _storageBucket = CustomPageStorageBucket();
  final TopicDetailController? topicDetailController;
  final List<Polls>? polls;

  HtmlWidget({
    super.key,
    required this.html,
    this.onLinkTap,
    this.fontSize,
    this.customWidgetBuilder,
    this.topicDetailController,
    this.polls,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageStorage(
      bucket: _storageBucket,
      child: SelectionArea(
        child: Html(
          anchorKey: anchorKey,
          data: html,
          style: {
            "body": Style(
              fontSize: FontSize(fontSize ?? 14.sp),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: AppFontFamily.dinPro,
            ),
            "a": Style(
              color: theme.primaryColor,
              textDecoration: TextDecoration.none,
              fontFamily: AppFontFamily.dinPro,
            ),
            "img": Style(
              width: Width(100, Unit.percent),
              height: Height.auto(),
              margin: Margins.only(top: 8.h, bottom: 8.h),
              padding: HtmlPaddings.zero,
              display: Display.block,
            ),
            "p": Style(
              margin: Margins.only(top: 8.h, bottom: 8.h),
              padding: HtmlPaddings.zero,
              fontSize: FontSize(fontSize ?? 14.sp),
              lineHeight: LineHeight.number(1.5),
              fontFamily: AppFontFamily.dinPro,
            ),
            "img.emoji": Style(
              width: Width(16.sp),
              height: Height(16.sp),
              margin: Margins.only(left: 2.sp, right: 2.sp),
              verticalAlign: VerticalAlign.middle,
              display: Display.inlineBlock,
            ),
            // 代码块样式
            "pre": Style(
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              padding: HtmlPaddings.all(12.w),
              margin: Margins.symmetric(vertical: 8.h),
              fontFamily: AppFontFamily.dinPro,
            ),
            "code": Style(
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0),
              padding: HtmlPaddings.symmetric(horizontal: 4.w, vertical: 2.h),
              fontFamily: AppFontFamily.dinPro,
              fontSize: FontSize(13.sp),
              color: Theme.of(context).primaryColor,
            ),
            // 引用样式
            "blockquote": Style(
              margin: Margins.symmetric(vertical: 8.h),
              padding: HtmlPaddings.only(left: 12.w),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  width: 4.w,
                ),
              ),
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.05),
            ),
            // 标题样式
            "h1": Style(
              fontSize: FontSize(24.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16.h, bottom: 8.h),
              lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
            ),
            "h2": Style(
              fontSize: FontSize(20.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16.h, bottom: 8.h),
              lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
            ),
            "h3": Style(
              fontSize: FontSize(18.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 16.h, bottom: 8.h),
              lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
            ),
            // 加粗和强调
            "strong": Style(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: AppFontFamily.dinPro,
            ),
            "em": Style(
              fontStyle: FontStyle.italic,
              fontFamily: AppFontFamily.dinPro,
            ),
            // 列表样式
            "ul": Style(
              margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
              padding: HtmlPaddings.only(left: 16.w),
              listStyleType: ListStyleType.disc,
              fontFamily: AppFontFamily.dinPro,
            ),
            "ol": Style(
              margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
              padding: HtmlPaddings.only(left: 16.w),
              listStyleType: ListStyleType.decimal,
              fontFamily: AppFontFamily.dinPro,
            ),
            "li": Style(
              margin: Margins.only(bottom: 4.h),
              fontFamily: AppFontFamily.dinPro,
            ),
            // 表格样式
            "table": Style(
              width: Width(100, Unit.percent),
              fontFamily: AppFontFamily.dinPro,
            ),
            "th": Style(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
            "td": Style(
              padding: HtmlPaddings.all(8.w),
              fontFamily: AppFontFamily.dinPro,
            ),
          },
          extensions: [
            // 添加图片扩展
            _imageExtension(context, theme),

            // 添加div的扩展
            _divExtension(context, theme),

            // 添加处理 iframe 的扩展
            _iframeExtension(context),

            // 添加代码块扩展
            _codeExtension(context),

            // 添加处理用户提及的扩展
            _mentionExtension(context, theme),

            // 添加表格扩展
            const TableHtmlExtension(),

            // 添加链接预览扩展
            // _linkPreviewExtension(context, theme),

            // 添加aside扩展
            _asideExtension(context, theme),

            // 添加hr扩展
            _hrExtension(context, theme),
          ],
          onLinkTap: (url, _, __) {
            if (url == null) return;

            if (url.startsWith('/u/')) {
              final username = url.split('/').last;
              _showUserCard(username);
            } else {
              if (onLinkTap != null) {
                onLinkTap!(url);
              } else {
                Get.toNamed(Routes.WEBVIEW, arguments: url);
              }
            }
          },
        ),
      ),
    );
  }

  void _showUserCard(String username) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: UserInfoCard(toPersonalPage: false, username: username),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  TagExtension _hrExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"hr"},
      builder: (extensionContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10).w,
          child: Divider(height: 1, color: theme.dividerColor),
        );
      },
    );
  }

  TagExtension _asideExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"aside"},
      builder: (extensionContext) {
        // 处理 GitHub 仓库的 onebox
        if (extensionContext.classes.contains('githubrepo') &&
            extensionContext.classes.contains('onebox')) {
          final header = extensionContext.element
              ?.getElementsByClassName('source')
              .firstOrNull;
          final link = header?.getElementsByTagName('a').firstOrNull;
          final href = link?.attributes['href'];
          final sourceText = link?.text ?? '';

          final article = extensionContext.element
              ?.getElementsByClassName('onebox-body')
              .firstOrNull;
          final githubRow = article
              ?.getElementsByClassName('github-row')
              .firstOrNull;

          // 获取缩略图
          final thumbnailImg = githubRow
              ?.getElementsByTagName('img')
              .firstOrNull;
          final thumbnailSrc = thumbnailImg?.attributes['src'];

          // 获取标题
          final titleElement = githubRow
              ?.getElementsByTagName('h3')
              .firstOrNull;
          final titleLink = titleElement?.getElementsByTagName('a').firstOrNull;
          final titleText = titleLink?.text ?? '';

          // 获取描述
          final descSpan = githubRow
              ?.getElementsByClassName('github-repo-description')
              .firstOrNull;
          final descriptionText = descSpan?.text ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(color: theme.dividerColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onLinkTap?.call(href),
                borderRadius: BorderRadius.circular(12).w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 仓库图片（如果可用）
                    if (thumbnailSrc != null && thumbnailSrc.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12).w,
                          topRight: const Radius.circular(12).w,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 180.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: CachedImage(
                            imageUrl: thumbnailSrc,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              child: Center(child: DisRefreshLoading()),
                            ),
                            errorWidget: Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40.w,
                                  color: theme.iconTheme.color?.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(12).w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // github 来源
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.link,
                                size: 14.w,
                                color: theme.primaryColor,
                              ),
                              4.hGap,
                              Text(
                                sourceText,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFontFamily.dinPro,
                                ),
                              ),
                            ],
                          ),
                          8.vGap,

                          // 仓库标题
                          Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontFamily.dinPro,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          8.vGap,

                          // 仓库描述
                          if (descriptionText.isNotEmpty)
                            Text(
                              descriptionText,
                              style: TextStyle(
                                fontSize: 13.w,
                                fontFamily: AppFontFamily.dinPro,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 处理通用的 onebox
        if (extensionContext.classes.contains('allowlistedgeneric') &&
            extensionContext.classes.contains('onebox')) {
          final header = extensionContext.element
              ?.getElementsByClassName('source')
              .firstOrNull;
          final article = extensionContext.element
              ?.getElementsByClassName('onebox-body')
              .firstOrNull;
          final title = article?.getElementsByTagName('h3').firstOrNull;
          final description = article?.getElementsByTagName('p').firstOrNull;
          final link = header?.getElementsByTagName('a').firstOrNull;
          final href = link?.attributes['href'];
          final sourceText = link?.text ?? '';
          final titleText = title?.text ?? '';
          final descriptionText = description?.text ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(color: theme.dividerColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onLinkTap?.call(href),
                borderRadius: BorderRadius.circular(12).w,
                child: Padding(
                  padding: const EdgeInsets.all(12).w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 来源链接
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.link,
                            size: fontSize ?? 11.w,
                            color: theme.primaryColor,
                          ),
                          4.hGap,
                          Text(
                            sourceText,
                            style: TextStyle(
                              fontSize: 12.w,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                          ),
                        ],
                      ),
                      8.vGap,
                      // 标题
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 13.w,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFontFamily.dinPro,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.vGap,
                      // 描述
                      if (descriptionText.isNotEmpty)
                        Text(
                          descriptionText,
                          style: TextStyle(
                            fontSize: 12.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Handle quoted content
        final titleDiv = extensionContext.element
            ?.getElementsByClassName('title')
            .firstOrNull;
        final username = extensionContext.element?.attributes['data-username'];
        final postId = extensionContext.element?.attributes['data-post'];
        final topicId = extensionContext.element?.attributes['data-topic'];
        final avatarImg = titleDiv?.getElementsByTagName('img').firstOrNull;
        final avatarSrc = avatarImg?.attributes['src'];
        final content =
            extensionContext.element
                ?.getElementsByTagName('blockquote')
                .firstOrNull
                ?.innerHtml ??
            '';

        return ExpandableNotifier(
          child: ScrollOnExpand(
            child: Column(
              children: [
                ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToExpand: true,
                    tapBodyToCollapse: true,
                    hasIcon: false,
                  ),
                  onExpanded: (expanded) {
                    if (expanded) {
                      controller.loadLinkRow(
                        int.parse(topicId ?? '0'),
                        int.parse(postId ?? '0'),
                      );
                    }
                  },
                  header: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ).w,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 4.w,
                                ),
                              ),
                              color: theme.primaryColor.withValues(alpha: 0.05),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 引用头部
                                if (username != null)
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    child: Row(
                                      children: [
                                        if (avatarSrc != null)
                                          AvatarWidget(
                                            avatarUrl: avatarSrc,
                                            size: 24.w,
                                            circle: true,
                                          ),
                                        8.hGap,
                                        GestureDetector(
                                          onTap: () => _showUserCard(username),
                                          child: Text(
                                            username,
                                            style: TextStyle(
                                              fontSize: 10.w,
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (postId != null) ...[
                                          4.hGap,
                                          Text(
                                            '#$postId',
                                            style: TextStyle(
                                              fontSize: 10.w,
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),

                                        ExpandableIcon(
                                          theme: ExpandableThemeData(
                                            expandIcon: CupertinoIcons
                                                .arrow_down_circle_fill,
                                            collapseIcon: CupertinoIcons
                                                .arrow_up_circle_fill,
                                            iconColor: theme.primaryColor,
                                            iconSize: 14.w,
                                            iconRotationAngle: pi / 2,
                                            iconPadding: const EdgeInsets.only(
                                              right: 5,
                                            ),
                                            hasIcon: false,
                                          ),
                                        ),
                                        // 跳转按钮
                                        if (topicId != null && postId != null)
                                          GestureDetector(
                                            onTap: () {
                                              if (topicDetailController !=
                                                  null) {
                                                topicDetailController!
                                                    .scrollToPost(
                                                      int.parse(postId),
                                                    );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 3.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4.w),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .arrow_up_arrow_down_circle_fill,
                                                    size: 14.w,
                                                    color: theme.primaryColor,
                                                  ),
                                                  4.hGap,
                                                  Text(
                                                    '跳转原贴',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: theme.primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ).w,
                                  child: HtmlWidget(
                                    html: content,
                                    onLinkTap: onLinkTap,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  collapsed: Container(),
                  expanded: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10).w,
                          child: Obx(() {
                            final quotedContent = controller.getQuotedContent(
                              int.parse(topicId ?? '0'),
                              int.parse(postId ?? '0'),
                            );

                            // 如果有引用内容，检查并高亮匹配部分
                            String highlightedContent = quotedContent ?? '';
                            if (quotedContent != null && content.isNotEmpty) {
                              // 移除HTML标签以进行纯文本比较
                              final plainContent = content
                                  .replaceAll(RegExp(r'<[^>]*>'), '')
                                  .trim();
                              final plainQuoted = quotedContent
                                  .replaceAll(RegExp(r'<[^>]*>'), '')
                                  .trim();

                              if (plainQuoted.contains(plainContent)) {
                                // 在原始HTML中查找并高亮匹配部分
                                final contentWithoutTags = content
                                    .replaceAll(RegExp(r'<[^>]*>'), '')
                                    .trim();
                                // ignore: deprecated_member_use
                                final color =
                                    // ignore: deprecated_member_use
                                    '#${theme.primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                                highlightedContent = quotedContent.replaceAll(
                                  contentWithoutTags,
                                  '<span style="color: $color">$contentWithoutTags</span>',
                                );
                              }
                            }

                            return HtmlWidget(
                              html: highlightedContent,
                              onLinkTap: onLinkTap,
                              fontSize: fontSize,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TagExtension _divExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"div"},
      builder: (extensionContext) {
        if (extensionContext.classes.contains('spoiler')) {
          final innerHtml = extensionContext.element?.innerHtml ?? '';

          // 每一个div都对应一个状态 无法维护在controller
          bool revealed = false;
          return StatefulBuilder(
            builder: (context, setState) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                child: revealed
                    ? HtmlWidget(
                        html: innerHtml,
                        onLinkTap: onLinkTap,
                        fontSize: fontSize,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8).w,
                        child: Stack(
                          children: [
                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 6,
                                sigmaY: 6,
                              ),
                              child: HtmlWidget(
                                html: innerHtml,
                                onLinkTap: onLinkTap,
                                fontSize: fontSize,
                              ),
                            ),
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    revealed = !revealed;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          );
        }

        // 如果是 lightbox-wrapper，只返回其中的图片内容
        if (extensionContext.classes.contains('lightbox-wrapper')) {
          final imgElement = extensionContext.element
              ?.getElementsByTagName('img')
              .firstOrNull;
          if (imgElement != null) {
            final imgSrc = imgElement.attributes['src'];
            if (imgSrc != null) {
              // 处理相对路径，添加域名前缀
              final src = imgSrc.startsWith('/')
                  ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$imgSrc'
                  : imgSrc;

              // 获取原始图片URL用于预览
              String previewUrl = src;
              // 尝试从 lightbox 链接获取原始图片 URL
              final lightboxElement = extensionContext.element
                  ?.getElementsByClassName('lightbox')
                  .firstOrNull;
              final originalUrlAttr = lightboxElement?.attributes['href'];
              if (originalUrlAttr != null) {
                final originalUrl = originalUrlAttr.startsWith('/')
                    ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$originalUrlAttr'
                    : originalUrlAttr;
                previewUrl = originalUrl;
              }

              return GestureDetector(
                onTap: () => showImagePreview(context, previewUrl),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(color: theme.dividerColor, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: CachedImage(
                      imageUrl: src,
                      width: double.infinity,
                      placeholder: Container(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        child: Center(child: DisRefreshLoading()),
                      ),
                      errorWidget: Icon(
                        Icons.broken_image_outlined,
                        size: 40.w,
                        color: theme.iconTheme.color?.withValues(alpha: .5),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }
        // 如果是 meta div，不显示
        if (extensionContext.classes.contains('meta')) {
          return const SizedBox();
        }

        if (extensionContext.element?.className == 'md-table') {
          final tableElement = extensionContext.element
              ?.getElementsByTagName('table')
              .firstOrNull;
          if (tableElement != null) {
            final tableHtml = tableElement.outerHtml;
            // 修复表格 HTML，移除嵌套的 p 标签和处理列表元素
            final fixedTableHtml = _fixTableHtml(tableHtml);

            // 使用特殊的表格渲染实现，完全避免与ItemPosition相关的错误
            return StatefulBuilder(
              builder: (context, setState) {
                // 使用StatefulBuilder但不保存状态，避免恢复滚动位置
                // 每次重建时创建新的ScrollController，避免恢复之前的滚动位置
                final horizontalScrollCtrl = ScrollController();
                final verticalScrollCtrl = ScrollController();
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .7,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          // 拦截滚动通知，避免触发滚动位置恢复
                          onNotification: (notification) => true,
                          child: SingleChildScrollView(
                            controller: horizontalScrollCtrl,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 2,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                controller: verticalScrollCtrl,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height * 2,
                                  ),
                                  child: Html(
                                    data: fixedTableHtml,
                                    style: {
                                      "table": Style(
                                        backgroundColor: theme.cardColor,
                                      ),
                                      "th": Style(
                                        padding: HtmlPaddings.all(8.w),
                                        backgroundColor: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        fontWeight: FontWeight.bold,
                                        textAlign: TextAlign.center,
                                      ),
                                      "td": Style(
                                        padding: HtmlPaddings.all(8.w),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                          width: .5,
                                        ),
                                      ),
                                    },
                                    extensions: const [TableHtmlExtension()],
                                    onLinkTap: (url, _, __) {
                                      if (onLinkTap != null) {
                                        onLinkTap!(url);
                                      } else {
                                        Get.toNamed(
                                          Routes.WEBVIEW,
                                          arguments: url,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 添加横屏查看按钮
                      const Divider(height: 1),
                      SizedBox(
                        height: 40.h,
                        child: TextButton.icon(
                          onPressed: () =>
                              _showFullScreenDialog(context, fixedTableHtml),
                          icon: Icon(
                            Icons.fullscreen,
                            size: 18.w,
                            color: theme.primaryColor,
                          ),
                          label: Text(
                            '预览',
                            style: TextStyle(
                              fontSize: 14.w,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }

        if (extensionContext.classes.contains('policy')) {
          final acceptText = extensionContext.attributes['data-accept'] ?? '接受';
          final revokeText = extensionContext.attributes['data-revoke'] ?? '拒绝';
          final innerHtml = extensionContext.element?.innerHtml ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8).w,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(html: innerHtml),

                // 按钮区域
                6.vGap,
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => DisButton(
                      text: controller.isPolicyAccepted.value
                          ? revokeText
                          : acceptText,
                      onPressed: () {
                        controller.updatePolicyAccepted();
                      },
                      loading: controller.isLoading.value,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 检查是否包含视频相关的类名
        final classNames = extensionContext.classes;
        final isVideoBox =
            classNames.contains('onebox') &&
            classNames.contains('video-onebox');
        final isVideoOnebox =
            classNames.contains('onebox') &&
            extensionContext.element?.outerHtml.contains('<video') == true;

        if (isVideoBox || isVideoOnebox) {
          // 获取视频元素
          final videoElement = extensionContext.element
              ?.getElementsByTagName('video')
              .firstOrNull;

          if (videoElement != null) {
            // 获取视频源
            final sourceElement = videoElement
                .getElementsByTagName('source')
                .firstOrNull;

            final videoUrl = sourceElement?.attributes['src'];

            if (videoUrl != null && videoUrl.isNotEmpty) {
              return VideoPlayerWidget(videoUrl: videoUrl);
            } else {
              // 尝试从a标签获取视频URL
              final aElement = videoElement
                  .getElementsByTagName('a')
                  .firstOrNull;

              final linkUrl = aElement?.attributes['href'];

              if (linkUrl != null && linkUrl.isNotEmpty) {
                return VideoPlayerWidget(videoUrl: linkUrl);
              } else {
                l.e('No video URL found in either source or a tag');
              }
            }
          } else {
            // 如果没有找到video元素，尝试直接从div中的a标签获取URL
            final aElement = extensionContext.element
                ?.getElementsByTagName('a')
                .firstOrNull;
            if (aElement != null) {
              final linkUrl = aElement.attributes['href'];
              if (linkUrl != null && linkUrl.isNotEmpty) {
                return VideoPlayerWidget(videoUrl: linkUrl);
              }
            }
          }

          return const SizedBox.shrink();
        }

        if (extensionContext.classes.contains('poll') &&
            polls != null &&
            polls!.isNotEmpty) {
          final String pollSetId = polls!.map((p) => p.id).join('_');

          if (controller.processedPollIds.contains(pollSetId)) {
            return Container();
          }

          controller.processedPollIds.add(pollSetId);
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildPollWidget(
                Get.find<PollController>(tag: 'poll_${polls![index].id}'),
              );
            },
            itemCount: polls!.length,
          );
        }

        if (extensionContext.classes.contains('d-image-grid')) {
          List<dom.Element> images = [];
          extensionContext.element!
              .querySelectorAll('.lightbox-wrapper')
              .forEach((wrapper) {
                dom.Element? img = wrapper.querySelector('img');
                if (img != null) {
                  images.add(img);
                }
              });

          if (images.isEmpty) {
            return const SizedBox.shrink();
          }

          // 根据图片数量确定网格布局样式
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (images.length == 1) {
                  return _buildSingleImage(context, images[0]);
                } else if (images.length == 2) {
                  return _buildTwoImagesRow(context, images);
                } else if (images.length == 3) {
                  return _buildThreeImagesLayout(context, images);
                } else if (images.length == 4) {
                  return _buildFourImagesGrid(context, images);
                } else {
                  return _buildImageGrid(context, images);
                }
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  TagExtension _codeExtension(BuildContext context) {
    return TagExtension(
      tagsToExtend: {"pre"},
      builder: (extensionContext) {
        // 获取代码内容
        final codeElement = extensionContext.element?.children.firstWhere(
          (element) => element.localName == 'code',
          orElse: () => dom.Element.tag('code'),
        );
        final code = codeElement?.text ?? '';

        // 获取代码语言
        final language = codeElement?.className.split('-').last;

        return Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (language != null && language != 'null') ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    8.vGap,
                  ],
                  Text.rich(
                    TextSpan(
                      text: code,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'monospace',
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            // 全屏按钮
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      showSuccess('代码已复制到剪贴板');
                    },
                    icon: Icon(
                      CupertinoIcons.doc_on_doc,
                      size: 18.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    splashRadius: 20.w,
                  ),
                  IconButton(
                    onPressed: () =>
                        showCodePreview(context, code, language: language),
                    icon: Icon(
                      CupertinoIcons.fullscreen,
                      size: 18.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    splashRadius: 20.w,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TagExtension _iframeExtension(BuildContext context) {
    return TagExtension(
      tagsToExtend: {"iframe"},
      builder: (extensionContext) {
        final src = extensionContext.attributes['src'];
        if (src == null) return const SizedBox();

        // 处理 bilibili 视频
        if (src.contains('player.bilibili.com')) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(src)),
                  initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    iframeAllowFullscreen: true,
                    javaScriptEnabled: true,
                  ),
                  onLoadStart: (controller, url) {
                    controller.evaluateJavascript(
                      source: '''
                            document.body.style.margin = '0';
                            document.body.style.padding = '0';
                            document.body.style.backgroundColor = 'transparent';
                          ''',
                    );
                  },
                ),
              ),
            ),
          );
        }

        // 处理其他视频源
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.w),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(src)),
                initialSettings: InAppWebViewSettings(
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  iframeAllowFullscreen: true,
                  javaScriptEnabled: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TagExtension _imageExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"img"},
      builder: (extensionContext) {
        final src = extensionContext.attributes['src'];
        if (src == null) return const SizedBox();

        // 优先使用自定义构建器
        if (customWidgetBuilder != null && extensionContext.element != null) {
          final widget = customWidgetBuilder!(extensionContext.element!);
          return widget;
        }

        // 处理相对路径，添加域名前缀
        final String imageUrl = src.startsWith('/')
            ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$src'
            : src;

        // 检查是否是回复中用户头像
        if (imageUrl.contains('user_avatar/linux.do') ||
            imageUrl.contains('/letter_avatar_proxy')) {
          return CachedImage(
            imageUrl: imageUrl,
            width: 32.w,
            height: 32.w,
            circle: true,
            showBorder: true,
            borderColor: Theme.of(context).primaryColor,
          );
        }

        // 检查是否是表情
        final isEmoji = extensionContext.classes.contains('emoji');
        final isEmojiPath =
            imageUrl.contains('/uploads/default/original') ||
            imageUrl.contains('/images/emoji/twitter/') ||
            imageUrl.contains('plugins/discourse-narrative-bot/images') ||
            imageUrl.contains('/images/emoji/apple/');

        final width = extensionContext.attributes['width'];
        final height = extensionContext.attributes['height'];

        if (isEmoji || isEmojiPath) {
          return Image.network(
            imageUrl,
            width: width != null ? double.parse(width) : 20.sp,
            height: height != null ? double.parse(height) : 20.sp,
            fit: BoxFit.contain,
          );
        }

        // 获取原始图片URL用于预览
        String previewUrl = imageUrl;
        // if (previewUrl.contains('/optimized/')) {
        //   previewUrl = previewUrl.replaceFirst('/optimized/', '/original/');
        // }

        return GestureDetector(
          onTap: () => showImagePreview(context, previewUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(color: theme.dividerColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: CachedImage(
                imageUrl: imageUrl,
                width: double.infinity,
                placeholder: Container(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  child: Center(child: DisRefreshLoading()),
                ),
                errorWidget: Icon(
                  Icons.broken_image_outlined,
                  size: 40.w,
                  color: theme.iconTheme.color?.withValues(alpha: .5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 修复表格 HTML，移除嵌套的 p 标签和处理列表元素
  String _fixTableHtml(String html) {
    try {
      // 使用 dom 库解析 HTML
      final document = dom.Document.html(html);

      // 处理表格中的 p 标签
      document.querySelectorAll('th p, td p').forEach((element) {
        final span = dom.Element.tag('span');
        span.innerHtml = element.innerHtml;
        element.replaceWith(span);
      });

      // 处理表格中的列表元素
      document
          .querySelectorAll(
            'th > ul > li, th > ol > li, td > ul > li, td > ol > li',
          )
          .forEach((element) {
            final span = dom.Element.tag('span');
            span.innerHtml = element.innerHtml;
            element.replaceWith(span);
          });

      document.querySelectorAll('th > ul, th > ol, td > ul, td > ol').forEach((
        element,
      ) {
        final span = dom.Element.tag('span');
        span.innerHtml = element.innerHtml;
        element.replaceWith(span);
      });

      return document.outerHtml;
    } catch (e) {
      l.e('修复表格 HTML 出错: $e');
      return html; // 如果处理失败，返回原始 HTML
    }
  }

  // 用户提及链接的扩展 - 只针对@提及链接
  TagExtension _mentionExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      // 只处理包含mention类的a标签，不影响其他a标签
      tagsToExtend: {"mention"},
      builder: (extensionContext) {
        final href = extensionContext.attributes['href'];
        final mentionText = extensionContext.element?.text ?? '';

        // 优先使用自定义构建器
        if (customWidgetBuilder != null && extensionContext.element != null) {
          final widget = customWidgetBuilder!(extensionContext.element!);
          return widget;
        }

        return GestureDetector(
          onTap: () {
            // 处理mention点击事件
            if (href != null) {
              final username = href.split('/').last;
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: UserInfoCard(
                    toPersonalPage: false,
                    username: username,
                  ),
                ),
                barrierColor: Colors.black.withValues(alpha: 0.5),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1).w,
            margin: const EdgeInsets.only(top: 6).w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Text(
              mentionText,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontFamily.dinPro,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  // 添加链接预览扩展
  // TagExtension _linkPreviewExtension(BuildContext context, ThemeData theme) {
  //   return TagExtension(
  //     tagsToExtend: {"a"},
  //     builder: (extensionContext) {
  //       final href = extensionContext.attributes['href'];
  //       if (href == null) return const SizedBox();

  //       // 如果是内部链接或特殊链接，不显示预览
  //       if (href.startsWith('/') ||
  //           href.startsWith('#') ||
  //           href.contains(HttpConfig.domain) ||
  //           href.contains('@')) {
  //         return GestureDetector(
  //           onTap: () => onLinkTap?.call(href),
  //           child: Text(
  //             extensionContext.element?.text ?? href,
  //             style: TextStyle(
  //               color: theme.primaryColor,
  //               fontSize: fontSize ?? 14.sp,
  //               decoration: TextDecoration.none,
  //             ),
  //           ),
  //         );
  //       }

  //       // 外部链接显示预览
  //       return Obx(() => Container(
  //             padding: const EdgeInsets.all(12).w,
  //             margin: const EdgeInsets.symmetric(vertical: 8).w,
  //             decoration: BoxDecoration(
  //               color: theme.cardColor,
  //               borderRadius: BorderRadius.circular(6).w,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: theme.shadowColor.withValues(alpha: 0.1),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: LinkPreview(
  //               onPreviewDataFetched: (data) {
  //                 controller.datas[href] = data;
  //               },
  //               previewData: controller.datas[href],
  //               text: href,
  //               width: MediaQuery.of(context).size.width,
  //               padding: EdgeInsets.zero,
  //               enableAnimation: true,
  //               onLinkPressed: (url) => onLinkTap?.call(url),
  //               linkStyle: TextStyle(
  //                 color: theme.primaryColor,
  //                 fontSize: fontSize ?? 14.sp,
  //                 decoration: TextDecoration.none,
  //               ),
  //             ),
  //           ));
  //     },
  //   );
  // }

  void _showFullScreenDialog(BuildContext context, String html) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        elevation: 16,
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.table_fill,
                          size: 14.w,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '表格预览',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.w),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 14.w,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 表格内容区
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    // 使用StatefulBuilder但不保存状态，避免恢复滚动位置问题
                    final horizontalScrollCtrl = ScrollController();
                    final verticalScrollCtrl = ScrollController();

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: NotificationListener<ScrollNotification>(
                        // 拦截滚动通知，避免触发滚动位置恢复
                        onNotification: (notification) => true,
                        child: SingleChildScrollView(
                          controller: horizontalScrollCtrl,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width - 64.w,
                              maxWidth: MediaQuery.of(context).size.width * 1.7,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const ClampingScrollPhysics(),
                              controller: verticalScrollCtrl,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 3,
                                ),
                                child: Html(
                                  data: html,
                                  style: {
                                    "table": Style(
                                      backgroundColor: theme.cardColor,
                                    ),
                                    "th": Style(
                                      padding: HtmlPaddings.all(12.w),
                                      backgroundColor: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      fontWeight: FontWeight.bold,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    "td": Style(
                                      padding: HtmlPaddings.all(12.w),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 0.5,
                                      ),
                                    ),
                                  },
                                  extensions: const [TableHtmlExtension()],
                                  onLinkTap: (url, _, __) {
                                    if (onLinkTap != null) {
                                      onLinkTap!(url);
                                    } else {
                                      Get.toNamed(
                                        Routes.WEBVIEW,
                                        arguments: url,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 底部按钮区
              SizedBox(height: 16.h),
              SizedBox(
                height: 32.w,
                width: double.infinity,
                child: DisButton(
                  text: '完成',
                  type: ButtonType.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollWidget(PollController controller) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10).w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: .12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10).w,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: .1),
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor, width: .5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.chart_bar_square,
                        size: 20,
                        color: theme.primaryColor,
                      ),
                      8.hGap,
                      Text(
                        '投票',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      Obx(
                        () => controller.pollStatus.value == 'open'
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '进行中',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '已结束',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                // 投票选项
                Padding(
                  padding: const EdgeInsets.all(10).w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 14.w,
                            color: theme.primaryColor.withValues(alpha: .5),
                          ),
                          Text(
                            controller.title.value,
                            style: TextStyle(
                              fontSize: 11.w,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                          ),
                        ],
                      ),
                      18.vGap,
                      ...controller.options.map(
                        (option) => Obx(
                          () =>
                              _buildPollOptionItem(context, controller, option),
                        ),
                      ),

                      // 投票信息
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_2,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          4.hGap,
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${controller.voteCount.value}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFontFamily.dinPro,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 人参与投票',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 32.w,
                            child: Obx(
                              () => DisButton(
                                fontSize: 12,
                                text: controller.hasVoted.value
                                    ? '修改投票'
                                    : '提交投票',
                                type: ButtonType.transform,
                                loading: controller.isVoting.value,
                                onPressed: () => controller.submitVote(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 如果公开投票，显示投票人列表
                      Obx(() {
                        List<PollVoter> allVoters = [];
                        String voterType = '';

                        if (controller.selectedOptionIds.isNotEmpty) {
                          // 如果选择了一个选项，显示该选项的投票者
                          if (controller.selectedOptionIds.length == 1) {
                            final optionId = controller.selectedOptionIds.first;
                            allVoters = controller.getVotersForOption(optionId);
                            voterType = controller.getVoterType(optionId);
                          } else {
                            // 如果选择了多个选项，合并所有选中选项的投票者
                            for (final optionId
                                in controller.selectedOptionIds) {
                              allVoters.addAll(
                                controller.getVotersForOption(optionId),
                              );
                              if (voterType.isEmpty) {
                                voterType = controller.getVoterType(optionId);
                              } else {
                                voterType +=
                                    '、${controller.getVoterType(optionId)}';
                              }
                            }
                            // 去重
                            allVoters = allVoters.toSet().toList();
                          }
                        }

                        if (allVoters.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.vGap,
                            const Divider(),
                            8.vGap,
                            _buildVotersList(
                              context,
                              controller,
                              voterType,
                              allVoters,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVotersList(
    BuildContext context,
    PollController controller,
    String voterType,
    List<PollVoter> votersList,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 投票类型标题
        // if (voterType.isNotEmpty)
        //   Text(
        //     '投票给"$voterType":',
        //     style: TextStyle(
        //       fontSize: 12,
        //       color: theme.textTheme.bodySmall?.color,
        //     ),
        //   ),
        8.vGap,

        // 投票者列表
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            // 投票者头像列表
            ...votersList.map(
              (voter) => AvatarWidget(
                avatarUrl: voter.getAvatarUrl(),
                size: 21,
                borderRadius: 4,
                backgroundColor: theme.primaryColor.withValues(alpha: .1),
                username: voter.username ?? '',
                avatarActions: AvatarActions.openCard,
                toPersonalPage: false,
                borderColor: theme.primaryColor,
              ),
            ),

            // 加载更多按钮
            Obx(() {
              if (controller.hasMoreVotersForSelectedOptions()) {
                if (controller.isLoadingMoreVoters.value) {
                  return Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  );
                }

                return InkWell(
                  onTap: () => controller.loadMoreVoters(),
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      CupertinoIcons.add,
                      size: 14,
                      color: theme.primaryColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildPollOptionItem(
    BuildContext context,
    PollController controller,
    PollOption option,
  ) {
    final theme = Theme.of(context);
    final isSelected = controller.isOptionSelected(option.id ?? '');
    final votePercent = controller.getOptionPercent(option.id ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12).w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleOption(option.id ?? ''),
          borderRadius: BorderRadius.circular(12).w,
          child: Container(
            height: 34.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(
                color: isSelected ? theme.primaryColor : theme.dividerColor,
                width: 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (controller.shouldShowResults.value) ...[
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return RepaintBoundary(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: constraints.maxWidth * votePercent / 100,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(12).w,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // 选项内容
                Row(
                  children: [
                    16.hGap,
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        shape: controller.isMultipleChoice
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        borderRadius: controller.isMultipleChoice
                            ? BorderRadius.circular(3)
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : theme.primaryColor.withValues(alpha: .2),
                          width: 1,
                        ),
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              CupertinoIcons.check_mark,
                              size: 10.w,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    12.hGap,

                    // 选项文本
                    Expanded(
                      child: Text(
                        option.html ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),

                    // 投票结果百分比
                    if (controller.shouldShowResults.value) ...[
                      Text(
                        '${votePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: AppFontFamily.dinPro,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    16.hGap,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 辅助方法：构建单图布局
  Widget _buildSingleImage(BuildContext context, dom.Element imgElement) {
    final src = imgElement.attributes['src'];
    final width = double.tryParse(imgElement.attributes['width'] ?? '0') ?? 0;
    final height = double.tryParse(imgElement.attributes['height'] ?? '0') ?? 0;

    if (src == null) return const SizedBox.shrink();

    // 使用固定的宽高比，若原始尺寸可用则使用，否则使用默认比例
    final double aspectRatio;
    if (width > 0 && height > 0) {
      aspectRatio = width / height;
    } else {
      // 默认使用4:3比例作为通用显示比例
      aspectRatio = 4 / 3;
    }

    return GestureDetector(
      onTap: () => showImagePreview(context, src),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4).w,
          child: CachedNetworkImage(
            imageUrl: src,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              child: Center(child: DisRefreshLoading(opacity: 0.5)),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 辅助方法：构建两图布局
  Widget _buildTwoImagesRow(BuildContext context, List<dom.Element> images) {
    const gap = 6.0;
    const fixedHeight = 160.0; // 两图布局使用较大的高度

    return Row(
      children: [
        Expanded(
          child: _buildGridItemImage(
            context,
            images[0],
            fixedHeight: fixedHeight,
          ),
        ),
        gap.hGap,
        Expanded(
          child: _buildGridItemImage(
            context,
            images[1],
            fixedHeight: fixedHeight,
          ),
        ),
      ],
    );
  }

  // 辅助方法：构建三图布局
  Widget _buildThreeImagesLayout(
    BuildContext context,
    List<dom.Element> images,
  ) {
    const gap = 6.0;
    const mainImageHeight = 180.0; // 主图较大
    const smallImageHeight = 120.0; // 小图较小

    return Column(
      children: [
        _buildGridItemImage(context, images[0], fixedHeight: mainImageHeight),
        gap.vGap,
        Row(
          children: [
            Expanded(
              child: _buildGridItemImage(
                context,
                images[1],
                fixedHeight: smallImageHeight,
              ),
            ),
            gap.hGap,
            Expanded(
              child: _buildGridItemImage(
                context,
                images[2],
                fixedHeight: smallImageHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 辅助方法：构建四图网格
  Widget _buildFourImagesGrid(BuildContext context, List<dom.Element> images) {
    const gap = 6.0;
    const fixedHeight = 140.0; // 四图布局中每张图片的高度

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridItemImage(
                context,
                images[0],
                fixedHeight: fixedHeight,
              ),
            ),
            gap.hGap,
            Expanded(
              child: _buildGridItemImage(
                context,
                images[1],
                fixedHeight: fixedHeight,
              ),
            ),
          ],
        ),
        gap.vGap,
        Row(
          children: [
            Expanded(
              child: _buildGridItemImage(
                context,
                images[2],
                fixedHeight: fixedHeight,
              ),
            ),
            gap.hGap,
            Expanded(
              child: _buildGridItemImage(
                context,
                images[3],
                fixedHeight: fixedHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 辅助方法：构建多图网格
  Widget _buildImageGrid(BuildContext context, List<dom.Element> images) {
    // 统一使用更大的间距
    const gap = 6.0;
    const columns = 3; // 固定3列
    const gridItemHeight = 120.0; // 每行固定高度

    // 计算行数
    final rows = (images.length / columns).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns > images.length)
            ? images.length
            : startIndex + columns;

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? gap : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(endIndex - startIndex, (colIndex) {
              final index = startIndex + colIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: colIndex < endIndex - startIndex - 1 ? gap : 0,
                  ),
                  child: _buildGridItemImage(
                    context,
                    images[index],
                    fixedHeight: gridItemHeight,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // 辅助方法：构建固定高度的单张图片
  Widget _buildGridItemImage(
    BuildContext context,
    dom.Element imgElement, {
    double fixedHeight = 120,
  }) {
    final src = imgElement.attributes['src'];
    if (src == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => showImagePreview(context, src),
      child: Container(
        height: fixedHeight.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4).w,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4).w,
          child: CachedNetworkImage(
            imageUrl: src,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              child: Center(child: DisRefreshLoading(opacity: 0.5)),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HtmlController extends BaseController {
  final isPolicyAccepted = false.obs;
  final postId = 0.obs;
  final _apiService = Get.find<ApiService>();
  RxMap<String, PreviewData> datas = RxMap<String, PreviewData>();
  final Set<String> processedPollIds = {};

  // 存储引用内容的Map，key为"topicId:postId"格式
  final RxMap<String, String> quotedContents = RxMap<String, String>();

  void loadLinkRow(int topicId, int postId) async {
    final key = '$topicId:$postId';

    // 如果已经加载过，就不再重复加载
    if (quotedContents.containsKey(key)) {
      return;
    }

    try {
      final response = await _apiService.getPostLinkRow(
        topicId.toString(),
        postId.toString(),
      );
      if (response.cooked != null) {
        quotedContents[key] = response.cooked!;
        quotedContents.refresh();
      }
    } catch (e) {
      l.e('加载引用内容出错: $e');
    }
  }

  // 获取引用内容
  String? getQuotedContent(int topicId, int postId) {
    return quotedContents['$topicId:$postId'];
  }

  void acceptPolicy() {
    isPolicyAccepted.value = true;
  }

  void revokePolicy() {
    isPolicyAccepted.value = false;
  }

  void updatePolicyAccepted() async {
    _updatePolicyAccepted(isPolicyAccepted.value ? 'unaccept' : 'accept');
  }

  void _updatePolicyAccepted(String action) async {
    try {
      isLoading.value = true;
      final response = await _apiService.updatePolicyAccepted(
        action,
        postId.value.toString(),
      );

      if (response.isSuccess) {
        isPolicyAccepted.value = !isPolicyAccepted.value;
      }
    } catch (e) {
      l.e('更新政策接受状态出错: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class PollController extends BaseController {
  final Rx<Polls> poll;
  final RxMap<String, RxList<PollVoter>> voters =
      <String, RxList<PollVoter>>{}.obs;
  final RxList<String> selectedOptionIds = <String>[].obs;
  final RxBool hasVoted = false.obs;
  final RxBool showVoters = true.obs;
  final RxBool shouldShowResults = false.obs;
  final RxBool isVoting = false.obs;
  final RxBool isLoadingMoreVoters = false.obs;
  final RxMap<String, int> votersPage = <String, int>{}.obs;
  final int votersPerPage = 25; // 每页显示的投票者数量
  final ApiService _apiService = Get.find<ApiService>();

  // 计算属性
  String get pollName => poll.value.name ?? '';
  String get pollType => poll.value.type ?? '';
  String get chartType => poll.value.chart_type ?? '';
  bool get isPublic => poll.value.public ?? false;
  String get resultsVisibility => poll.value.results ?? '';
  int get totalVoters => poll.value.voters ?? 0;
  bool get isMultipleChoice => pollType == 'multiple';

  RxInt get voteCount => RxInt(poll.value.voters ?? 0);
  RxString get pollStatus => RxString(poll.value.status ?? '');
  RxList<PollOption> get options => RxList(poll.value.options ?? []);
  RxString get title => RxString(poll.value.title ?? '');

  @override
  void onInit() {
    updateSelectedOptions();
    super.onInit();
  }

  PollController(Polls initialPoll) : poll = initialPoll.obs {
    updatePoll(initialPoll);
  }

  void updatePoll(Polls newPoll) {
    poll.value = newPoll;

    updateSelectedOptions();

    // 更新投票者数据
    if (newPoll.preloaded_voters != null) {
      voters.clear();
      votersPage.clear();

      newPoll.preloaded_voters!.forEach((optionId, votersList) {
        voters[optionId] = RxList<PollVoter>(votersList);
        votersPage[optionId] = 1; // 初始化页码
      });
    }

    updateResultsVisibility();
  }

  void updateSelectedOptions() {
    selectedOptionIds.clear();
    hasVoted.value = false;

    // 如果有vote数据，将其添加到selectedOptionIds
    if (poll.value.vote != null && poll.value.vote!.isNotEmpty) {
      // 处理投票数据
      selectedOptionIds.addAll(poll.value.vote!);
      hasVoted.value = true;
    }
  }

  String getVoterType(String optionId) {
    return options
            .firstWhere(
              (opt) => opt.id == optionId,
              orElse: () => PollOption(id: '', html: '', votes: 0),
            )
            .html ??
        '';
  }

  // 获取特定选项的投票者列表
  List<PollVoter> getVotersForOption(String optionId) {
    return voters[optionId]?.toList() ?? [];
  }

  // 检查是否有更多投票者可以加载
  bool hasMoreVoters(String optionId) {
    // 找到该选项的总投票数
    final option = options.firstWhere(
      (opt) => opt.id == optionId,
      orElse: () => PollOption(id: '', html: '', votes: 0),
    );

    final totalVotes = option.votes ?? 0;
    final loadedVoters = voters[optionId]?.length ?? 0;

    return loadedVoters < totalVotes;
  }

  // 检查当前选中的所有选项是否有更多投票者可以加载
  bool hasMoreVotersForSelectedOptions() {
    if (selectedOptionIds.isEmpty) return false;

    for (final optionId in selectedOptionIds) {
      if (hasMoreVoters(optionId)) return true;
    }

    return false;
  }

  // 加载更多投票者
  Future<void> loadMoreVoters() async {
    if (isLoadingMoreVoters.value || selectedOptionIds.isEmpty) return;

    try {
      isLoadingMoreVoters.value = true;

      for (final optionId in selectedOptionIds) {
        final response = await _apiService.getPollVoters(
          pollName: poll.value.name ?? '',
          page: votersPage[optionId] ?? 1,
          limit: votersPerPage,
          optionId: optionId,
          postId: poll.value.postId,
        );

        if (response.voters != null &&
            response.voters!.containsKey(optionId) &&
            response.voters![optionId] != null) {
          final newVoters = response.voters![optionId]!;
          if (newVoters.isNotEmpty) {
            // 更新页码
            votersPage[optionId] = (votersPage[optionId] ?? 1) + 1;
            if (!voters.containsKey(optionId)) {
              voters[optionId] = RxList<PollVoter>([]);
            }

            voters[optionId]!.addAll(newVoters);
          }
        }

        voters.refresh();
      }
    } catch (e, s) {
      l.e('加载更多投票者失败: $e \n$s');
    } finally {
      isLoadingMoreVoters.value = false;
    }
  }

  double getOptionPercent(String optionId) {
    if (totalVoters == 0) return 0;

    // 查找对应选项的票数
    final option = options.firstWhere(
      (opt) => opt.id == optionId,
      orElse: () => PollOption(id: '', html: '', votes: 0),
    );

    // 计算百分比
    return (option.votes ?? 0) * 100.0 / totalVoters;
  }

  // 修改：选择/取消选择选项
  void toggleOption(String optionId) {
    if (isMultipleChoice) {
      if (selectedOptionIds.contains(optionId)) {
        selectedOptionIds.remove(optionId);
      } else {
        selectedOptionIds.add(optionId);
      }
    } else {
      selectedOptionIds.clear();
      selectedOptionIds.add(optionId);
    }
  }

  bool isOptionSelected(String optionId) {
    return selectedOptionIds.contains(optionId);
  }

  void updateResultsVisibility() {
    switch (resultsVisibility) {
      case 'always':
        shouldShowResults.value = true;
        break;
      case 'on_vote':
        shouldShowResults.value = hasVoted.value;
        break;
      case 'on_close':
        shouldShowResults.value = pollStatus.value == 'closed';
        break;
      default:
        shouldShowResults.value = false;
    }
  }

  // 修改：提交投票
  Future<void> submitVote() async {
    try {
      isVoting.value = true;

      if (selectedOptionIds.isEmpty) {
        showWarning('请选择投票选项');
        return;
      }

      // 调用API提交投票
      final response = await _apiService.submitVote(
        poll.value.name ?? 'poll',
        selectedOptionIds.toList(),
        postId: poll.value.postId,
      );

      if (response.poll != null) {
        final poll = response.poll;
        poll?.vote = response.vote;
        updatePoll(poll!);

        // 更新结果显示状态
        updateResultsVisibility();
        showSuccess('投票成功');
      } else {
        showError('投票失败，请稍后重试');
      }
    } catch (e, s) {
      l.e('投票提交失败: $e \n$s');
    } finally {
      isVoting.value = false;
    }
  }
}
