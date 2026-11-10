// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityStreamResponse _$ActivityStreamResponseFromJson(
  Map<String, dynamic> json,
) => ActivityStreamResponse(
  events: (json['events'] as List<dynamic>)
      .map((e) => ActivityEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ActivityStreamResponseToJson(
  ActivityStreamResponse instance,
) => <String, dynamic>{'events': instance.events};

ActivityEvent _$ActivityEventFromJson(Map<String, dynamic> json) =>
    ActivityEvent(
      id: (json['id'] as num).toInt(),
      startsAt: json['starts_at'] as String,
      endsAt: json['ends_at'] as String,
      timezone: json['timezone'] as String,
      post: ActivityPost.fromJson(json['post'] as Map<String, dynamic>),
      name: json['name'] as String,
      categoryId: (json['category_id'] as num).toInt(),
    );

Map<String, dynamic> _$ActivityEventToJson(ActivityEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'starts_at': instance.startsAt,
      'ends_at': instance.endsAt,
      'timezone': instance.timezone,
      'post': instance.post,
      'name': instance.name,
      'category_id': instance.categoryId,
    };

ActivityPost _$ActivityPostFromJson(Map<String, dynamic> json) => ActivityPost(
  id: (json['id'] as num).toInt(),
  postNumber: (json['post_number'] as num).toInt(),
  url: json['url'] as String,
  topic: ActivityTopic.fromJson(json['topic'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityPostToJson(ActivityPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_number': instance.postNumber,
      'url': instance.url,
      'topic': instance.topic,
    };

ActivityTopic _$ActivityTopicFromJson(Map<String, dynamic> json) =>
    ActivityTopic(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$ActivityTopicToJson(ActivityTopic instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};
