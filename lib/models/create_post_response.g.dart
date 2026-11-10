// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostResponse _$CreatePostResponseFromJson(Map<String, dynamic> json) =>
    CreatePostResponse(
      action: json['action'] as String?,
      post: CreatePost.fromJson(json['post'] as Map<String, dynamic>),
      success: json['success'] as bool?,
    );

Map<String, dynamic> _$CreatePostResponseToJson(CreatePostResponse instance) =>
    <String, dynamic>{
      'action': instance.action,
      'post': instance.post,
      'success': instance.success,
    };

CreatePost _$CreatePostFromJson(Map<String, dynamic> json) => CreatePost(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  username: json['username'] as String,
  avatarTemplate: json['avatar_template'] as String,
  createdAt: json['created_at'] as String,
  cooked: json['cooked'] as String,
  postNumber: (json['post_number'] as num).toInt(),
  postType: (json['post_type'] as num).toInt(),
  updatedAt: json['updated_at'] as String,
  replyCount: (json['reply_count'] as num).toInt(),
  topicId: (json['topic_id'] as num).toInt(),
  topicSlug: json['topic_slug'] as String,
  raw: json['raw'] as String,
  yours: json['yours'] as bool,
  canEdit: json['can_edit'] as bool,
);

Map<String, dynamic> _$CreatePostToJson(CreatePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'avatar_template': instance.avatarTemplate,
      'created_at': instance.createdAt,
      'cooked': instance.cooked,
      'post_number': instance.postNumber,
      'post_type': instance.postType,
      'updated_at': instance.updatedAt,
      'reply_count': instance.replyCount,
      'topic_id': instance.topicId,
      'topic_slug': instance.topicSlug,
      'raw': instance.raw,
      'yours': instance.yours,
      'can_edit': instance.canEdit,
    };
