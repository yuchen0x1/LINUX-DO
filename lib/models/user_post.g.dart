// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPostResponse _$UserPostResponseFromJson(Map<String, dynamic> json) =>
    UserPostResponse(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => UserPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      restSerializer: json['__rest_serializer'] as String,
      extras: Extras.fromJson(json['extras'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPostResponseToJson(UserPostResponse instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      '__rest_serializer': instance.restSerializer,
      'extras': instance.extras,
    };

Extras _$ExtrasFromJson(Map<String, dynamic> json) =>
    Extras(hasMore: json['has_more'] as bool);

Map<String, dynamic> _$ExtrasToJson(Extras instance) => <String, dynamic>{
  'has_more': instance.hasMore,
};

UserPost _$UserPostFromJson(Map<String, dynamic> json) => UserPost(
  excerpt: json['excerpt'] as String,
  truncated: json['truncated'] as bool?,
  categoryId: (json['category_id'] as num).toInt(),
  createdAt: json['created_at'] as String,
  id: (json['id'] as num).toInt(),
  postNumber: (json['post_number'] as num).toInt(),
  postType: (json['post_type'] as num).toInt(),
  topicId: (json['topic_id'] as num).toInt(),
  url: json['url'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  topic: Topic.fromJson(json['topic'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPostToJson(UserPost instance) => <String, dynamic>{
  'excerpt': instance.excerpt,
  'truncated': instance.truncated,
  'category_id': instance.categoryId,
  'created_at': instance.createdAt,
  'id': instance.id,
  'post_number': instance.postNumber,
  'post_type': instance.postType,
  'topic_id': instance.topicId,
  'url': instance.url,
  'user': instance.user,
  'topic': instance.topic,
};
