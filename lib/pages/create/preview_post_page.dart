import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/widgets/emoji_text.dart';
import 'package:linux_do/widgets/html/html_widget.dart';
import '../../const/app_const.dart';
import '../../const/app_spacing.dart';
import '../../utils/tag.dart';
import 'preview_post_controller.dart';

class PreviewPostPage extends GetView<PreviewPostController> {
  const PreviewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppConst.createPost.previewTitle,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Container(
          margin: const EdgeInsets.only(top: 6).w,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 14.w,
                  bottom: 12.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmojiText(
                      controller.title,
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    if (controller.tags.isNotEmpty) ...[
                      12.vGap,
                      Row(
                        children: [
                          // 分类
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.folder,
                                  size: 11.w,
                                  color: Theme.of(context).primaryColor,
                                ),
                                4.hGap,
                                Text(
                                  controller.category.name ?? '',
                                  style: TextStyle(
                                    fontSize: 11.w,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.hGap,
                          // 标签
                          if (controller.tags.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: controller.tags.map((tag) {
                                    final color = Tag.getTagColors(tag);
                                    return Container(
                                      margin: EdgeInsets.only(right: 8.w),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                          4.w,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 11.w,
                                          color: color.textColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 内容
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.all(12.w),
                child: controller.content.isEmpty
                    ? Center(
                        child: Text(
                          AppConst.createPost.previewEmpty,
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : HtmlWidget(html: controller.content),
              ),
              24.vGap,
            ],
          ),
        ),
      ),
    );
  }
}
