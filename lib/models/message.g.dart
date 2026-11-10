// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      primaryGroups: json['primary_groups'] as List<dynamic>? ?? [],
      flairGroups: json['flair_groups'] as List<dynamic>? ?? [],
      topicList: json['topic_list'] == null
          ? null
          : TopicList.fromJson(json['topic_list'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'primary_groups': instance.primaryGroups,
      'flair_groups': instance.flairGroups,
      'topic_list': instance.topicList,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String,
  admin: json['admin'] as bool?,
  trustLevel: (json['trust_level'] as num?)?.toInt(),
  moderator: json['moderator'] as bool?,
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'admin': instance.admin,
  'trust_level': instance.trustLevel,
  'moderator': instance.moderator,
  'animated_avatar': instance.animatedAvatar,
};

TopicList _$TopicListFromJson(Map<String, dynamic> json) => TopicList(
  canCreateTopic: json['can_create_topic'] as bool? ?? false,
  perPage: (json['per_page'] as num?)?.toInt() ?? 30,
  topTags:
      (json['top_tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$TopicListToJson(TopicList instance) => <String, dynamic>{
  'can_create_topic': instance.canCreateTopic,
  'per_page': instance.perPage,
  'top_tags': instance.topTags,
  'topics': instance.topics,
};

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  fancyTitle: json['fancy_title'] as String?,
  slug: json['slug'] as String?,
  postsCount: (json['posts_count'] as num?)?.toInt(),
  replyCount: (json['reply_count'] as num?)?.toInt(),
  highestPostNumber: (json['highest_post_number'] as num?)?.toInt(),
  imageUrl: json['image_url'] as String?,
  createdAt: json['created_at'] as String?,
  lastPostedAt: json['last_posted_at'] as String?,
  bumped: json['bumped'] as bool?,
  bumpedAt: json['bumped_at'] as String?,
  archetype: json['archetype'] as String?,
  unseen: json['unseen'] as bool?,
  lastReadPostNumber: (json['last_read_post_number'] as num?)?.toInt(),
  unread: (json['unread'] as num?)?.toInt(),
  newPosts: (json['new_posts'] as num?)?.toInt(),
  unreadPosts: (json['unread_posts'] as num?)?.toInt(),
  pinned: json['pinned'] as bool?,
  unpinned: json['unpinned'] as String?,
  visible: json['visible'] as bool?,
  closed: json['closed'] as bool?,
  archived: json['archived'] as bool?,
  notificationLevel: (json['notification_level'] as num?)?.toInt(),
  bookmarked: json['bookmarked'] as bool?,
  liked: json['liked'] as bool?,
  tagsDescriptions: json['tags_descriptions'] as Map<String, dynamic>?,
  views: (json['views'] as num?)?.toInt(),
  likeCount: (json['like_count'] as num?)?.toInt(),
  hasSummary: json['has_summary'] as bool?,
  lastPosterUsername: json['last_poster_username'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  pinnedGlobally: json['pinned_globally'] as bool?,
  featuredLink: json['featured_link'] as String?,
  allowedUserCount: (json['allowed_user_count'] as num?)?.toInt(),
  participantGroups: json['participant_groups'] as List<dynamic>? ?? [],
  hasAcceptedAnswer: json['has_accepted_answer'] as bool?,
  canHaveAnswer: json['can_have_answer'] as bool?,
  posters:
      (json['posters'] as List<dynamic>?)
          ?.map((e) => Poster.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'fancy_title': instance.fancyTitle,
  'slug': instance.slug,
  'posts_count': instance.postsCount,
  'reply_count': instance.replyCount,
  'highest_post_number': instance.highestPostNumber,
  'image_url': instance.imageUrl,
  'created_at': instance.createdAt,
  'last_posted_at': instance.lastPostedAt,
  'bumped': instance.bumped,
  'bumped_at': instance.bumpedAt,
  'archetype': instance.archetype,
  'unseen': instance.unseen,
  'last_read_post_number': instance.lastReadPostNumber,
  'unread': instance.unread,
  'new_posts': instance.newPosts,
  'unread_posts': instance.unreadPosts,
  'pinned': instance.pinned,
  'unpinned': instance.unpinned,
  'visible': instance.visible,
  'closed': instance.closed,
  'archived': instance.archived,
  'notification_level': instance.notificationLevel,
  'bookmarked': instance.bookmarked,
  'liked': instance.liked,
  'tags_descriptions': instance.tagsDescriptions,
  'views': instance.views,
  'like_count': instance.likeCount,
  'has_summary': instance.hasSummary,
  'last_poster_username': instance.lastPosterUsername,
  'category_id': instance.categoryId,
  'pinned_globally': instance.pinnedGlobally,
  'featured_link': instance.featuredLink,
  'allowed_user_count': instance.allowedUserCount,
  'participant_groups': instance.participantGroups,
  'has_accepted_answer': instance.hasAcceptedAnswer,
  'can_have_answer': instance.canHaveAnswer,
  'posters': instance.posters,
  'participants': instance.participants,
};

Poster _$PosterFromJson(Map<String, dynamic> json) => Poster(
  extras: json['extras'] as String?,
  description: json['description'] as String?,
  userId: (json['user_id'] as num).toInt(),
  primaryGroupId: (json['primary_group_id'] as num?)?.toInt(),
  flairGroupId: (json['flair_group_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$PosterToJson(Poster instance) => <String, dynamic>{
  'extras': instance.extras,
  'description': instance.description,
  'user_id': instance.userId,
  'primary_group_id': instance.primaryGroupId,
  'flair_group_id': instance.flairGroupId,
};

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  extras: json['extras'] as String?,
  description: json['description'] as String?,
  userId: (json['user_id'] as num).toInt(),
  primaryGroupId: (json['primary_group_id'] as num?)?.toInt(),
  flairGroupId: (json['flair_group_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'extras': instance.extras,
      'description': instance.description,
      'user_id': instance.userId,
      'primary_group_id': instance.primaryGroupId,
      'flair_group_id': instance.flairGroupId,
    };
