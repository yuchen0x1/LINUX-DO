import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../const/app_const.dart';
import '../../controller/base_controller.dart';
import '../../controller/global_controller.dart';
import '../../net/api_service.dart';
import '../../models/category_data.dart';
import '../../models/tag_data.dart';
import '../../models/image_size.dart';
import '../../models/upload_image_response.dart';
import '../../utils/storage_manager.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:math';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/log.dart';

import 'preview_post_controller.dart';
import 'preview_post_page.dart';

class CreatePostController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();

  // 标题
  final titleController = TextEditingController();
  // 内容
  final contentController = TextEditingController();

  // 搜索
  final searchController = TextEditingController();
  // 选中的分类
  final selectedCategory = Rx<Category?>(null);
  final selectedCategoryName = Rxn<String?>();
  // 是否正在提交
  final isSubmitting = false.obs;
  // 标签列表
  final tags = <String>[].obs;
  // 标签输入控制器
  final tagController = TextEditingController();
  // 是否在预览模式
  final isPreview = false.obs;
  // 分类列表
  final categories = <Category>[].obs;
  // 分类统计数据
  final categoryStats = <int, Map<int, int>>{}.obs;
  // 标签搜索结果
  final tagResults = <TagItem>[].obs;
  // 图片列表
  final uploadedImages = <UploadImageResponse>[].obs;
  final isUploading = false.obs;

  // 表情选择器相关
  final RxBool isShowEmojiPicker = false.obs;
  final RxBool isHideKeyboard = false.obs;
  final titleFocusNode = FocusNode();
  final contentFocusNode = FocusNode();

  // 跟踪焦点 currentFocus 似乎没有任何效果, 不知道原因
  final RxString focusedInput = 'content'.obs;

  final isShowKeyboard = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 从「分享到」等入口进来时，arguments 里可能带着预填正文
    _applyInitialArguments();
    // 初始化时加载所有分类的统计数据
    loadAllCategoryStats();

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        isShowEmojiPicker.value = false;
        isHideKeyboard.value = false;
      }

      isShowKeyboard.value = visible;
    });

    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        focusedInput.value = 'title';
      }
    });
    contentFocusNode.addListener(() {
      if (contentFocusNode.hasFocus) {
        focusedInput.value = 'content';
      }
    });
  }

  /// 支持 arguments 形如 `{'content': '...'}` 或 `{'title': '...', 'content': '...'}`。
  /// 用于「分享到 App」时把外部文本预填为正文。
  void _applyInitialArguments() {
    final args = Get.arguments;
    if (args is! Map) return;

    final content = args['content'];
    if (content is String && content.trim().isNotEmpty) {
      contentController.text = content;
    }
    final title = args['title'];
    if (title is String && title.trim().isNotEmpty) {
      titleController.text = title;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    tagController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.onClose();
  }

  // 加载所有分类的统计数据
  Future<void> loadAllCategoryStats() async {
    try {
      isLoading.value = true;

      // 获取所有分类
      final categoriesResponse = await _apiService.getCategories();
      categories.value = categoriesResponse.categoryList.categories;

      // 更新统计数据
      for (var category in categories) {
        // 根据权限等级计算可见的主题数量
        final totalTopics = category.topicCount;
        categoryStats[category.id] = {
          1: totalTopics ?? 0, // Lv1 可以看到所有主题
          2: category.permission == 2
              ? totalTopics ?? 0
              : 0, // Lv2 只能看到权限等级=2的主题
          3: category.permission == 3
              ? totalTopics ?? 0
              : 0, // Lv3 只能看到权限等级=3的主题
        };
      }

      /// 默认选中第一个分类
      selectedCategory.value = categories.first;
      await searchTags('');

      // 加载本地草稿，恢复之前未发布的内容
      restoreDraft();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      showToast('加载分类数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 获取指定分类和权限等级的帖子数量
  int getTopicCount(int categoryId, int level) {
    return categoryStats[categoryId]?[level] ?? 0;
  }

  // 更新选中的分类
  Future<void> updateSelectedCategory(Category category, [int? level]) async {
    selectedCategory.value = category;
    String displayName = level == null
        ? category.name ?? ''
        : '${category.name} (Lv $level)';
    selectedCategoryName.value = displayName;
    // 清空标签搜索结果
    tagResults.clear();
    tags.clear();
    await searchTags('');
  }

  // 搜索标签
  Future<List<TagItem>> searchTags(String query) async {
    if (selectedCategory.value == null) {
      return [];
    }

    try {
      // 如果搜索关键词为空，且已有结果，直接返回
      if (query.isEmpty && tagResults.isNotEmpty) {
        return tagResults;
      }

      final response = await _apiService.getTags(
        query,
        8,
        selectedCategory.value!.id,
        true,
      );
      tagResults.value = response.results;
      return response.results;
    } catch (e) {
      debugPrint('Error searching tags: $e');
      return [];
    }
  }

  void addTag(String tag) {
    final normalizedTag = tag.trim();
    if (normalizedTag.isNotEmpty && !tags.contains(normalizedTag)) {
      tags.add(normalizedTag);
      searchController.clear();
    }
  }

  void removeTag(String tag) {
    final normalizedTag = tag.trim();
    if (tags.contains(normalizedTag)) {
      tags.remove(normalizedTag);
    }
  }

  // 格式化内容为HTML
  String _formatContentToHtml() {
    if (contentController.text.isEmpty) return '';

    // 按行分割内容
    final lines = contentController.text.split('\n');
    final formattedLines = <String>[];

    for (var line in lines) {
      if (line.isEmpty) {
        continue;
      }

      // 处理图片标记 ![name|widthxheight](url)
      if (line.contains('![') && line.contains('](')) {
        final imagePattern = RegExp(r'!\[(.*?)\|(\d+)x(\d+)\]\((.*?)\)');
        final match = imagePattern.firstMatch(line);
        if (match != null) {
          final name = match.group(1) ?? '';
          final width = match.group(2) ?? '';
          final height = match.group(3) ?? '';
          var url = match.group(4) ?? '';

          // 打印匹配到的URL
          l.d('Original image URL: $url');

          // 处理 upload:// 短链接
          if (url.startsWith('upload://')) {
            // 查找对应的上传图片记录
            final uploadedImage = uploadedImages.firstWhereOrNull(
              (img) =>
                  img.shortUrl == url || img.url.contains(url.substring(9)),
            );

            if (uploadedImage != null) {
              url = uploadedImage.url;
            } else {
              // 如果找不到记录，使用基础URL
              final baseUrl = HttpConfig.baseUrl.endsWith('/')
                  ? HttpConfig.baseUrl.substring(
                      0,
                      HttpConfig.baseUrl.length - 1,
                    )
                  : HttpConfig.baseUrl;
              url = '$baseUrl/uploads/default/${url.substring(9)}';
            }
            l.d('Converted image URL: $url');
          }

          // 构建img标签
          line = '<img src="$url" alt="$name" width="$width" height="$height">';
        }
      }

      // 将处理后的行包装在p标签中
      formattedLines.add('<p>$line</p>');
    }

    // 连接所有行
    return formattedLines.join('\n');
  }

  // 切换预览模式
  void togglePreview() {
    if (!validateInputs()) return;

    // 预览不重要, 碰到问题了,先不做
    Get.to(
      () => const PreviewPostPage(),
      binding: BindingsBuilder(() {
        Get.put(
          PreviewPostController(
            title: titleController.text,
            content: _formatContentToHtml(),
            category: selectedCategory.value!,
            tags: tags,
          ),
        );
      }),
    );
  }

  // 计算文件的SHA1
  String _calculateSha1(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }

  // 生成短文件名
  String _generateShortFileName(String originalFileName) {
    final extension = originalFileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    final random = (1000 + Random().nextInt(9000)).toString();
    return 'img_${timestamp}_$random.$extension';
  }

  // 选择并上传图片
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isUploading.value = true;
      try {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final originalFileName = pickedFile.path.split('/').last;
        final shortFileName = _generateShortFileName(originalFileName);
        final sha1Checksum = _calculateSha1(bytes);

        // 创建 FormData
        final formData = dio.FormData.fromMap({
          'upload_type': 'composer',
          'pasted': false,
          'name': shortFileName,
          'type': 'image/${shortFileName.split('.').last}',
          'sha1_checksum': sha1Checksum,
          'file': await dio.MultipartFile.fromFile(
            pickedFile.path,
            filename: shortFileName,
          ),
        });

        final response = await _apiService.uploadImage(
          GlobalController.clientId,
          formData,
        );

        // 打印上传响应信息
        l.d(
          'Image upload response - shortUrl: ${response.shortUrl}, url: ${response.url}',
        );

        uploadedImages.add(response);

        // 将图片插入到内容中，使用 shortUrl 作为标记但在预览时使用完整 url
        final imageMarkdown =
            '\n![${response.originalFilename}|${response.width}x${response.height}](${response.shortUrl})\n';
        final currentContent = contentController.text;
        final cursorPosition = contentController.selection.baseOffset;

        if (cursorPosition >= 0) {
          final newContent =
              currentContent.substring(0, cursorPosition) +
              imageMarkdown +
              currentContent.substring(cursorPosition);
          contentController.text = newContent;
          contentController.selection = TextSelection.collapsed(
            offset: cursorPosition + imageMarkdown.length,
          );
        } else {
          contentController.text += imageMarkdown;
        }
      } catch (e, s) {
        showToast(AppConst.createPost.uploadFailed);
        l.e('Error uploading image: $e -- $s');
      } finally {
        isUploading.value = false;
      }
    }
  }

  // 删除图片
  void removeImage(UploadImageResponse image) {
    uploadedImages.remove(image);
    // 从内容中移除图片引用
    final imagePattern =
        '\\!\\[${image.originalFilename}\\|${image.width}x${image.height}\\]\\(${image.shortUrl}\\)';
    final regex = RegExp(imagePattern);
    contentController.text = contentController.text.replaceAll(regex, '');
  }

  // 发布帖子
  Future<void> publishPost() async {
    if (!validateInputs()) return;

    try {
      isSubmitting.value = true;
      // 构建图片尺寸映射
      final imageSizes = <String, ImageSize>{};
      for (final image in uploadedImages) {
        imageSizes[image.url] = ImageSize(
          width: image.width,
          height: image.height,
        );
      }

      final response = await _apiService.createPost(
        title: titleController.text,
        content: contentController.text,
        categoryId: selectedCategory.value!.id,
        tags: tags,
        imageSizes: imageSizes,
      );

      if (response.success == true) {
        await clearDraft();
        Get.back(result: response);
        showToast(AppConst.createPost.publishSuccess);
      } else {
        showToast(AppConst.createPost.publishFailed);
      }
    } catch (e) {
      showToast(AppConst.createPost.publishFailed);
    } finally {
      isSubmitting.value = false;
    }
  }

  static const _draftKey = 'create_post_draft';

  /// 将当前编辑内容保存为本地草稿
  Future<bool> saveDraft() async {
    final data = <String, dynamic>{
      'title': titleController.text,
      'content': contentController.text,
      'categoryId': selectedCategory.value?.id,
      'categoryName': selectedCategoryName.value,
      'tags': tags,
      'images': uploadedImages
          .map(
            (e) => {
              'url': e.url,
              'shortUrl': e.shortUrl,
              'originalFilename': e.originalFilename,
              'width': e.width,
              'height': e.height,
            },
          )
          .toList(),
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    };
    try {
      await StorageManager.setData(_draftKey, data);
      showToast(AppConst.createPost.draftSuccess);
      return true;
    } catch (e) {
      showToast(AppConst.createPost.draftFailed);
      return false;
    }
  }

  /// 判断是否存在未保存的草稿
  bool hasDraft() => StorageManager.getString(_draftKey) != null;

  /// 加载草稿并填充编辑界面
  void restoreDraft() {
    final jsonString = StorageManager.getString(_draftKey);
    if (jsonString == null) return;
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      titleController.text = data['title'] as String? ?? '';
      contentController.text = data['content'] as String? ?? '';
      final categoryId = data['categoryId'] as int?;
      if (categoryId != null && categories.isNotEmpty) {
        for (final c in categories) {
          if (c.id == categoryId) {
            selectedCategory.value = c;
            break;
          }
        }
      }
      selectedCategoryName.value = data['categoryName'] as String?;
      tags.value = (data['tags'] as List?)?.cast<String>() ?? [];
      final images = data['images'] as List? ?? [];
      uploadedImages.value = images.map((e) {
        final m = (e as Map).cast<String, dynamic>();
        return UploadImageResponse(
          id: 0,
          url: m['url'] as String? ?? '',
          originalFilename: m['originalFilename'] as String? ?? '',
          filesize: 0,
          width: m['width'] as int? ?? 0,
          height: m['height'] as int? ?? 0,
          thumbnailWidth: m['width'] as int? ?? 0,
          thumbnailHeight: m['height'] as int? ?? 0,
          extension: '',
          shortUrl: m['shortUrl'] as String? ?? '',
          shortPath: '',
          humanFilesize: '',
          dominantColor: '',
        );
      }).toList();
    } catch (e) {
      l.e('恢复草稿失败: $e');
    }
  }

  /// 清除草稿（发布成功后调用）
  Future<void> clearDraft() async {
    await StorageManager.remove(_draftKey);
  }

  // 验证输入
  bool validateInputs() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      showToast(AppConst.createPost.previewPost);
      return false;
    }
    return true;
  }

  void toggleEmojiPicker() {
    if (isShowEmojiPicker.value) {
      isShowEmojiPicker.value = false;
      isHideKeyboard.value = false;

      // 检查当前焦点是否在 titleFocusNode 或 contentFocusNode 上
      FocusNode targetFocusNode = focusedInput.value == 'title'
          ? titleFocusNode
          : contentFocusNode;

      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(Get.context!).requestFocus(targetFocusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        isShowEmojiPicker.value = true;
        isHideKeyboard.value = true;
      });
    }
  }
}
