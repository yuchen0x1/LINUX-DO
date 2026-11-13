import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/badge_detail.dart';
import 'package:linux_do/models/request/user_request.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:dio/dio.dart' as dio;

class EditProfileController extends BaseController with ToastMixin {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  // 控制器
  late final TextEditingController nameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController backupEmailController;

  final badges = <BadgeDetail>[].obs;
  final avatarUrl = ''.obs;
  final isSaving = false.obs;
  final linkedAccounts = <Map<String, dynamic>>[].obs;
  final userTitle = ''.obs;
  final isUploading = false.obs;

  // 临时文件
  File? _avatarFile;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _loadUserInfo();
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    backupEmailController.dispose();
    super.onClose();
  }

  void _initControllers() {
    final userInfo = _globalController.userInfo?.user;
    badges.value = (_globalController.userInfo?.badges ?? [])
        .where((badge) => badge.allowTitle == true)
        .toList();

    badges.insert(
      0,
      BadgeDetail(
        id: 0,
        name: '无',
        description: '无',
        grantCount: 0,
        allowTitle: true,
        multipleGrant: false,
        listable: false,
        enabled: false,
        badgeGroupingId: 0,
        system: false,
        slug: '',
        hasBadge: false,
        manuallyGrantable: false,
        showInPostHeader: false,
        badgeTypeId: 0,
      ),
    );

    nameController = TextEditingController(text: userInfo?.name ?? '');
    usernameController = TextEditingController(text: userInfo?.username ?? '');
    userTitle.value = userInfo?.title ?? '';
    emailController = TextEditingController(text: userInfo?.email ?? '');
    backupEmailController = TextEditingController(
      text: userInfo?.secondaryEmails?.firstOrNull ?? '',
    );
  }

  void _loadUserInfo() {
    final userInfo = _globalController.userInfo?.user;
    if (userInfo != null) {
      avatarUrl.value = userInfo.avatarUrl;

      // 获取已关联的账户
      final associatedAccounts = userInfo.associatedAccounts ?? [];

      // 创建所有可能的账户列表
      final allAccounts = [
        {'name': 'google_oauth2'},
        {'name': 'github'},
        {'name': 'twitter'},
        {'name': 'discord'},
      ];

      // 更新账户状态
      linkedAccounts.value = allAccounts.map((account) {
        final existing = associatedAccounts.firstWhereOrNull(
          (a) => a['name'] == account['name'],
        );
        if (existing != null) {
          return existing;
        }
        return account;
      }).toList();
    }
  }

  // 关联三方的账户,
  void linkAccount(String type) {
    const baseUrl = HttpConfig.baseUrl;
    String url = '';
    switch (type) {
      case 'google_oauth2':
        url = '$baseUrl/auth/google_oauth2';
        break;
      case 'github':
        url = '$baseUrl/auth/github';
        break;
      case 'twitter':
        url = '$baseUrl/auth/twitter';
        break;
      case 'discord':
        url = '$baseUrl/auth/discord';
        break;
    }

    if (url.isNotEmpty) {
      Get.toNamed(Routes.WEBVIEW, arguments: url);
    }
  }

  // 解除账户关联
  Future<void> unlinkAccount(String type) async {
    try {
      isSaving.value = true;

      // 调用解除关联的 API
      await _apiService.unlinkAccount(
        _globalController.userInfo?.user?.username ?? '',
        type,
      );

      // 更新关联账户列表
      final index = linkedAccounts.indexWhere(
        (account) => account['name'] == type,
      );
      if (index != -1) {
        linkedAccounts[index] = {'name': type};
      }

      showSuccess('解除关联成功');
    } catch (e) {
      l.e('解除关联失败: $e');
      showError('解除关联失败');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        _avatarFile = File(pickedFile.path);

        // 上传新头像
        if (_avatarFile != null) {
          await _uploadAvatar();
        }
      }
    } catch (e) {
      l.e('选择头像失败: $e');
      showError('选择头像失败');
    }
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final user = _globalController.userInfo?.user;

      // 更新用户信息
      final request = UserRequest(
        name: nameController.text,
        title: userTitle.value,
        primaryGroupId: user?.primaryGroupId ?? 0,
        flairGroupId: user?.flairGroupId ?? 0,
        status: UserStatus(
          description: user?.status?.description ?? '',
          emoji: user?.status?.emoji ?? '',
          endsAt: user?.status?.endsAt,
          messageBusLastId: user?.status?.messageBusLastId ?? 0,
        ),
      );

      await _apiService.updateUser(
        _globalController.userInfo?.user?.username ?? '',
        request,
      );

      // 刷新全局用户信息
      await _globalController.fetchUserInfo();

      showSuccess('保存成功');
      Get.back();
    } catch (e) {
      l.e('保存个人资料失败: $e');
      showError('保存失败');
    } finally {
      isSaving.value = false;
    }
  }

  // 直接更新头像数据
  Future<void> _uploadAvatar() async {
    if (_avatarFile == null) return;

    try {
      isUploading.value = true;
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(_avatarFile!.path),
        'upload_type': 'avatar',
        'user_id': _globalController.userInfo?.user?.id.toString(),
      });

      final response = await _apiService.uploadImage(
        GlobalController.clientId,
        formData,
      );

      // 更新头像URL为上传后的URL
      avatarUrl.value = response.url;

      _updateUserAvatar(response.id);
    } catch (e) {
      l.e('上传头像失败: $e');
      rethrow;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> _updateUserAvatar(int uploadId) async {
    try {
      await _apiService.updateUserAvatar(
        _globalController.userInfo?.user?.username ?? '',
        uploadId: uploadId,
      );

      // 刷新全局用户信息
      await _globalController.fetchUserInfo();
    } catch (e) {
      l.e('更新用户头衔失败: $e');
      showError('更新头衔失败');
    }
  }
}
