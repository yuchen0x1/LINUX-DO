import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_emoji_picker.dart';
import 'package:linux_do/widgets/dis_text_field.dart';

import '../../const/app_const.dart';
import '../../const/app_colors.dart';
import '../../const/app_theme.dart';
import '../../utils/tag.dart';
import '../../widgets/category_item.dart';
import 'create_post_controller.dart';

class CreatePostPage extends GetView<CreatePostController> {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: 14.w,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        leadingWidth: 60.w,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 4.w),
            height: 30.w,
            child: TextButton(
              onPressed: controller.saveDraft,
              child: Text(
                AppConst.createPost.draft,
                style: TextStyle(
                  fontSize: 13.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 16.w),
            height: 30.w,
            child: DisButton(
              onPressed: controller.publishPost,
              text: '发布',
              fontSize: 13.w,
              borderRadius: 15.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildPostContent(context)),
          _buildBottomToolbar(context),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final userAvatar = Get.find<GlobalController>().userInfo?.user?.avatarUrl;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12).w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 用户头像
                AvatarWidget(
                  avatarUrl: userAvatar ?? '',
                  size: 30.w,
                  borderColor: Theme.of(context).primaryColor,
                ),
                16.hGap,
                // 帖子内容输入区
                Expanded(
                  child: TextField(
                    controller: controller.titleController,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).textTheme.titleSmall?.color,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                    focusNode: controller.titleFocusNode,
                    decoration: InputDecoration(
                      hintText: "输入标题",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      fillColor: AppColors.transparent,
                      hintStyle: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color
                            ?.withValues(alpha: .3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12).w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.hGap,
                // 帖子内容输入区
                Expanded(
                  child: TextField(
                    controller: controller.contentController,
                    maxLines: null,
                    maxLength: 2000,
                    focusNode: controller.contentFocusNode,
                    style: TextStyle(
                      fontSize: 13.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                    decoration: InputDecoration(
                      hintText: "提问、回复请记得：真诚、友善、团结、专业，共建你我引以为荣之社区。",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        left: 30,
                        right: 12,
                      ).w,
                      fillColor: AppColors.transparent,
                      hintStyle: TextStyle(
                        fontSize: 13.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color
                            ?.withValues(alpha: .3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    buildCounter:
                        (
                          context, {
                          required int currentLength,
                          required int? maxLength,
                          required bool isFocused,
                        }) {
                          if (maxLength == null) return null;
                          final color = currentLength > maxLength * 0.9
                              ? Colors.red
                              : currentLength > maxLength * 0.7
                              ? Colors.orange
                              : Colors.grey;
                          return Text(
                            '$currentLength/$maxLength',
                            style: TextStyle(
                              color: color,
                              fontSize: 11.w,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
          ),

          // 已上传图片区域
          Obx(() {
            if (controller.uploadedImages.isEmpty) {
              return Container();
            }
            return Container(
              height: 60.w,
              margin: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                bottom: 16.w,
                top: 20.w,
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.uploadedImages.length,
                separatorBuilder: (context, index) => 8.hGap,
                itemBuilder: (context, index) {
                  final image = controller.uploadedImages[index];
                  return Stack(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          image: DecorationImage(
                            image: NetworkImage(image.url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4.w,
                        top: 4.w,
                        child: InkWell(
                          onTap: () => controller.removeImage(image),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 11.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryAndTags(context),
        4.vGap,
        _buildMenus(context),
        Obx(() {
          return Offstage(
            offstage: !controller.isShowEmojiPicker.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: DisEmojiPicker(
                height: 320.w,
                textEditingController: controller.focusedInput.value == 'title'
                    ? controller.titleController
                    : controller.contentController,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMenus(BuildContext context) => Obx(() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom:
            controller.isShowEmojiPicker.value ||
                controller.isShowKeyboard.value
            ? 0
            : 26,
      ).w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          controller.isUploading.value
              ? Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: controller.pickAndUploadImage,
                  icon: Icon(
                    CupertinoIcons.camera_fill,
                    color: Theme.of(context).primaryColor,
                    size: 18.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
          // 分类按钮
          IconButton(
            onPressed: () {
              _showCategoryPicker(context);
            },
            icon: Icon(
              CupertinoIcons.square_grid_2x2_fill,
              color: Theme.of(context).primaryColor,
              size: 18.w,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
          ),
          // tag按钮
          controller.selectedCategoryName.value == null
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    _showTagPicker(context);
                  },
                  icon: Icon(
                    CupertinoIcons.tag_circle_fill,
                    color: Theme.of(context).primaryColor,
                    size: 18.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
          // 预览
          IconButton(
            onPressed: () {
              controller.togglePreview();
            },
            icon: Icon(
              CupertinoIcons.eye_fill,
              color: Theme.of(context).primaryColor,
              size: 18.w,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
          ),
          const Spacer(),
          // 表情切换
          IconButton(
            icon: Icon(
              CupertinoIcons.smiley_fill,
              color: Theme.of(context).primaryColor,
              size: 18.w,
            ),
            onPressed: () {
              controller.toggleEmojiPicker();
            },
          ),
        ],
      ),
    );
  });

  Padding _buildCategoryAndTags(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => controller.selectedCategoryName.value == null
                ? const SizedBox.shrink()
                : Text(
                    '${controller.selectedCategoryName.value}',
                    style: TextStyle(
                      fontSize: 11.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontFamily: AppFontFamily.dinPro,
                    ),
                  ),
          ),
          4.vGap,
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: controller.tags.isEmpty
                  ? const SizedBox.shrink()
                  : Row(
                      children: controller.tags.map((tag) {
                        final color = Tag.getTagColors(tag);
                        return Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.w,
                          ),
                          decoration: BoxDecoration(
                            color: color.backgroundColor,
                            border: Border.all(
                              color: color.backgroundColor,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10.w,
                                  color: color.textColor,
                                  fontFamily: AppFontFamily.dinPro,
                                ),
                              ),
                              4.hGap,
                              InkWell(
                                onTap: () => controller.removeTag(tag),
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  size: 10.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ],
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

  void _showTagPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.symmetric(vertical: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConst.createPost.addTags,
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chevron_down,
                        size: 16.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              8.vGap,
              const Divider(),
              // 搜索框
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                child: DisTextField(
                  controller: controller.searchController,
                  hintText: '搜索标签...',
                  onSubmitted: (value) {
                    controller.searchTags(value);
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                child: Obx(
                  () => controller.tags.isEmpty
                      ? const SizedBox()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: controller.tags.map((tag) {
                              final color = Tag.getTagColors(tag);
                              return Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.w,
                                ),
                                decoration: BoxDecoration(
                                  color: color.backgroundColor,
                                  border: Border.all(
                                    color: color.backgroundColor,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 11.w,
                                        color: color.textColor,
                                        fontFamily: AppFontFamily.dinPro,
                                      ),
                                    ),
                                    4.hGap,
                                    InkWell(
                                      onTap: () => controller.removeTag(tag),
                                      child: Icon(
                                        CupertinoIcons.xmark,
                                        size: 10.w,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),

              // 标签列表
              Expanded(
                child: Obx(() {
                  if (controller.tagResults.isEmpty &&
                      controller.searchController.text.isEmpty) {
                    return const Center(child: Text('请输入关键词搜索标签'));
                  }
                  if (controller.tagResults.isEmpty) {
                    return const Center(child: Text('暂无匹配的标签'));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 10.w,
                    ),
                    itemCount: controller.tagResults.length,
                    separatorBuilder: (_, __) => 1.vGap,
                    itemBuilder: (context, index) {
                      final tag = controller.tagResults[index];
                      final color = Tag.getTagColors(tag.name);
                      final isSelected = controller.tags.contains(
                        tag.targetTag ?? tag.name,
                      );
                      return GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            controller.addTag(tag.targetTag ?? tag.name);
                          } else {
                            controller.removeTag(tag.targetTag ?? tag.name);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4.w),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.w,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.w,
                                ),
                                decoration: BoxDecoration(
                                  color: color.backgroundColor,
                                  border: Border.all(
                                    color: color.backgroundColor,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Text(
                                  tag.name,
                                  style: TextStyle(
                                    fontSize: 11.w,
                                    color: color.textColor,
                                    fontFamily: AppFontFamily.dinPro,
                                  ),
                                ),
                              ),
                              Text(
                                'x (${tag.count})',
                                style: TextStyle(
                                  fontSize: 10.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontFamily: AppFontFamily.dinPro,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      //  controller.searchController.clear();
      // controller.tagResults.clear();
    });
  }

  // 显示分类选择对话框
  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.symmetric(vertical: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择分类',
                      style: TextStyle(
                        fontSize: 15.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chevron_down,
                        size: 16.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              8.vGap,
              const Divider(),
              // 分类列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = controller.categories;
                  if (categories.isEmpty) {
                    return const Center(child: Text('暂无分类数据'));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 10.w,
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => Container(),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryItem(
                        category: category,
                        stats: controller.categoryStats[category.id] ?? {},
                        isSelected:
                            controller.selectedCategory.value?.id ==
                            category.id,
                        onTap: (category, level) {
                          controller.updateSelectedCategory(category, level);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
