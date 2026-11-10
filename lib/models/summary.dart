import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/models/category_data.dart';
import 'package:linux_do/models/topic_model.dart';

part 'summary.g.dart';

@JsonSerializable()
class SummaryResponse {
  @JsonKey(name: 'topics')
  final List<Topic>? topics;
  @JsonKey(name: 'badges')
  final List<Badge>? badges;
  @JsonKey(name: 'badge_types')
  final List<BadgeType>? badgeTypes;
  @JsonKey(name: 'users')
  final List<User>? users;
  @JsonKey(name: 'user_summary')
  final UserSummary? userSummary;

  SummaryResponse({
    this.topics,
    this.badges,
    this.badgeTypes,
    this.users,
    this.userSummary,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SummaryResponseToJson(this);
}

@JsonSerializable()
class Badge {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: 'grant_count')
  final int grantCount;
  @JsonKey(name: 'allow_title')
  final bool allowTitle;
  @JsonKey(name: 'multiple_grant')
  final bool multipleGrant;
  final String icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final bool listable;
  final bool enabled;
  @JsonKey(name: 'badge_grouping_id')
  final int badgeGroupingId;
  final bool system;
  final String slug;
  @JsonKey(name: 'manually_grantable')
  final bool manuallyGrantable;
  @JsonKey(name: 'show_in_post_header')
  final bool showInPostHeader;
  @JsonKey(name: 'badge_type_id')
  final int badgeTypeId;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.grantCount,
    required this.allowTitle,
    required this.multipleGrant,
    required this.icon,
    this.imageUrl,
    required this.listable,
    required this.enabled,
    required this.badgeGroupingId,
    required this.system,
    required this.slug,
    required this.manuallyGrantable,
    required this.showInPostHeader,
    required this.badgeTypeId,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}

@JsonSerializable()
class BadgeType {
  final int id;
  final String name;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  BadgeType({required this.id, required this.name, required this.sortOrder});

  factory BadgeType.fromJson(Map<String, dynamic> json) =>
      _$BadgeTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeTypeToJson(this);
}

@JsonSerializable()
class UserSummary {
  @JsonKey(name: 'likes_given')
  final int? likesGiven;
  @JsonKey(name: 'likes_received')
  final int? likesReceived;
  @JsonKey(name: 'topics_entered')
  final int? topicsEntered;
  @JsonKey(name: 'posts_read_count')
  final int? postsReadCount;
  @JsonKey(name: 'days_visited')
  final int? daysVisited;
  @JsonKey(name: 'topic_count')
  final int? topicCount;
  @JsonKey(name: 'post_count')
  final int? postCount;
  @JsonKey(name: 'time_read')
  final int? timeRead;
  @JsonKey(name: 'recent_time_read')
  final int? recentTimeRead;
  @JsonKey(name: 'bookmark_count')
  final int? bookmarkCount;
  @JsonKey(name: 'can_see_summary_stats')
  final bool? canSeeSummaryStats;
  @JsonKey(name: 'can_see_user_actions')
  final bool? canSeeUserActions;
  @JsonKey(name: 'solved_count')
  final int? solvedCount;
  @JsonKey(name: 'topic_ids')
  final List<int>? topicIds;
  final List<Reply>? replies;
  final List<Link>? links;
  @JsonKey(name: 'most_liked_by_users')
  final List<User>? mostLikedByUsers;
  @JsonKey(name: 'most_liked_users')
  final List<User>? mostLikedUsers;
  @JsonKey(name: 'most_replied_to_users')
  final List<User>? mostRepliedToUsers;
  final List<UserBadge>? badges;
  @JsonKey(name: 'top_categories')
  final List<Category>? topCategories;

