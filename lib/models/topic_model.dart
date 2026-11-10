import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

part 'topic_model.g.dart';

@JsonSerializable()
class TopicListResponse {
  final List<User>? users;
  final List<Group>? primaryGroups;
  final List<FlairGroup>? flairGroups;
  @JsonKey(name: 'topic_list')
  final TopicList? topicList;

  const TopicListResponse({
    this.users,
    this.primaryGroups,
    this.flairGroups,
    this.topicList,
  });

  factory TopicListResponse.fromJson(Map<String, dynamic> json) =>
      _$TopicListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TopicListResponseToJson(this);

  // 根据用户ID获取用户
  User? findUserById(int userId) {
    return users?.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(id: 0, username: '', name: '', avatarTemplate: ''),
    );
  }
}

@JsonSerializable()
class User {
  final int id;
  final String? username;
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'flair_name')
  final String? flairName;
  @JsonKey(name: 'flair_url')
  final String? flairUrl;
  @JsonKey(name: 'flair_bg_color')
  final String? flairBgColor;
  @JsonKey(name: 'flair_color')
  final String? flairColor;
  @JsonKey(name: 'flair_group_id')
  final int? flairGroupId;
  final bool? admin;
  final bool? moderator;
  @JsonKey(name: 'trust_level')
  final int? trustLevel;
  @JsonKey(name: 'count')
  final int? count;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  User({
    required this.id,
    this.username,
    this.name,
    this.avatarTemplate,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.flairGroupId,
    this.admin,
    this.moderator,
    this.trustLevel,
    this.count,
    this.animatedAvatar,
  });

  String get avatarUrl {
    if (animatedAvatar != null) {
      if (animatedAvatar!.startsWith('http://') ||
          animatedAvatar!.startsWith('https://')) {
        return animatedAvatar!;
      }
      return '${HttpConfig.baseUrl}${animatedAvatar?.replaceFirst('{size}', '100')}';
    }
    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${avatarTemplate?.replaceFirst('{size}', '100')}';
  }

  String? getFlairUrl() {
    if (flairUrl == null) {
      return null;
    }
    if (flairUrl!.startsWith('http://') || flairUrl!.startsWith('https://')) {
      return flairUrl!;
    }
    return '${HttpConfig.baseUrl}${flairUrl?.replaceFirst('{size}', '100')}';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Group {
  final int id;
  final String? name;

  Group({required this.id, this.name});

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class FlairGroup {
  final int id;
  final String? name;
  @JsonKey(name: 'flair_url')
  final String? flairUrl;
  @JsonKey(name: 'flair_bg_color')
  final String? flairBgColor;
  @JsonKey(name: 'flair_color')
  final String? flairColor;

  FlairGroup({
    required this.id,
    this.name,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
  });

  factory FlairGroup.fromJson(Map<String, dynamic> json) =>
      _$FlairGroupFromJson(json);
  Map<String, dynamic> toJson() => _$FlairGroupToJson(this);
}

@JsonSerializable()
class TopicList {
  @JsonKey(name: 'can_create_topic')
  final bool? canCreateTopic;
  @JsonKey(name: 'more_topics_url')
  final String? moreTopicsUrl;
  @JsonKey(name: 'for_period')
  final String? forPeriod;
  @JsonKey(name: 'per_page')
  final int? perPage;
  @JsonKey(name: 'top_tags')
  final List<String>? topTags;
  final List<Topic> topics;

  TopicList({
    this.canCreateTopic,
    this.moreTopicsUrl,
    this.forPeriod,
    this.perPage,
    this.topTags,
    required this.topics,
  });

  factory TopicList.fromJson(Map<String, dynamic> json) =>
      _$TopicListFromJson(json);
  Map<String, dynamic> toJson() => _$TopicListToJson(this);
}

@JsonSerializable()
class Topic {
  final int id;
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
  final bool? pinned;
  final dynamic unpinned;
  final String? excerpt;
  final bool? visible;
  final bool? closed;
  final bool? archived;
  final List<String>? tags;
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
  final dynamic featuredLink;
  @JsonKey(name: 'has_accepted_answer')
  final bool? hasAcceptedAnswer;
  final List<Poster>? posters;
  @JsonKey(name: 'bookmarked')
  final bool? bookmarked;

  // 楼层编号, 用于定位到具体楼层
  @JsonKey(name: 'post_number')
  int? postNumber;

  Topic({
    required this.id,
    this.title,
    this.fancyTitle,
    this.slug,
    this.postsCount,
    this.replyCount,
    this.highestPostNumber,
    this.imageUrl,
    this.createdAt,
    this.lastPostedAt,
    this.bumped,
    this.bumpedAt,
    this.archetype,
    this.unseen,
    this.pinned,
    this.unpinned,
    this.excerpt,
    this.visible,
    this.closed,
    this.archived,
    this.tags,
    this.views,
    this.likeCount,
    this.hasSummary,
    this.lastPosterUsername,
    this.categoryId,
    this.pinnedGlobally,
    this.featuredLink,
    this.hasAcceptedAnswer,
    this.posters,
    this.bookmarked,
    this.postNumber,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);

  // 获取最新发帖人的ID
  int? getLatestPosterId() {
    final latestPoster = posters?.firstWhere(
      (poster) => poster.extras == 'latest',
      orElse: () => Poster(userId: 0, extras: ''),
    );
    return latestPoster?.userId;
  }

  // 获取原始发帖人的ID
  int? getOriginalPosterId() {
    final latestPoster = posters?.firstWhere(
      (poster) => poster.description?.contains('原始发帖人') ?? false,
      orElse: () => Poster(userId: 0, extras: ''),
    );
    return latestPoster?.userId;
  }

  // 返回posters中的id 并且不包含原始发帖人
  List<int> getAvatarUrls() {
    return posters?.map((poster) => poster.userId).whereType<int>().toList() ??
        [];
  }
}

@JsonSerializable()
class Poster {
  final dynamic extras;
  final String? description;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'primary_group_id')
  final int? primaryGroupId;
  @JsonKey(name: 'flair_group_id')
  final int? flairGroupId;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;

  Poster({
    this.extras,
    this.description,
    this.userId,
    this.primaryGroupId,
    this.flairGroupId,
    this.avatarTemplate,
  });

  factory Poster.fromJson(Map<String, dynamic> json) => _$PosterFromJson(json);
  Map<String, dynamic> toJson() => _$PosterToJson(this);
}

class TopicModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  TopicModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
