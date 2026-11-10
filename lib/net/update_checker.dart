import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version.dart';
import 'http_config.dart';
import '../utils/log.dart';

/// 应用更新检查。
///
/// 主源为 GitHub Releases（仓库公开、无需自建服务），失败时回退到旧的自建
/// 接口 `HttpConfig.otherUrl`。两者都不可用则静默跳过——更新提示属于锦上添花，
/// 不应该在启动时打扰用户或阻塞任何流程。
///
/// 注意：这里只负责「发现有新版本并给出下载地址」，不做静默安装。
/// 安装交给系统（下载后用 url_launcher 打开），因此必须保证下载地址来自可信域名。
class UpdateChecker {
  static const String owner = 'yuchen0x1';
  static const String repo = 'LINUX-DO';

  static const String _githubApi =
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  /// 允许的下载域名：只有这些域名下的链接才会被交给系统浏览器打开
  static const Set<String> trustedDownloadHosts = {
    'github.com',
    'objects.githubusercontent.com',
    'github-releases.githubusercontent.com',
    'raw.githubusercontent.com',
  };

  /// 检查更新。返回 null 表示「无更新 / 检查失败」。
  static Future<AppVersion?> check() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    final fromGithub = await _checkGithub(currentVersion);
    if (fromGithub != null) return fromGithub;

    return _checkLegacy(currentVersion, info.buildNumber);
  }

  /// GitHub Releases：/releases/latest 只返回最新正式版，天然排除 draft/prerelease。
  static Future<AppVersion?> _checkGithub(String currentVersion) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github+json'},
        ),
      );

      final resp = await dio.get<dynamic>(_githubApi);
      if (resp.statusCode != 200 || resp.data is! Map) return null;

      final data = resp.data as Map<String, dynamic>;
      final tag = (data['tag_name'] as String? ?? '').trim();
      if (tag.isEmpty) return null;

      final latest = tag.startsWith('v') ? tag.substring(1) : tag;
      if (!isNewer(latest, currentVersion)) return null;

      // 优先挑 arm64/universal 的 apk 资产
      final apkUrl = _pickApk(data['assets']);
      if (apkUrl == null) {
        l.w('GitHub Release $tag 没有可用的 APK 资产');
        return null;
      }

      return AppVersion(
        hasUpdate: true,
        latestVersion: latest,
        downloadUrl: apkUrl,
        releaseNotes: data['body'] as String?,
        isForceUpdate: false,
      );
    } catch (e) {
      l.d('GitHub 更新检查失败: $e');
      return null;
    }
  }

  static String? _pickApk(dynamic assets) {
    if (assets is! List) return null;

    String? fallback;
    for (final asset in assets) {
      if (asset is! Map) continue;
      final name = (asset['name'] as String? ?? '').toLowerCase();
      final url = asset['browser_download_url'] as String?;
      if (url == null || !name.endsWith('.apk')) continue;

      if (name.contains('arm64') || name.contains('universal')) return url;
      fallback ??= url;
    }
    return fallback;
  }

  /// 回退到自建接口（接口已失效时静默返回 null）
  static Future<AppVersion?> _checkLegacy(
    String currentVersion,
    String buildNumber,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final code = int.tryParse(buildNumber) ?? 0;

      const base = HttpConfig.otherUrl;
      if (base.isEmpty) return null;

      final resp = await dio.get<dynamic>(
        '$base/api/version/check/Android',
        queryParameters: {
          'current_version': currentVersion,
          'current_version_code': code,
        },
      );
      if (resp.statusCode != 200 || resp.data is! Map) return null;

      final map = resp.data as Map<String, dynamic>;
      if (map['has_update'] == false) return null;
      return AppVersion.fromJson(map);
    } catch (e) {
      l.d('自建更新接口不可用: $e');
      return null;
    }
  }

  /// 语义化版本比较：a 是否比 b 新
  static bool isNewer(String a, String b) {
    final pa = _parse(a);
    final pb = _parse(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  static List<int> _parse(String v) {
    final core = v.split('+').first.split('-').first;
    return core
        .split('.')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .toList();
  }

  /// 下载链接是否来自可信域名
  static bool isTrustedDownload(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isScheme('https')) return false;
    return trustedDownloadHosts.contains(uri.host);
  }
}