  UserSummary({
    this.likesGiven,
    this.likesReceived,
    this.topicsEntered,
    this.postsReadCount,
    this.daysVisited,
    this.topicCount,
    this.postCount,
    this.timeRead,
    this.recentTimeRead,
    this.bookmarkCount,
    this.canSeeSummaryStats,
    this.canSeeUserActions,
    this.solvedCount,
    this.topicIds,
    this.replies,
    this.links,
    this.mostLikedByUsers,
    this.mostLikedUsers,
    this.mostRepliedToUsers,
    this.badges,
    this.topCategories,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
    likesGiven: json['likes_given'] as int?,
    likesReceived: json['likes_received'] as int?,
    topicsEntered: json['topics_entered'] as int?,
    postsReadCount: json['posts_read_count'] as int?,
    daysVisited: json['days_visited'] as int?,
    topicCount: json['topic_count'] as int?,
    postCount: json['post_count'] as int?,
    timeRead: json['time_read'] as int?,
    recentTimeRead: json['recent_time_read'] as int?,
    bookmarkCount: json['bookmark_count'] as int?,
    canSeeSummaryStats: json['can_see_summary_stats'] as bool?,
    canSeeUserActions: json['can_see_user_actions'] as bool?,
    solvedCount: json['solved_count'] as int?,
    topicIds: (json['topic_ids'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList(),
    replies: (json['replies'] as List<dynamic>?)
        ?.map((e) => Reply.fromJson(e as Map<String, dynamic>))
        .toList(),
    links: (json['links'] as List<dynamic>?)
        ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
        .toList(),
    mostLikedByUsers: (json['most_liked_by_users'] as List<dynamic>?)
        ?.map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList(),
    mostLikedUsers: (json['most_liked_users'] as List<dynamic>?)
        ?.map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList(),
    mostRepliedToUsers: (json['most_replied_to_users'] as List<dynamic>?)
        ?.map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList(),
    badges: (json['badges'] as List<dynamic>?)
        ?.map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
        .toList(),
    topCategories: (json['top_categories'] as List<dynamic>?)
        ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'likes_given': likesGiven,
    'likes_received': likesReceived,
    'topics_entered': topicsEntered,
    'posts_read_count': postsReadCount,
    'days_visited': daysVisited,
    'topic_count': topicCount,
    'post_count': postCount,
    'time_read': timeRead,
    'recent_time_read': recentTimeRead,
    'bookmark_count': bookmarkCount,
    'can_see_summary_stats': canSeeSummaryStats,
    'can_see_user_actions': canSeeUserActions,
    'solved_count': solvedCount,
    'topic_ids': topicIds,
    'replies': replies?.map((e) => e.toJson()).toList(),
    'links': links?.map((e) => e.toJson()).toList(),
    'most_liked_by_users': mostLikedByUsers?.map((e) => e.toJson()).toList(),
    'most_liked_users': mostLikedUsers?.map((e) => e.toJson()).toList(),
    'most_replied_to_users': mostRepliedToUsers
        ?.map((e) => e.toJson())
        .toList(),
    'badges': badges?.map((e) => e.toJson()).toList(),
    'top_categories': topCategories?.map((e) => e.toJson()).toList(),
  };
}

@JsonSerializable()
class Reply {
  @JsonKey(name: 'post_number')
  final int postNumber;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'topic_id')
  final int topicId;

  Reply({
    required this.postNumber,
    required this.likeCount,
    required this.createdAt,
    required this.topicId,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyToJson(this);
}

@JsonSerializable()
class Link {
  final String url;
  final String? title;
  final int clicks;
  @JsonKey(name: 'post_number')
  final int postNumber;
  @JsonKey(name: 'topic_id')
  final int topicId;

  Link({
    required this.url,
    this.title,
    required this.clicks,
    required this.postNumber,
    required this.topicId,
  });

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class UserBadge {
  final int id;
  @JsonKey(name: 'granted_at')
  final String grantedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final int count;
  @JsonKey(name: 'badge_id')
  final int badgeId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'granted_by_id')
  final int grantedById;

  UserBadge({
    required this.id,
    required this.grantedAt,
    required this.createdAt,
    required this.count,
    required this.badgeId,
    required this.userId,
    required this.grantedById,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}

// @JsonSerializable()
// class TopCategory {
//   @JsonKey(name: 'topic_count')
//   final int topicCount;
//   @JsonKey(name: 'post_count')
//   final int postCount;
//   final int id;
//   final String name;
//   final String color;
//   @JsonKey(name: 'text_color')
//   final String textColor;
//   final String slug;
//   @JsonKey(name: 'read_restricted')
//   final bool readRestricted;
//   @JsonKey(name: 'parent_category_id')
//   final int? parentCategoryId;

//   TopCategory({
//     required this.topicCount,
//     required this.postCount,
//     required this.id,
//     required this.name,
//     required this.color,
//     required this.textColor,
//     required this.slug,
//     required this.readRestricted,
//     this.parentCategoryId,
//   });

//   factory TopCategory.fromJson(Map<String, dynamic> json) =>
//       _$TopCategoryFromJson(json);
//   Map<String, dynamic> toJson() => _$TopCategoryToJson(this);
// }
