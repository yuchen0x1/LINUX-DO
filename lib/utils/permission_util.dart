import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// 检查权限
  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// 请求权限
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// 检查并请求权限
  static Future<bool> checkAndRequestPermission(Permission permission) async {
    if (await checkPermission(permission)) {
      return true;
    }
    return await requestPermission(permission);
  }

  /// 打开应用设置
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// 检查相机权限
  static Future<bool> checkCameraPermission() async {
    return await checkAndRequestPermission(Permission.camera);
  }

  /// 检查相册权限
  static Future<bool> checkPhotosPermission() async {
    return await checkAndRequestPermission(Permission.photos);
  }

  /// 检查存储权限
  static Future<bool> checkStoragePermission() async {
    return await checkAndRequestPermission(Permission.storage);
  }

  /// 检查定位权限
  static Future<bool> checkLocationPermission() async {
    return await checkAndRequestPermission(Permission.location);
  }

  /// 检查麦克风权限
  static Future<bool> checkMicrophonePermission() async {
    return await checkAndRequestPermission(Permission.microphone);
  }

  /// 检查联系人权限
  static Future<bool> checkContactsPermission() async {
    return await checkAndRequestPermission(Permission.contacts);
  }
}
