import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linux_do/models/topic_model.dart';

/// API 契约测试。
///
/// 目的不是覆盖业务逻辑，而是锁住**服务端 JSON 字段名 → 模型字段**的映射。
/// Discourse 升级、或我们手改 `@JsonKey` 时，这类测试会立刻失败，比等到线上
/// 页面空白才发现要早得多。
///
/// 这里用的是按真实 Discourse `/latest.json` 形状裁剪过的固定样本，
/// 不发起任何网络请求。
void main() {
  group('TopicListResponse 契约', () {
    const sample = '''
{
  "users": [
    {
      "id": 42,
      "username": "neo",
      "name": "Neo",
      "avatar_template": "/user_avatar/linux.do/neo/{size}/123_2.png",
      "trust_level": 3
    }
  ],
  "topic_list": {
    "topics": [
      {
        "id": 12345,
        "title": "示例主题标题",
        "fancy_title": "示例主题<em>标题</em>",
        "slug": "example-topic",
        "posts_count": 17,
        "reply_count": 12,
        "highest_post_number": 17,
        "created_at": "2026-11-01T08:00:00.000Z",
        "last_posted_at": "2026-11-09T10:30:00.000Z",
        "bumped_at": "2026-11-09T10:30:00.000Z",
        "archetype": "regular",
        "unseen": true,
        "pinned": false,
        "excerpt": "一段摘要",
        "visible": true,
        "closed": false,
        "archived": false,
        "tags": ["闲聊", "技术"],
        "views": 1024,
        "like_count": 56,
        "has_summary": false,
        "last_poster_username": "trinity",
        "category_id": 4,
        "pinned_globally": false,
        "has_accepted_answer": false
      }
    ]
  }
}
''';

    test('顶层与 topic_list 字段可解析', () {
      final json = jsonDecode(sample) as Map<String, dynamic>;
      final response = TopicListResponse.fromJson(json);

      expect(response.users, isNotNull);
      expect(response.users!.length, 1);
      expect(response.topicList, isNotNull);
      expect(response.topicList!.topics, isNotNull);
      expect(response.topicList!.topics.length, 1);
    });

    test('User 的 snake_case 字段映射正确', () {
      final json = jsonDecode(sample) as Map<String, dynamic>;
      final user = TopicListResponse.fromJson(json).users!.first;

      expect(user.id, 42);
      expect(user.username, 'neo');
      expect(user.name, 'Neo');
      expect(user.trustLevel, 3);
      // avatar_template 需要 {size} 替换后才能拼成可用 URL
      expect(user.avatarTemplate, contains('{size}'));
      expect(user.avatarUrl, isNot(contains('{size}')));
      expect(user.avatarUrl, contains('/123_2.png'));
    });

    test('Topic 的计数与布尔字段映射正确', () {
      final json = jsonDecode(sample) as Map<String, dynamic>;
      final topic = TopicListResponse.fromJson(json).topicList!.topics.first;

      expect(topic.id, 12345);
      expect(topic.title, '示例主题标题');
      expect(topic.fancyTitle, contains('<em>'));
      expect(topic.slug, 'example-topic');
      expect(topic.postsCount, 17);
      expect(topic.replyCount, 12);
      expect(topic.highestPostNumber, 17);
      expect(topic.categoryId, 4);
      expect(topic.views, 1024);
      expect(topic.likeCount, 56);
      expect(topic.lastPosterUsername, 'trinity');
    });

    test('列表与可空字段映射正确', () {
      final json = jsonDecode(sample) as Map<String, dynamic>;
      final topic = TopicListResponse.fromJson(json).topicList!.topics.first;

      expect(topic.tags, ['闲聊', '技术']);
      expect(topic.pinned, isFalse);
      expect(topic.closed, isFalse);
      expect(topic.archived, isFalse);
      expect(topic.hasAcceptedAnswer, isFalse);
      expect(topic.archetype, 'regular');
      expect(topic.excerpt, '一段摘要');
    });

    test('缺省字段不抛异常（服务端裁剪过 payload 的场景）', () {
      final minimal =
          jsonDecode('''
      {
        "topic_list": {
          "topics": [{"id": 1, "title": "最小主题"}]
        }
      }
      ''')
              as Map<String, dynamic>;

      final response = TopicListResponse.fromJson(minimal);
      final topic = response.topicList!.topics.first;

      expect(topic.id, 1);
      expect(topic.title, '最小主题');
      expect(topic.postsCount, isNull);
      expect(topic.tags, isNull);
      expect(response.users, isNull);
    });
  });

  group('findUserById 契约', () {
    test('命中时返回对应用户', () {
      final json =
          jsonDecode('''
      {
        "users": [{"id": 7, "username": "seven"}],
        "topic_list": {"topics": []}
      }
      ''')
              as Map<String, dynamic>;
      final response = TopicListResponse.fromJson(json);

      expect(response.findUserById(7)?.username, 'seven');
    });

    test('未命中时返回空占位而不抛异常', () {
      final json =
          jsonDecode('''
      {
        "users": [{"id": 7, "username": "seven"}],
        "topic_list": {"topics": []}
      }
      ''')
              as Map<String, dynamic>;
      final response = TopicListResponse.fromJson(json);

      final missing = response.findUserById(999);
      expect(missing, isNotNull);
      expect(missing!.id, 0);
      expect(missing.username, '');
    });
  });
}
