import 'package:json_annotation/json_annotation.dart';

part 'activity_stream.g.dart';

@JsonSerializable()
class ActivityStreamResponse {
  final List<ActivityEvent> events;

  ActivityStreamResponse({required this.events});

  factory ActivityStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityStreamResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityStreamResponseToJson(this);
}

@JsonSerializable()
class ActivityEvent {
  final int id;
  @JsonKey(name: 'starts_at')
  final String startsAt;
  @JsonKey(name: 'ends_at')
  final String endsAt;
  final String timezone;
  final ActivityPost post;
  final String name;
  @JsonKey(name: 'category_id')
  final int categoryId;

  ActivityEvent({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.timezone,
    required this.post,
    required this.name,
    required this.categoryId,
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityEventToJson(this);
}

@JsonSerializable()
class ActivityPost {
  final int id;
  @JsonKey(name: 'post_number')
  final int postNumber;
  final String url;
  final ActivityTopic topic;

  ActivityPost({
    required this.id,
    required this.postNumber,
    required this.url,
    required this.topic,
  });

  factory ActivityPost.fromJson(Map<String, dynamic> json) =>
      _$ActivityPostFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityPostToJson(this);
}

@JsonSerializable()
class ActivityTopic {
  final int id;
  final String title;

  ActivityTopic({required this.id, required this.title});

  factory ActivityTopic.fromJson(Map<String, dynamic> json) =>
      _$ActivityTopicFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityTopicToJson(this);
}
