import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/net/http_config.dart';

part 'user_post.g.dart';

@JsonSerializable()
class UserPostResponse {
  final List<UserPost> posts;
  @JsonKey(name: '__rest_serializer')
  final String restSerializer;
  final Extras extras;

  UserPostResponse({
    required this.posts,
    required this.restSerializer,
    required this.extras,
  });

  factory UserPostResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPostResponseToJson(this);
}

@JsonSerializable()
class Extras {
  @JsonKey(name: 'has_more')
  final bool hasMore;

  Extras({required this.hasMore});

  factory Extras.fromJson(Map<String, dynamic> json) => _$ExtrasFromJson(json);
  Map<String, dynamic> toJson() => _$ExtrasToJson(this);
}

@JsonSerializable()
class UserPost {
  final String excerpt;
  final bool? truncated;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final int id;
  @JsonKey(name: 'post_number')
  final int postNumber;
  @JsonKey(name: 'post_type')
  final int postType;
  @JsonKey(name: 'topic_id')
  final int topicId;
  final String url;
  final User user;
  final Topic topic;

  UserPost({
    required this.excerpt,
    this.truncated,
    required this.categoryId,
    required this.createdAt,
    required this.id,
    required this.postNumber,
    required this.postType,
    required this.topicId,
    required this.url,
    required this.user,
    required this.topic,
  });

  String get avatarUrl {
    if (user.animatedAvatar != null) {
      if (user.animatedAvatar!.startsWith('http://') ||
          user.animatedAvatar!.startsWith('https://')) {
        return user.animatedAvatar!;
      }
      return '${HttpConfig.baseUrl}${user.animatedAvatar?.replaceFirst('{size}', '100') ?? ''}';
    }
    if (user.avatarTemplate == null || user.avatarTemplate!.isEmpty) {
      return '';
    }
    if (user.avatarTemplate!.startsWith('http://') ||
        user.avatarTemplate!.startsWith('https://')) {
      return user.avatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${user.avatarTemplate!.replaceFirst('{size}', '100')}';
  }

  bool isWebMaster() {
    return user.id == 1;
  }

  factory UserPost.fromJson(Map<String, dynamic> json) =>
      _$UserPostFromJson(json);
  Map<String, dynamic> toJson() => _$UserPostToJson(this);
}
