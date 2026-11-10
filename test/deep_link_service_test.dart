import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/deep_link_service.dart';

void main() {
  final service = DeepLinkService();

  group('帖子链接', () {
    test('/t/slug/id 解析出 topicId', () {
      final r = service.resolve(
        Uri.parse('https://linux.do/t/some-title/12345'),
      );
      expect(r, isNotNull);
      expect(r!.name, DeepLinkService.routeTopicDetail);
      expect(r.argument, 12345);
    });

    test('/t/id 单段也解析', () {
      final r = service.resolve(Uri.parse('https://linux.do/t/678'));
      expect(r!.argument, 678);
    });

    test('带页码与查询参数不影响解析', () {
      final r = service.resolve(
        Uri.parse('https://linux.do/t/title/999/5?u=someone'),
      );
      expect(r!.argument, 999);
    });

    test('www 前缀同样支持', () {
      final r = service.resolve(Uri.parse('https://www.linux.do/t/a/42'));
      expect(r!.argument, 42);
    });
  });

  group('用户与分类', () {
    test('/u/username 解析', () {
      final r = service.resolve(Uri.parse('https://linux.do/u/neo'));
      expect(r!.name, DeepLinkService.routePersonal);
      expect(r.argument, 'neo');
    });

    test('/c/slug/id 解析', () {
      final r = service.resolve(Uri.parse('https://linux.do/c/dev/7'));
      expect(r!.name, DeepLinkService.routeCategory);
      expect(r.argument, 7);
    });
  });

  group('自定义 scheme', () {
    test('linuxdo://topic/123 解析', () {
      final r = service.resolve(Uri.parse('linuxdo://topic/123'));
      expect(r!.argument, 123);
    });

    test('授权回调不接管（交给 WebPage 处理）', () {
      final r = service.resolve(
        Uri.parse('linuxdo://auth/callback?payload=abc'),
      );
      expect(r, isNull);
    });
  });

  group('不抢占无关链接', () {
    test('其他域名忽略', () {
      expect(service.resolve(Uri.parse('https://example.com/t/a/1')), isNull);
    });

    test('首页忽略', () {
      expect(service.resolve(Uri.parse('https://linux.do/')), isNull);
    });

    test('非法 id 忽略', () {
      expect(service.resolve(Uri.parse('https://linux.do/t/a/b')), isNull);
    });

    test('非 http(s)/linuxdo scheme 忽略', () {
      expect(service.resolve(Uri.parse('ftp://linux.do/t/a/1')), isNull);
    });
  });
}