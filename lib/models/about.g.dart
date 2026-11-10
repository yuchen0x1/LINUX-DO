// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutResponse _$AboutResponseFromJson(Map<String, dynamic> json) =>
    AboutResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => AboutUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      about: About.fromJson(json['about'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AboutResponseToJson(AboutResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'categories': instance.categories,
      'about': instance.about,
    };

About _$AboutFromJson(Map<String, dynamic> json) => About(
  stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
  description: json['description'] as String,
  extendedSiteDescription: json['extended_site_description'] as String,
  bannerImage: json['banner_image'] as String,
  siteCreationDate: DateTime.parse(json['site_creation_date'] as String),
  title: json['title'] as String,
  locale: json['locale'] as String,
  version: json['version'] as String,
  https: json['https'] as bool,
  canSeeAboutStats: json['can_see_about_stats'] as bool,
  contactUrl: json['contact_url'] as String,
  contactEmail: json['contact_email'] as String,
  moderatorIds: (json['moderator_ids'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  adminIds: (json['admin_ids'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  categoryModerators: (json['category_moderators'] as List<dynamic>)
      .map((e) => CategoryModerator.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AboutToJson(About instance) => <String, dynamic>{
  'stats': instance.stats,
  'description': instance.description,
  'extended_site_description': instance.extendedSiteDescription,
  'banner_image': instance.bannerImage,
  'site_creation_date': instance.siteCreationDate.toIso8601String(),
  'title': instance.title,
  'locale': instance.locale,
  'version': instance.version,
  'https': instance.https,
  'can_see_about_stats': instance.canSeeAboutStats,
  'contact_url': instance.contactUrl,
  'contact_email': instance.contactEmail,
  'moderator_ids': instance.moderatorIds,
  'admin_ids': instance.adminIds,
  'category_moderators': instance.categoryModerators,
};

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
  topicsLastDay: (json['topics_last_day'] as num).toInt(),
  topics7Days: (json['topics_7_days'] as num).toInt(),
  topics30Days: (json['topics_30_days'] as num).toInt(),
  topicsCount: (json['topics_count'] as num).toInt(),
  postsLastDay: (json['posts_last_day'] as num).toInt(),
  posts7Days: (json['posts_7_days'] as num).toInt(),
  posts30Days: (json['posts_30_days'] as num).toInt(),
  postsCount: (json['posts_count'] as num).toInt(),
  usersLastDay: (json['users_last_day'] as num).toInt(),
  users7Days: (json['users_7_days'] as num).toInt(),
  users30Days: (json['users_30_days'] as num).toInt(),
  usersCount: (json['users_count'] as num).toInt(),
  activeUsersLastDay: (json['active_users_last_day'] as num).toInt(),
  activeUsers7Days: (json['active_users_7_days'] as num).toInt(),
  activeUsers30Days: (json['active_users_30_days'] as num).toInt(),
  likesLastDay: (json['likes_last_day'] as num).toInt(),
  likes7Days: (json['likes_7_days'] as num).toInt(),
  likes30Days: (json['likes_30_days'] as num).toInt(),
  likesCount: (json['likes_count'] as num).toInt(),
  participatingUsersLastDay: (json['participating_users_last_day'] as num)
      .toInt(),
  participatingUsers7Days: (json['participating_users_7_days'] as num).toInt(),
  participatingUsers30Days: (json['participating_users_30_days'] as num)
      .toInt(),
  chatMessagesLastDay: (json['chat_messages_last_day'] as num).toInt(),
  chatMessages7Days: (json['chat_messages_7_days'] as num).toInt(),
  chatMessages30Days: (json['chat_messages_30_days'] as num).toInt(),
  chatMessagesPrevious30Days: (json['chat_messages_previous_30_days'] as num)
      .toInt(),
  chatMessagesCount: (json['chat_messages_count'] as num).toInt(),
  chatUsersLastDay: (json['chat_users_last_day'] as num).toInt(),
  chatUsers7Days: (json['chat_users_7_days'] as num).toInt(),
  chatUsers30Days: (json['chat_users_30_days'] as num).toInt(),
  chatUsersPrevious30Days: (json['chat_users_previous_30_days'] as num).toInt(),
  chatUsersCount: (json['chat_users_count'] as num).toInt(),
  chatChannelsLastDay: (json['chat_channels_last_day'] as num).toInt(),
  chatChannels7Days: (json['chat_channels_7_days'] as num).toInt(),
  chatChannels30Days: (json['chat_channels_30_days'] as num).toInt(),
  chatChannelsPrevious30Days: (json['chat_channels_previous_30_days'] as num)
      .toInt(),
  chatChannelsCount: (json['chat_channels_count'] as num).toInt(),
);

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
  'topics_last_day': instance.topicsLastDay,
  'topics_7_days': instance.topics7Days,
  'topics_30_days': instance.topics30Days,
  'topics_count': instance.topicsCount,
  'posts_last_day': instance.postsLastDay,
  'posts_7_days': instance.posts7Days,
  'posts_30_days': instance.posts30Days,
  'posts_count': instance.postsCount,
  'users_last_day': instance.usersLastDay,
  'users_7_days': instance.users7Days,
  'users_30_days': instance.users30Days,
  'users_count': instance.usersCount,
  'active_users_last_day': instance.activeUsersLastDay,
  'active_users_7_days': instance.activeUsers7Days,
  'active_users_30_days': instance.activeUsers30Days,
  'likes_last_day': instance.likesLastDay,
  'likes_7_days': instance.likes7Days,
  'likes_30_days': instance.likes30Days,
  'likes_count': instance.likesCount,
  'participating_users_last_day': instance.participatingUsersLastDay,
  'participating_users_7_days': instance.participatingUsers7Days,
  'participating_users_30_days': instance.participatingUsers30Days,
  'chat_messages_last_day': instance.chatMessagesLastDay,
  'chat_messages_7_days': instance.chatMessages7Days,
  'chat_messages_30_days': instance.chatMessages30Days,
  'chat_messages_previous_30_days': instance.chatMessagesPrevious30Days,
  'chat_messages_count': instance.chatMessagesCount,
  'chat_users_last_day': instance.chatUsersLastDay,
  'chat_users_7_days': instance.chatUsers7Days,
  'chat_users_30_days': instance.chatUsers30Days,
  'chat_users_previous_30_days': instance.chatUsersPrevious30Days,
  'chat_users_count': instance.chatUsersCount,
  'chat_channels_last_day': instance.chatChannelsLastDay,
  'chat_channels_7_days': instance.chatChannels7Days,
  'chat_channels_30_days': instance.chatChannels30Days,
  'chat_channels_previous_30_days': instance.chatChannelsPrevious30Days,
  'chat_channels_count': instance.chatChannelsCount,
};

CategoryModerator _$CategoryModeratorFromJson(Map<String, dynamic> json) =>
    CategoryModerator(
      categoryId: (json['category_id'] as num).toInt(),
      moderatorIds: (json['moderator_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CategoryModeratorToJson(CategoryModerator instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'moderator_ids': instance.moderatorIds,
    };

AboutUser _$AboutUserFromJson(Map<String, dynamic> json) => AboutUser(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  title: json['title'] as String?,
  animatedAvatar: json['animated_avatar'] as String?,
  lastSeenAt: json['last_seen_at'] as String?,
);

Map<String, dynamic> _$AboutUserToJson(AboutUser instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'title': instance.title,
  'animated_avatar': instance.animatedAvatar,
  'last_seen_at': instance.lastSeenAt,
};
