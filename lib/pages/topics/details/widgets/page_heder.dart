import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/emoji_text.dart';

import '../../../../utils/tag.dart';
import '../topic_detail_controller.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.controller});

  final TopicDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          controller.topic.value?.title == null
              ? const SizedBox()
              : EmojiText(
                  controller.topic.value?.title ?? '',
                  style: TextStyle(
                    fontSize: 12.w,
                    fontFamily: AppFontFamily.dinPro,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          if (controller.topic.value?.tags != null &&
              controller.topic.value?.tags!.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 2).w,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (controller.topic.value?.tags ?? []).map((tag) {
                    final color = Tag.getTagColors(tag);
                    return Container(
                      margin: const EdgeInsets.only(right: 8).w,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.4,
                      ).w,
                      decoration: BoxDecoration(
                        color: color.backgroundColor,
                        border: Border.all(
                          color: color.backgroundColor,
                          width: 0.5,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(4))
                            .w,
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 8.w, color: color.textColor),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
