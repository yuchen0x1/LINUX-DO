import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'user_action.g.dart';

@JsonSerializable()
class UserActionResponse {
  @JsonKey(name: 'user_actions')
  final List<UserAction> userActions;

  UserActionResponse({
    required this.userActions,
  });

  factory UserActionResponse.fromJson(Map<String, dynamic> json) =>
      _$UserActionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserActionResponseToJson(this);
}

@JsonSerializable()
class UserAction {
  @JsonKey(name: 'excerpt', defaultValue: '')
  final String? excerpt;
  @JsonKey(name: 'action_type', defaultValue: 0)
  final int? actionType;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String? createdAt;
  @JsonKey(name: 'avatar_template', defaultValue: '')
  final String? avatarTemplate;
  @JsonKey(name: 'acting_avatar_template', defaultValue: '')
  final String? actingAvatarTemplate;
  @JsonKey(name: 'slug', defaultValue: '')
  final String? slug;
  @JsonKey(name: 'topic_id')
  final int? topicId;
  @JsonKey(name: 'target_user_id')
  final int? targetUserId;
  @JsonKey(name: 'target_name', defaultValue: '')
  final String targetName;
  @JsonKey(name: 'target_username', defaultValue: '')
  final String targetUsername;
  @JsonKey(name: 'post_number')
  final int? postNumber;
  @JsonKey(name: 'post_id')
  final int? postId;
  @JsonKey(name: 'reply_to_post_number')
  final int? replyToPostNumber;
  @JsonKey(name: 'username', defaultValue: '')
  final String? username;
  @JsonKey(name: 'name', defaultValue: '')
  final String? name;
  @JsonKey(name: 'user_id', defaultValue: 0)
  final int? userId;
  @JsonKey(name: 'acting_username', defaultValue: '')
  final String? actingUsername;
  @JsonKey(name: 'acting_name', defaultValue: '')
  final String? actingName;
  @JsonKey(name: 'acting_user_id', defaultValue: 0)
  final int? actingUserId;
  @JsonKey(name: 'title', defaultValue: '')
  final String? title;
  @JsonKey(name: 'deleted', defaultValue: false)
  final bool deleted;
  @JsonKey(name: 'hidden', defaultValue: false)
  final bool hidden;
  @JsonKey(name: 'post_type')
  final int? postType;
  @JsonKey(name: 'action_code')
  final String? actionCode;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'closed', defaultValue: false)
  final bool closed;
  @JsonKey(name: 'archived', defaultValue: false)
  final bool archived;
  @JsonKey(name: 'hide_presence', defaultValue: false)
  final bool hidePresence;

  UserAction({
    required this.excerpt,
    required this.actionType,
    required this.createdAt,
    required this.avatarTemplate,
    required this.actingAvatarTemplate,
    required this.slug,
    this.topicId,
    this.targetUserId,
    required this.targetName,
    required this.targetUsername,
    this.postNumber,
    this.postId,
    this.replyToPostNumber,
    required this.username,
    required this.name,
    required this.userId,
    required this.actingUsername,
    required this.actingName,
    required this.actingUserId,
    required this.title,
    required this.deleted,
    required this.hidden,
    this.postType,
    this.actionCode,
    this.categoryId,
    required this.closed,
    required this.archived,
    required this.hidePresence,
  });

  String get avatarUrl {
    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    if (actingAvatarTemplate == null || actingAvatarTemplate!.isEmpty) {
      return '';
    }
    if (actingAvatarTemplate!.startsWith('http://') ||
        actingAvatarTemplate!.startsWith('https://')) {
      return actingAvatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${actingAvatarTemplate!.replaceAll('{size}', '100')}';
  }

  String getAvatarUrl() {
    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    if (actingAvatarTemplate == null || actingAvatarTemplate!.isEmpty) {
      return '';
    }
    if (actingAvatarTemplate!.startsWith('http://') ||
        actingAvatarTemplate!.startsWith('https://')) {
      return actingAvatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${actingAvatarTemplate!.replaceAll('{size}', '62')}';
  }

  bool isWebMaster() {
    return userId == 1;
  }

  String get formattedDate {
    final date = DateTime.parse(createdAt ?? '');
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get cleanExcerpt {
    if (excerpt?.isEmpty ?? true) return '';
    // 移除 HTML 标签
    String text = excerpt?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';
    // 移除表情图片标签
    text = text.replaceAll(RegExp(r'<img[^>]+>'), '');
    // 解码 HTML 实体
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
    // 移除多余空格
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  factory UserAction.fromJson(Map<String, dynamic> json) =>
      _$UserActionFromJson(json);
  Map<String, dynamic> toJson() => _$UserActionToJson(this);
}
