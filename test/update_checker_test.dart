import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/update_checker.dart';

final _digest = List<String>.filled(64, 'a').join();

Map<String, dynamic> release({String abi = 'arm64-v8a'}) {
  const tag = 'v1.2.0';
  final name = 'linux_do_android_release_1.2.0_$abi.apk';
  return {
    'tag_name': tag,
    'draft': false,
    'prerelease': false,
    'body': 'Release notes',
    'published_at': '2026-11-26T00:00:00Z',
    'assets': [
      {
        'name': name,
        'browser_download_url':
            'https://github.com/yuchen0x1/LINUX-DO/releases/download/$tag/$name',
        'digest': 'sha256:$_digest',
        'size': 1024,
      },
    ],
  };
}

void main() {
  group('版本比较', () {
    test('补丁版本更高时判定有更新', () {
      expect(UpdateChecker.isNewer('1.0.10', '1.0.9'), isTrue);
    });

    test('相同版本不算更新', () {
      expect(UpdateChecker.isNewer('1.0.9', '1.0.9'), isFalse);
    });

    test('旧版本不算更新', () {
      expect(UpdateChecker.isNewer('1.0.8', '1.0.9'), isFalse);
    });

    test('位数不同时按缺位补零比较', () {
      expect(UpdateChecker.isNewer('1.1', '1.0.9'), isTrue);
      expect(UpdateChecker.isNewer('1.0', '1.0.0'), isFalse);
    });

    test('忽略 build number 与预发布后缀', () {
      expect(UpdateChecker.isNewer('1.2.0+11', '1.2.0+9'), isFalse);
      expect(UpdateChecker.isNewer('1.2.0-beta', '1.1.0'), isTrue);
    });

    test('数值比较而非字符串比较（1.10 > 1.9）', () {
      expect(UpdateChecker.isNewer('1.10.0', '1.9.0'), isTrue);
    });
  });

  group('下载地址可信度', () {
    test('当前仓库的正式版 APK 地址受信任', () {
      expect(
        UpdateChecker.isTrustedDownload(
          'https://github.com/yuchen0x1/LINUX-DO/releases/download/v1.2.0/app.apk',
        ),
        isTrue,
      );
    });

    test('拒绝其他仓库和不完整的版本标签', () {
      expect(
        UpdateChecker.isTrustedDownload(
          'https://github.com/other/LINUX-DO/releases/download/v1.2.0/app.apk',
        ),
        isFalse,
      );
      expect(
        UpdateChecker.isTrustedDownload(
          'https://github.com/yuchen0x1/LINUX-DO/releases/download/v2/app.apk',
        ),
        isFalse,
      );
    });

    test('拒绝直接的 GitHub 对象存储地址', () {
      expect(
        UpdateChecker.isTrustedDownload(
          'https://objects.githubusercontent.com/abc/app.apk',
        ),
        isFalse,
      );
    });

    test('拒绝任意域名', () {
      expect(
        UpdateChecker.isTrustedDownload('https://evil.example.com/app.apk'),
        isFalse,
      );
    });

    test('拒绝 http 明文', () {
      expect(
        UpdateChecker.isTrustedDownload('http://github.com/app.apk'),
        isFalse,
      );
    });

    test('拒绝畸形地址', () {
      expect(UpdateChecker.isTrustedDownload('not a url'), isFalse);
    });
  });

  group('正式版更新发现', () {
    test('已发布的旧版本可发现新版本及对应架构 APK', () {
      for (final current in [
        '1.1.0',
        '1.1.1',
        '1.1.2',
        '1.1.3',
        '1.1.4',
      ]) {
        final update = UpdateChecker.parseRelease(
          release(),
          currentVersion: current,
          supportedAbis: ['arm64-v8a', 'armeabi-v7a'],
        );
        expect(update, isNotNull);
        expect(update!.latestVersion, '1.2.0');
        expect(update.sha256, _digest);
        expect(update.downloadUrl, endsWith('_arm64-v8a.apk'));
      }
    });

    test('选择设备支持的架构', () {
      final update = UpdateChecker.parseRelease(
        release(abi: 'x86_64'),
        currentVersion: '1.1.4',
        supportedAbis: ['x86_64'],
      );
      expect(update!.downloadUrl, endsWith('_x86_64.apk'));
      expect(
        UpdateChecker.parseRelease(
          release(abi: 'x86_64'),
          currentVersion: '1.1.4',
          supportedAbis: ['arm64-v8a'],
        ),
        isNull,
      );
    });

    test('相同版本、草稿和预发布版本不提示更新', () {
      expect(
        UpdateChecker.parseRelease(
          release(),
          currentVersion: '1.2.0',
          supportedAbis: ['arm64-v8a'],
        ),
        isNull,
      );
      for (final flag in ['draft', 'prerelease']) {
        final data = release();
        data[flag] = true;
        expect(
          UpdateChecker.parseRelease(
            data,
            currentVersion: '1.1.4',
            supportedAbis: ['arm64-v8a'],
          ),
          isNull,
        );
      }
    });

    test('缺少摘要或下载地址标签不匹配时拒绝更新', () {
      for (final changes in [
        {'digest': null},
        {'digest': 'sha256:invalid'},
        {'size': 0},
        {
          'browser_download_url':
              'https://github.com/yuchen0x1/LINUX-DO/releases/download/v1.1.4/app.apk',
        },
      ]) {
        final data = release();
        (data['assets'] as List).single.addAll(changes);
        expect(
          UpdateChecker.parseRelease(
            data,
            currentVersion: '1.1.4',
            supportedAbis: ['arm64-v8a'],
          ),
          isNull,
        );
      }
    });
  });
}
