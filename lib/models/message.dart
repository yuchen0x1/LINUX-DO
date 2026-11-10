import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageResponse {
  @JsonKey(defaultValue: [])
  final List<User> users;
  @JsonKey(name: 'primary_groups', defaultValue: [])
  final List<dynamic> primaryGroups;
  @JsonKey(name: 'flair_groups', defaultValue: [])
  final List<dynamic> flairGroups;
  @JsonKey(name: 'topic_list')
  final TopicList? topicList;

  MessageResponse({
    this.users = const [],
    this.primaryGroups = const [],
    this.flairGroups = const [],
    this.topicList,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String avatarTemplate;
  final bool? admin;
  @JsonKey(name: 'trust_level')
  final int? trustLevel;
  final bool? moderator;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  User({
    required this.id,
    required this.username,
    this.name,
    required this.avatarTemplate,
    this.admin,
    this.trustLevel,
    this.moderator,
    this.animatedAvatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class TopicList {
  @JsonKey(name: 'can_create_topic', defaultValue: false)
  final bool? canCreateTopic;
  @JsonKey(name: 'per_page', defaultValue: 30)
  final int perPage;
  @JsonKey(name: 'top_tags', defaultValue: [])
  final List<String>? topTags;
  @JsonKey(defaultValue: [])
  final List<Topic>? topics;

  TopicList({
    this.canCreateTopic = false,
    this.perPage = 30,
    this.topTags = const [],
    this.topics = const [],
  });

  factory TopicList.fromJson(Map<String, dynamic> json) =>
      _$TopicListFromJson(json);
  Map<String, dynamic> toJson() => _$TopicListToJson(this);
}

@JsonSerializable()
class Topic {
  final int? id;
  final String? title;
  @JsonKey(name: 'fancy_title')
  final String? fancyTitle;
  final String? slug;
  @JsonKey(name: 'posts_count')
  final int? postsCount;
  @JsonKey(name: 'reply_count')
  final int? replyCount;
  @JsonKey(name: 'highest_post_number')
  final int? highestPostNumber;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'last_posted_at')
  final String? lastPostedAt;
  final bool? bumped;
  @JsonKey(name: 'bumped_at')
  final String? bumpedAt;
  final String? archetype;
  final bool? unseen;
  @JsonKey(name: 'last_read_post_number')
  final int? lastReadPostNumber;
  final int? unread;
  @JsonKey(name: 'new_posts')
  final int? newPosts;
  @JsonKey(name: 'unread_posts')
  final int? unreadPosts;
  final bool? pinned;
  final String? unpinned;
  final bool? visible;
  final bool? closed;
  final bool? archived;
  @JsonKey(name: 'notification_level')
  final int? notificationLevel;
  final bool? bookmarked;
  final bool? liked;
  @JsonKey(name: 'tags_descriptions')
  final Map<String, dynamic>? tagsDescriptions;
  final int? views;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'has_summary')
  final bool? hasSummary;
  @JsonKey(name: 'last_poster_username')
  final String? lastPosterUsername;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'pinned_globally')
  final bool? pinnedGlobally;
  @JsonKey(name: 'featured_link')
  final String? featuredLink;
  @JsonKey(name: 'allowed_user_count')
  final int? allowedUserCount;
  @JsonKey(name: 'participant_groups', defaultValue: [])
  final List<dynamic>? participantGroups;
  @JsonKey(name: 'has_accepted_answer')
  final bool? hasAcceptedAnswer;
  @JsonKey(name: 'can_have_answer')
  final bool? canHaveAnswer;
  @JsonKey(defaultValue: [])
  final List<Poster>? posters;
  @JsonKey(defaultValue: [])
  final List<Participant>? participants;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? _avatarUrl;

  set avatarUrl(String? value) {
    _avatarUrl = value;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarUrl {
    return _avatarUrl ?? '';
  }

  Topic({
    required this.id,
    this.title,
    this.fancyTitle,
    this.slug,
    required this.postsCount,
    required this.replyCount,
    required this.highestPostNumber,
    this.imageUrl,
    this.createdAt,
    this.lastPostedAt,
    required this.bumped,
    this.bumpedAt,
    this.archetype,
    required this.unseen,
    this.lastReadPostNumber,
    this.unread,
    this.newPosts,
    this.unreadPosts,
    required this.pinned,
    this.unpinned,
    required this.visible,
    required this.closed,
    required this.archived,
    this.notificationLevel,
    this.bookmarked,
    this.liked,
    this.tagsDescriptions,
    this.views,
    this.likeCount,
    this.hasSummary,
    this.lastPosterUsername,
    this.categoryId,
    this.pinnedGlobally,
    this.featuredLink,
    this.allowedUserCount,
    this.participantGroups,
    this.hasAcceptedAnswer,
    this.canHaveAnswer,
    this.posters,
    this.participants,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);

  bool isWebMaster() {
    return posters?[0].userId == 1;
  }
}

@JsonSerializable()
class Poster {
  final String? extras;
  final String? description;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'primary_group_id')
  final int? primaryGroupId;
  @JsonKey(name: 'flair_group_id')
  final int? flairGroupId;

  Poster({
    this.extras,
    this.description,
    required this.userId,
    this.primaryGroupId,
    this.flairGroupId,
  });

  factory Poster.fromJson(Map<String, dynamic> json) => _$PosterFromJson(json);
  Map<String, dynamic> toJson() => _$PosterToJson(this);
}

@JsonSerializable()
class Participant {
  final String? extras;
  final String? description;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'primary_group_id')
  final int? primaryGroupId;
  @JsonKey(name: 'flair_group_id')
  final int? flairGroupId;

  Participant({
    this.extras,
    this.description,
    required this.userId,
    this.primaryGroupId,
    this.flairGroupId,
  });

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
