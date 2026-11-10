import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/net/share_intent_service.dart';

void main() {
  group('分享内容解析', () {
    test('纯文本进入发帖页，原文保留', () {
      final r = ShareIntentService.classify('今天发现一个很有意思的项目');
      expect(r, isNotNull);
      expect(r!.topicId, isNull);
      expect(r.content, '今天发现一个很有意思的项目');
    });

    test('linux.do 帖子链接直接定位帖子', () {
      final r = ShareIntentService.classify(
        '看看这个 https://linux.do/t/some-title/12345 挺有用',
      );
      expect(r!.topicId, 12345);
      // 原文仍然保留，便于用户在帖子里引用
      expect(r.content, contains('12345'));
    });

    test('链接带查询串与页码也能识别', () {
      final r = ShareIntentService.classify(
        'https://linux.do/t/title/999/5?u=neo',
      );
      expect(r!.topicId, 999);
    });

    test('链接后的中文标点不影响解析', () {
      final r = ShareIntentService.classify('推荐 https://linux.do/t/a/42，很好用');
      expect(r!.topicId, 42);
    });

    test('用户主页链接不当作帖子，转为发帖预填', () {
      final r = ShareIntentService.classify('https://linux.do/u/neo');
      expect(r!.topicId, isNull);
      expect(r.content, contains('linux.do/u/neo'));
    });

    test('非本站链接不识别为帖子', () {
      final r = ShareIntentService.classify('https://example.com/t/a/1');
      expect(r!.topicId, isNull);
    });

    test('空文本返回 null', () {
      expect(ShareIntentService.classify(''), isNull);
      expect(ShareIntentService.classify('   \n  '), isNull);
    });

    test('多行文本完整保留', () {
      const text = '第一行\n第二行 https://linux.do/t/x/7\n第三行';
      final r = ShareIntentService.classify(text);
      expect(r!.topicId, 7);
      expect(r.content, text);
    });

    test('取第一个链接判定，后续链接不覆盖', () {
      final r = ShareIntentService.classify(
        'https://example.com/a https://linux.do/t/b/88',
      );
      // 第一个链接是站外的，按「无法识别」处理
      expect(r!.topicId, isNull);
    });
  });
}
