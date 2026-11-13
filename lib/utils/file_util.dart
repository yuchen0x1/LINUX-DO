import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class FileUtil {
  /// 获取应用文档目录
  static Future<Directory> getDocumentDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取应用缓存目录
  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// 获取文件大小
  static Future<String> getFileSize(String path, {int decimals = 2}) async {
    var file = File(path);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// 获取文件MIME类型
  static String? getMimeType(String path) {
    return lookupMimeType(path);
  }

  /// 创建文件
  static Future<File> createFile(String path) async {
    return await File(path).create(recursive: true);
  }

  /// 删除文件
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 复制文件
  static Future<File> copyFile(String sourcePath, String targetPath) async {
    final sourceFile = File(sourcePath);
    return await sourceFile.copy(targetPath);
  }

  /// 移动文件
  static Future<File> moveFile(String sourcePath, String targetPath) async {
    final sourceFile = File(sourcePath);
    return await sourceFile.rename(targetPath);
  }

  /// 读取文件内容
  static Future<String> readAsString(String path) async {
    final file = File(path);
    return await file.readAsString();
  }

  /// 写入文件内容
  static Future<File> writeAsString(String path, String content) async {
    final file = File(path);
    return await file.writeAsString(content);
  }

  /// 清空缓存
  static Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// 获取缓存大小
  static Future<String> getCacheSize({int decimals = 2}) async {
    final cacheDir = await getCacheDirectory();
    if (!await cacheDir.exists()) return "0 B";

    int size = 0;
    try {
      await for (var entity in cacheDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      print(e.toString());
    }

    if (size <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(size) / log(1024)).floor();
    return '${(size / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
