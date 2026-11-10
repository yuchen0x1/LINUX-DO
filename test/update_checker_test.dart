import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/update_checker.dart';

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
    test('GitHub 域名受信任', () {
      expect(
        UpdateChecker.isTrustedDownload(
          'https://github.com/yuchen0x1/LINUX-DO/releases/download/v2/app.apk',
        ),
        isTrue,
      );
    });

    test('objects.githubusercontent.com 受信任', () {
      expect(
        UpdateChecker.isTrustedDownload(
          'https://objects.githubusercontent.com/abc/app.apk',
        ),
        isTrue,
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
}