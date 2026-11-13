import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

import 'category_data.dart';

part 'about.g.dart';

@JsonSerializable()
class AboutResponse {
  final List<AboutUser> users;
  final List<Category> categories;
  final About about;

  AboutResponse({
    required this.users,
    required this.categories,
    required this.about,
  });

  String get avatarUrl =>
      '${HttpConfig.baseUrl}${(findUserById(1)?.avatarTemplate ?? '').replaceAll('{size}', '80')}';

  // 根据用户ID获取用户
  AboutUser? findUserById(int userId) {
    return users.firstWhere(
      (user) => user.id == userId,
      orElse: () =>
          AboutUser(id: 0, username: '', name: '', avatarTemplate: ''),
    );
  }

  factory AboutResponse.fromJson(Map<String, dynamic> json) =>
      _$AboutResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AboutResponseToJson(this);
}

@JsonSerializable()
class About {
  final Stats stats;
  final String description;
  @JsonKey(name: 'extended_site_description')
  final String extendedSiteDescription;
  @JsonKey(name: 'banner_image')
  final String bannerImage;
  @JsonKey(name: 'site_creation_date')
  final DateTime siteCreationDate;
  final String title;
  final String locale;
  final String version;
  final bool https;
  @JsonKey(name: 'can_see_about_stats')
  final bool canSeeAboutStats;
  @JsonKey(name: 'contact_url')
  final String contactUrl;
  @JsonKey(name: 'contact_email')
  final String contactEmail;
  @JsonKey(name: 'moderator_ids')
  final List<int> moderatorIds;
  @JsonKey(name: 'admin_ids')
  final List<int> adminIds;
  @JsonKey(name: 'category_moderators')
  final List<CategoryModerator> categoryModerators;

  About({
    required this.stats,
    required this.description,
    required this.extendedSiteDescription,
    required this.bannerImage,
    required this.siteCreationDate,
    required this.title,
    required this.locale,
    required this.version,
    required this.https,
    required this.canSeeAboutStats,
    required this.contactUrl,
    required this.contactEmail,
    required this.moderatorIds,
    required this.adminIds,
    required this.categoryModerators,
  });

  factory About.fromJson(Map<String, dynamic> json) => _$AboutFromJson(json);
  Map<String, dynamic> toJson() => _$AboutToJson(this);
}

