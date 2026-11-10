import 'package:json_annotation/json_annotation.dart';

part 'create_post_response.g.dart';

@JsonSerializable()
class CreatePostResponse {
  final String? action;
  final CreatePost post;
  final bool? success;

  CreatePostResponse({this.action, required this.post, this.success});

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostResponseToJson(this);
}

@JsonSerializable()
class CreatePost {
  final int id;
  final String name;
  final String username;
  @JsonKey(name: 'avatar_template')
  final String avatarTemplate;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final String cooked;
  @JsonKey(name: 'post_number')
  final int postNumber;
  @JsonKey(name: 'post_type')
  final int postType;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'reply_count')
  final int replyCount;
  @JsonKey(name: 'topic_id')
  final int topicId;
  @JsonKey(name: 'topic_slug')
  final String topicSlug;
  final String raw;
  final bool yours;
  @JsonKey(name: 'can_edit')
  final bool canEdit;

  CreatePost({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarTemplate,
    required this.createdAt,
    required this.cooked,
    required this.postNumber,
    required this.postType,
    required this.updatedAt,
    required this.replyCount,
    required this.topicId,
    required this.topicSlug,
    required this.raw,
    required this.yours,
    required this.canEdit,
  });

  factory CreatePost.fromJson(Map<String, dynamic> json) =>
      _$CreatePostFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostToJson(this);
}
