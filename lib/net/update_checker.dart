import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version.dart';
import '../utils/storage_manager.dart';

class ReleaseUpdate extends AppVersion {
  ReleaseUpdate({
    required String version,
    required String url,
    required this.sha256,
    required this.size,
    required this.currentVersion,
    required this.releaseUrl,
    this.publishedAt,
    String? notes,
  }) : super(
         hasUpdate: true,
         latestVersion: version,
         downloadUrl: url,
         releaseNotes: notes,
         isForceUpdate: false,
       );
  final String sha256;
  final int size;
  final String currentVersion;
  final String releaseUrl;
  final DateTime? publishedAt;
}

class UpdatePreferences {
  static const frequencyKey = 'update.interval_hours';
  static const lastCheckKey = 'update.last_check';
  static const deferredVersionKey = 'update.deferred_version';
  static const deferredUntilKey = 'update.deferred_until';
  static int get intervalHours =>
      StorageManager.getInt(frequencyKey, defaultValue: 24)!;
  static bool shouldCheck(DateTime now) {
    if (intervalHours == 0) return false;
    final last = StorageManager.getInt(lastCheckKey);
    return last == null ||
        now.millisecondsSinceEpoch - last >=
            Duration(hours: intervalHours).inMilliseconds;
  }

  static bool isDeferred(String version, DateTime now) =>
      StorageManager.getString(deferredVersionKey) == version &&
      (StorageManager.getInt(deferredUntilKey) ?? 0) >
          now.millisecondsSinceEpoch;
  static Future<void> defer(String version, {DateTime? now}) async {
    await StorageManager.setData(deferredVersionKey, version);
    await StorageManager.setData(
      deferredUntilKey,
      (now ?? DateTime.now())
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch,
    );
  }
}

/// Discovery uses public GitHub metadata only, without forum credentials.
class UpdateChecker {
  static const owner = 'yuchen0x1';
  static const repo = 'LINUX-DO';
  static const releasesUrl = 'https://github.com/$owner/$repo/releases';
  static const githubApi =
      'https://api.github.com/repos/$owner/$repo/releases/latest';
  static Future<ReleaseUpdate?> check({bool automatic = true}) async {
    await StorageManager.init();
    final now = DateTime.now();
    if (automatic && !UpdatePreferences.shouldCheck(now)) return null;
    final info = await PackageInfo.fromPlatform();
    final device = await DeviceInfoPlugin().androidInfo;
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: false,
        headers: {'Accept': 'application/vnd.github+json'},
      ),
    );
    try {
      final response = await dio.get<Map<String, dynamic>>(githubApi);
      final update = parseRelease(
        response.data!,
        currentVersion: info.version,
        supportedAbis: device.supportedAbis,
      );
      await StorageManager.setData(
        UpdatePreferences.lastCheckKey,
        now.millisecondsSinceEpoch,
      );
      if (automatic &&
          update != null &&
          UpdatePreferences.isDeferred(update.latestVersion!, now))
        return null;
      return update;
    } finally {
      dio.close(force: true);
    }
  }

  static ReleaseUpdate? parseRelease(
    Map<String, dynamic> data, {
    required String currentVersion,
    required List<String> supportedAbis,
  }) {
    if (data['draft'] != false || data['prerelease'] != false) return null;
    final tag = data['tag_name'];
    if (tag is! String || !RegExp(r'^v?\d+\.\d+\.\d+$').hasMatch(tag))
      return null;
    final latest = tag.replaceFirst(RegExp('^v'), '');
    if (!isNewer(latest, currentVersion)) return null;
    final assets = data['assets'];
    if (assets is! List) return null;
    for (final abi in [...supportedAbis, 'universal']) {
      if (!['arm64-v8a', 'armeabi-v7a', 'x86_64', 'universal'].contains(abi))
        continue;
      for (final asset in assets) {
        if (asset is! Map) continue;
        final name = asset['name'];
        final url = asset['browser_download_url'];
        final digest = asset['digest'];
        final size = asset['size'];
        if (name is! String ||
            !RegExp('(?:^|[_-])${RegExp.escape(abi)}\\.apk\$').hasMatch(name) ||
            url is! String ||
            !isTrustedDownload(url) ||
            Uri.parse(url).pathSegments[4] != tag ||
            digest is! String ||
            !RegExp(r'^sha256:[a-fA-F0-9]{64}$').hasMatch(digest) ||
            size is! int ||
            size <= 0 ||
            size > 150 * 1024 * 1024)
          continue;
        return ReleaseUpdate(
          version: latest,
          url: url,
          sha256: digest.substring(7).toLowerCase(),
          size: size,
          currentVersion: currentVersion,
          releaseUrl: '$releasesUrl/tag/${Uri.encodeComponent(tag)}',
          publishedAt: DateTime.tryParse(data['published_at'] as String? ?? ''),
          notes: data['body'] is String ? data['body'] as String : null,
        );
      }
    }
    return null;
  }

  static bool isNewer(String a, String b) {
    List<int>? parse(String value) {
      if (!RegExp(r'^\d+(?:\.\d+){0,2}(?:[+-][a-zA-Z0-9.+-]+)?$')
          .hasMatch(value))
        return null;
      return value
          .split(RegExp('[+-]'))
          .first
          .split('.')
          .map(int.parse)
          .toList();
    }

    final left = parse(a);
    final right = parse(b);
    if (left == null || right == null) return false;
    for (var i = 0; i < 3; i++) {
      final x = i < left.length ? left[i] : 0;
      final y = i < right.length ? right[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  static bool isTrustedDownload(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'github.com' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        uri.hasQuery ||
        uri.hasFragment)
      return false;
    final parts = uri.pathSegments;
    return parts.length == 6 &&
        parts[0] == owner &&
        parts[1] == repo &&
        parts[2] == 'releases' &&
        parts[3] == 'download' &&
        RegExp(r'^v?\d+\.\d+\.\d+$').hasMatch(parts[4]) &&
        parts[5].endsWith('.apk');
  }
}
