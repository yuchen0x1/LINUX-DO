import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/request/user_preferences_request.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';

import '../../models/badge_detail.dart';

class ProfileSettingsController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  final introduction = ''.obs;
  final location = ''.obs;
  final website = ''.obs;
  final profileTitle = ''.obs;
  final cardBackground = ''.obs;
  final featuredTopic = ''.obs;
  final cardBadge = ''.obs;
  final birthDate = ''.obs;
  final signature = ''.obs;
  final telegramChatId = ''.obs;
  final enableSignatureFlag = false.obs;
  final timezone = ''.obs;
  final region = ''.obs;

  final selectedTimezone = ''.obs;
  final profileTitleImage = Rxn<String>();
  final cardBackgroundImage = Rxn<String>();
  final isUploadingProfileTitle = false.obs;
  final isUploadingCardBackground = false.obs;
  final selectedBadge = Rxn<BadgeDetail>();

  // 徽章列表
  final badges = <BadgeDetail>[].obs;

  // 时区列表
  final timezones = ['Asia/Shanghai', 'Asia/Tokyo'];

  @override
  void onInit() {
    super.onInit();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      isLoading.value = true;
      final userInfo = _globalController.userInfo;
      if (userInfo != null) {
        final user = userInfo.user;
        if (user != null) {}
      }
    } catch (e) {
      l.e('加载用户偏好设置失败: $e');
      showError('加载用户偏好设置失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 上传图片
  Future<void> uploadImage(ImageSource source, bool isProfileTitle) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        if (isProfileTitle) {
          isUploadingProfileTitle.value = true;
        } else {
          isUploadingCardBackground.value = true;
        }

        final file = File(pickedFile.path);
        final formData = dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(file.path),
          'type': isProfileTitle ? 'profile_title' : 'card_background',
        });

        final response = await _apiService.uploadImage(
          GlobalController.clientId,
          formData,
        );

        if (isProfileTitle) {
          profileTitleImage.value = response.url;
        } else {
          cardBackgroundImage.value = response.url;
        }

        showSuccess('上传成功');
      }
    } catch (e) {
      l.e('上传图片失败: $e');
      showError('上传失败');
    } finally {
      if (isProfileTitle) {
        isUploadingProfileTitle.value = false;
      } else {
        isUploadingCardBackground.value = false;
      }
    }
  }

  // URL验证
  bool isValidUrl(String url) {
    if (url.isEmpty) return true;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  void updateTimezone(String? newTimezone) {
    if (newTimezone != null) {
      selectedTimezone.value = newTimezone;
      timezone.value = newTimezone;
    }
  }

  // 预览图片
  void previewImage(String? imageUrl) {
    if (imageUrl != null) {
      Get.dialog(
        Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> savePreferences() async {
    try {
      isLoading.value = true;
      final request = UserPreferencesRequest();

      await _apiService.updateUserPreferences(userName, request);
      await _globalController.fetchUserInfo();
      showSuccess('保存成功');
      Get.back();
    } catch (e) {
      l.e('保存用户偏好设置失败: $e');
      showError('保存失败');
    } finally {
      isLoading.value = false;
    }
  }
}
