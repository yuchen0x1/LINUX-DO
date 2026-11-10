import 'dart:io';
import 'dart:typed_data';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/log.dart';
import '../utils/mixins/toast_mixin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dis_button.dart';

class ImagePreviewDialog extends StatelessWidget with ToastMixin {
  final String imageUrl;
  final String? heroTag;

  const ImagePreviewDialog({
    Key? key,
    required this.imageUrl,
    this.heroTag,
  }) : super(key: key);

  // 将缩略图URL转换为原图URL
  String _getOriginalImageUrl(String url) {
    if (url.contains('/optimized/')) {
      return url
          .replaceFirst('/optimized/', '/original/')
          .replaceAll(RegExp(r'_\d+_\d+x\d+'), '');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    // 获取原图URL
    final originalImageUrl = _getOriginalImageUrl(imageUrl);
    l.d('Original image URL: $originalImageUrl');

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片预览
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            onLongPress: () => _showSaveOptions(context),
            child: Container(
              color: Colors.black87,
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(
                  originalImageUrl,
                  maxWidth: 2048,
                  maxHeight: 2048,
                ),
                loadingBuilder: (context, event) => Center(
                  child: DisRefreshLoading(),
                ),
                errorBuilder: (context, error, stackTrace) {
                  l.e('图片加载失败: $error');
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 40.w,
                        ),
                        8.vGap,
                        Text(
                          '加载失败',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                heroAttributes: heroTag != null
                    ? PhotoViewHeroAttributes(tag: heroTag!)
                    : null,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          // 关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.w,
            right: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.w),
                child: Text(
                  '保存图片',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // 选项列表
              ListTile(
                leading: Icon(
                  CupertinoIcons.photo_fill_on_rectangle_fill,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('保存到相册'),
                onTap: () {
                  Navigator.pop(context);
                  _saveToGallery(_getOriginalImageUrl(imageUrl));
                },
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.folder_solid,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('保存到文件'),
                onTap: () {
                  Navigator.pop(context);
                  _saveToFile(_getOriginalImageUrl(imageUrl));
                },
              ),
              // 取消按钮
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.w),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAppSettings() async {
    if (Platform.isIOS) {
      final url = Uri.parse('app-settings:');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      await openAppSettings();
    }
  }

  Future<void> _saveToGallery(String imageUrl) async {
    try {
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photos.status;
        l.d('Initial photos permission status: $status');

        if (status.isPermanentlyDenied) {
          _showSettingsDialog();
          return;
        } else if (status.isDenied) {
          status = await Permission.photos.request();
        }
      } else {
        status = await Permission.storage.status;
        l.d('Initial storage permission status: $status');

        if (status.isPermanentlyDenied) {
          _showSettingsDialog();
          return;
        } else if (status.isDenied) {
          status = await Permission.storage.request();
          l.d('After request, permission status: $status');
        }
      }

      if (status.isGranted || (Platform.isIOS && status.isLimited)) {
        l.d('Permission is granted or limited, proceeding to save');
        try {
          final response = await Dio().get(
            imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data),
            quality: 100,
          );
          l.d('Save result: $result');
          if (result['isSuccess']) {
            showSuccess('图片已保存到相册');
          } else {
            showError('保存失败');
          }
        } catch (e) {
          l.e('Error saving image: $e');
          showError('保存失败');
        }
      } else {
        showError('没有权限');
      }
    } catch (e) {
      l.e('Error in _saveToGallery: $e');
      showError('保存失败');
    }
  }

  void _showSettingsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!)
                      .primaryColor
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Platform.isIOS ? CupertinoIcons.photo : Icons.photo_library,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 32.w,
                ),
              ),
              16.vGap,
              Text(
                '需要权限',
                style: TextStyle(
                  fontSize: 18.w,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).textTheme.titleLarge?.color,
                ),
              ),
              12.vGap,
              Text(
                '保存图片需要访问${Platform.isIOS ? "相册" : "存储"}权限，\n请在设置中开启权限',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
              24.vGap,
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.w,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          backgroundColor: Theme.of(Get.context!)
                              .primaryColor
                              .withValues(alpha: 0.1),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.hGap,
                  Expanded(
                    child: SizedBox(
                      height: 44.w,
                      child: TextButton(
                        onPressed: () async {
                          Get.back();
                          if (Platform.isIOS) {
                            final url = Uri.parse('app-settings:');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          } else {
                            await openAppSettings();
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          backgroundColor: Theme.of(Get.context!).primaryColor,
                        ),
                        child: Text(
                          '去设置',
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _saveToFile(String imageUrl) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          // 从 URL 中获取文件名
          String fileName = imageUrl.split('/').last;
          if (!fileName.contains('.')) {
            fileName = '$fileName.jpg';
          }

          // 让用户选择保存位置
          String? selectedDirectory =
              await FilePicker.platform.getDirectoryPath();
          if (selectedDirectory == null) {
            print('User cancelled directory selection');
            return;
          }

          // 下载图片
          final response = await Dio().get(
            imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          // iOS 获取 documents 目录
          Directory? directory;
          if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
            selectedDirectory = directory.path;
          }

          // 保存文件
          final file = File('$selectedDirectory/$fileName');
          await file.writeAsBytes(response.data);

          // 显示成功信息
          if (Platform.isIOS) {
            // iOS 需要将文件保存到相册后删除临时文件
            final result = await ImageGallerySaver.saveFile(file.path);
            if (result['isSuccess']) {
              Get.snackbar('成功', '图片已保存到相册');
            } else {
              Get.snackbar('错误', '保存失败');
            }
            await file.delete();
          } else {
            Get.snackbar('成功', '图片已保存到: ${file.path}');
          }
        } catch (e) {
          print('Error saving file: $e');
          Get.snackbar('错误', '保存文件失败');
        }
      } else if (status.isPermanentlyDenied) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('需要权限'),
            content: const Text('保存文件需要存储权限，请在设置中开启。'),
            actions: [
              DisButton(
                onPressed: () => Get.back(result: false),
                text: '取消',
              ),
              DisButton(
                onPressed: () {
                  Get.back(result: true);
                  _openAppSettings();
                },
                text: '去设置',
              ),
            ],
          ),
        );
        if (result == true) {
          print('User directed to settings to enable storage permission');
        } else {
          print('User cancelled permission request');
        }
      } else {
        Get.snackbar('错误', '无法获取存储权限');
        print('Storage permission denied: $status');
      }
    } catch (e) {
      print('Error in _saveToFile: $e');
      Get.snackbar('错误', '保存文件失败');
    }
  }
}

/// 显示图片预览弹窗的便捷方法
void showImagePreview(BuildContext context, String imageUrl,
    {String? heroTag}) {
  l.d('showImagePreview: $imageUrl');
  showDialog(
    context: context,
    builder: (context) => ImagePreviewDialog(
      imageUrl: imageUrl,
      heroTag: heroTag,
    ),
  );
}