@JsonSerializable()
class Stats {
  @JsonKey(name: 'topics_last_day')
  final int topicsLastDay;
  @JsonKey(name: 'topics_7_days')
  final int topics7Days;
  @JsonKey(name: 'topics_30_days')
  final int topics30Days;
  @JsonKey(name: 'topics_count')
  final int topicsCount;
  @JsonKey(name: 'posts_last_day')
  final int postsLastDay;
  @JsonKey(name: 'posts_7_days')
  final int posts7Days;
  @JsonKey(name: 'posts_30_days')
  final int posts30Days;
  @JsonKey(name: 'posts_count')
  final int postsCount;
  @JsonKey(name: 'users_last_day')
  final int usersLastDay;
  @JsonKey(name: 'users_7_days')
  final int users7Days;
  @JsonKey(name: 'users_30_days')
  final int users30Days;
  @JsonKey(name: 'users_count')
  final int usersCount;
  @JsonKey(name: 'active_users_last_day')
  final int activeUsersLastDay;
  @JsonKey(name: 'active_users_7_days')
  final int activeUsers7Days;
  @JsonKey(name: 'active_users_30_days')
  final int activeUsers30Days;
  @JsonKey(name: 'likes_last_day')
  final int likesLastDay;
  @JsonKey(name: 'likes_7_days')
  final int likes7Days;
  @JsonKey(name: 'likes_30_days')
  final int likes30Days;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'participating_users_last_day')
  final int participatingUsersLastDay;
  @JsonKey(name: 'participating_users_7_days')
  final int participatingUsers7Days;
  @JsonKey(name: 'participating_users_30_days')
  final int participatingUsers30Days;
  @JsonKey(name: 'chat_messages_last_day')
  final int chatMessagesLastDay;
  @JsonKey(name: 'chat_messages_7_days')
  final int chatMessages7Days;
  @JsonKey(name: 'chat_messages_30_days')
  final int chatMessages30Days;
  @JsonKey(name: 'chat_messages_previous_30_days')
  final int chatMessagesPrevious30Days;
  @JsonKey(name: 'chat_messages_count')
  final int chatMessagesCount;
  @JsonKey(name: 'chat_users_last_day')
  final int chatUsersLastDay;
  @JsonKey(name: 'chat_users_7_days')
  final int chatUsers7Days;
  @JsonKey(name: 'chat_users_30_days')
  final int chatUsers30Days;
  @JsonKey(name: 'chat_users_previous_30_days')
  final int chatUsersPrevious30Days;
  @JsonKey(name: 'chat_users_count')
  final int chatUsersCount;
  @JsonKey(name: 'chat_channels_last_day')
  final int chatChannelsLastDay;
  @JsonKey(name: 'chat_channels_7_days')
  final int chatChannels7Days;
  @JsonKey(name: 'chat_channels_30_days')
  final int chatChannels30Days;
  @JsonKey(name: 'chat_channels_previous_30_days')
  final int chatChannelsPrevious30Days;
  @JsonKey(name: 'chat_channels_count')
  final int chatChannelsCount;

  Stats({
    required this.topicsLastDay,
    required this.topics7Days,
    required this.topics30Days,
    required this.topicsCount,
    required this.postsLastDay,
    required this.posts7Days,
    required this.posts30Days,
    required this.postsCount,
    required this.usersLastDay,
    required this.users7Days,
    required this.users30Days,
    required this.usersCount,
    required this.activeUsersLastDay,
    required this.activeUsers7Days,
    required this.activeUsers30Days,
    required this.likesLastDay,
    required this.likes7Days,
    required this.likes30Days,
    required this.likesCount,
    required this.participatingUsersLastDay,
    required this.participatingUsers7Days,
    required this.participatingUsers30Days,
    required this.chatMessagesLastDay,
    required this.chatMessages7Days,
    required this.chatMessages30Days,
    required this.chatMessagesPrevious30Days,
    required this.chatMessagesCount,
    required this.chatUsersLastDay,
    required this.chatUsers7Days,
    required this.chatUsers30Days,
    required this.chatUsersPrevious30Days,
    required this.chatUsersCount,
    required this.chatChannelsLastDay,
    required this.chatChannels7Days,
    required this.chatChannels30Days,
    required this.chatChannelsPrevious30Days,
    required this.chatChannelsCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatsToJson(this);
}

@JsonSerializable()
class CategoryModerator {
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'moderator_ids')
  final List<int> moderatorIds;

  CategoryModerator({required this.categoryId, required this.moderatorIds});

  factory CategoryModerator.fromJson(Map<String, dynamic> json) =>
      _$CategoryModeratorFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModeratorToJson(this);
}

@JsonSerializable()
class AboutUser {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'username')
  final String? username;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;
  @JsonKey(name: 'last_seen_at')
  final String? lastSeenAt;

  AboutUser({
    required this.id,
    this.username,
    this.name,
    this.avatarTemplate,
    this.title,
    this.animatedAvatar,
    this.lastSeenAt,
  });

  String get avatarUrl {
    if (animatedAvatar != null && animatedAvatar!.isNotEmpty) {
      if (animatedAvatar!.startsWith('http://') ||
          animatedAvatar!.startsWith('https://')) {
        return animatedAvatar!.replaceAll(RegExp(r'/+'), '/');
      }
      return '${HttpConfig.baseUrl}${animatedAvatar!.replaceAll('{size}', '80')}';
    }

    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!.replaceAll(RegExp(r'/+'), '/');
    }
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll('{size}', '80')}';
  }

  factory AboutUser.fromJson(Map<String, dynamic> json) =>
      _$AboutUserFromJson(json);
  Map<String, dynamic> toJson() => _$AboutUserToJson(this);
}
