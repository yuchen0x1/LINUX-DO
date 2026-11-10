// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Docs _$DocsFromJson(Map<String, dynamic> json) => Docs(
  topicCount: (json['topic_count'] as num?)?.toInt(),
  topics: json['topics'] == null
      ? null
      : TopicListResponse.fromJson(json['topics'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => DocTag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DocsToJson(Docs instance) => <String, dynamic>{
  'topic_count': instance.topicCount,
  'topics': instance.topics,
  'tags': instance.tags,
};

DocTag _$DocTagFromJson(Map<String, dynamic> json) => DocTag(
  id: json['id'] as String?,
  active: json['active'] as bool?,
  count: (json['count'] as num?)?.toInt(),
);

Map<String, dynamic> _$DocTagToJson(DocTag instance) => <String, dynamic>{
  'id': instance.id,
  'active': instance.active,
  'count': instance.count,
};
