// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  author: json['author'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  category: json['category'] as String? ?? '',
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
  commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
  isAnnouncement: json['is_announcement'] as bool? ?? false,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'author': instance.author,
  'category': instance.category,
  'view_count': instance.viewCount,
  'comment_count': instance.commentCount,
  'created_at': instance.createdAt.toIso8601String(),
  'is_announcement': instance.isAnnouncement,
};
