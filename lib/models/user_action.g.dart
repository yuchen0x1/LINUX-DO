// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserActionResponse _$UserActionResponseFromJson(Map<String, dynamic> json) =>
    UserActionResponse(
      userActions: (json['user_actions'] as List<dynamic>)
          .map((e) => UserAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserActionResponseToJson(UserActionResponse instance) =>
    <String, dynamic>{'user_actions': instance.userActions};

UserAction _$UserActionFromJson(Map<String, dynamic> json) => UserAction(
  excerpt: json['excerpt'] as String? ?? '',
  actionType: (json['action_type'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String? ?? '',
  avatarTemplate: json['avatar_template'] as String? ?? '',
  actingAvatarTemplate: json['acting_avatar_template'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  topicId: (json['topic_id'] as num?)?.toInt(),
  targetUserId: (json['target_user_id'] as num?)?.toInt(),
  targetName: json['target_name'] as String? ?? '',
  targetUsername: json['target_username'] as String? ?? '',
  postNumber: (json['post_number'] as num?)?.toInt(),
  postId: (json['post_id'] as num?)?.toInt(),
  replyToPostNumber: (json['reply_to_post_number'] as num?)?.toInt(),
  username: json['username'] as String? ?? '',
  name: json['name'] as String? ?? '',
  userId: (json['user_id'] as num?)?.toInt() ?? 0,
  actingUsername: json['acting_username'] as String? ?? '',
  actingName: json['acting_name'] as String? ?? '',
  actingUserId: (json['acting_user_id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  deleted: json['deleted'] as bool? ?? false,
  hidden: json['hidden'] as bool? ?? false,
  postType: (json['post_type'] as num?)?.toInt(),
  actionCode: json['action_code'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  closed: json['closed'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  hidePresence: json['hide_presence'] as bool? ?? false,
);

Map<String, dynamic> _$UserActionToJson(UserAction instance) =>
    <String, dynamic>{
      'excerpt': instance.excerpt,
      'action_type': instance.actionType,
      'created_at': instance.createdAt,
      'avatar_template': instance.avatarTemplate,
      'acting_avatar_template': instance.actingAvatarTemplate,
      'slug': instance.slug,
      'topic_id': instance.topicId,
      'target_user_id': instance.targetUserId,
      'target_name': instance.targetName,
      'target_username': instance.targetUsername,
      'post_number': instance.postNumber,
      'post_id': instance.postId,
      'reply_to_post_number': instance.replyToPostNumber,
      'username': instance.username,
      'name': instance.name,
      'user_id': instance.userId,
      'acting_username': instance.actingUsername,
      'acting_name': instance.actingName,
      'acting_user_id': instance.actingUserId,
      'title': instance.title,
      'deleted': instance.deleted,
      'hidden': instance.hidden,
      'post_type': instance.postType,
      'action_code': instance.actionCode,
      'category_id': instance.categoryId,
      'closed': instance.closed,
      'archived': instance.archived,
      'hide_presence': instance.hidePresence,
    };
