// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicListResponse _$TopicListResponseFromJson(Map<String, dynamic> json) =>
    TopicListResponse(
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryGroups: (json['primaryGroups'] as List<dynamic>?)
          ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      flairGroups: (json['flairGroups'] as List<dynamic>?)
          ?.map((e) => FlairGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      topicList: json['topic_list'] == null
          ? null
          : TopicList.fromJson(json['topic_list'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopicListResponseToJson(TopicListResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'primaryGroups': instance.primaryGroups,
      'flairGroups': instance.flairGroups,
      'topic_list': instance.topicList,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  flairName: json['flair_name'] as String?,
  flairUrl: json['flair_url'] as String?,
  flairBgColor: json['flair_bg_color'] as String?,
  flairColor: json['flair_color'] as String?,
  flairGroupId: (json['flair_group_id'] as num?)?.toInt(),
  admin: json['admin'] as bool?,
  moderator: json['moderator'] as bool?,
  trustLevel: (json['trust_level'] as num?)?.toInt(),
  count: (json['count'] as num?)?.toInt(),
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'flair_name': instance.flairName,
  'flair_url': instance.flairUrl,
  'flair_bg_color': instance.flairBgColor,
  'flair_color': instance.flairColor,
  'flair_group_id': instance.flairGroupId,
  'admin': instance.admin,
  'moderator': instance.moderator,
  'trust_level': instance.trustLevel,
  'count': instance.count,
  'animated_avatar': instance.animatedAvatar,
};

Group _$GroupFromJson(Map<String, dynamic> json) =>
    Group(id: (json['id'] as num).toInt(), name: json['name'] as String?);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

FlairGroup _$FlairGroupFromJson(Map<String, dynamic> json) => FlairGroup(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  flairUrl: json['flair_url'] as String?,
  flairBgColor: json['flair_bg_color'] as String?,
  flairColor: json['flair_color'] as String?,
);

Map<String, dynamic> _$FlairGroupToJson(FlairGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'flair_url': instance.flairUrl,
      'flair_bg_color': instance.flairBgColor,
      'flair_color': instance.flairColor,
    };

TopicList _$TopicListFromJson(Map<String, dynamic> json) => TopicList(
  canCreateTopic: json['can_create_topic'] as bool?,
  moreTopicsUrl: json['more_topics_url'] as String?,
  forPeriod: json['for_period'] as String?,
  perPage: (json['per_page'] as num?)?.toInt(),
  topTags: (json['top_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  topics: (json['topics'] as List<dynamic>)
      .map((e) => Topic.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TopicListToJson(TopicList instance) => <String, dynamic>{
  'can_create_topic': instance.canCreateTopic,
  'more_topics_url': instance.moreTopicsUrl,
  'for_period': instance.forPeriod,
  'per_page': instance.perPage,
  'top_tags': instance.topTags,
  'topics': instance.topics,
};

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: (json['id'] as num).toInt(),
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
  pinned: json['pinned'] as bool?,
  unpinned: json['unpinned'],
  excerpt: json['excerpt'] as String?,
  visible: json['visible'] as bool?,
  closed: json['closed'] as bool?,
  archived: json['archived'] as bool?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  views: (json['views'] as num?)?.toInt(),
  likeCount: (json['like_count'] as num?)?.toInt(),
  hasSummary: json['has_summary'] as bool?,
  lastPosterUsername: json['last_poster_username'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  pinnedGlobally: json['pinned_globally'] as bool?,
  featuredLink: json['featured_link'],
  hasAcceptedAnswer: json['has_accepted_answer'] as bool?,
  posters: (json['posters'] as List<dynamic>?)
      ?.map((e) => Poster.fromJson(e as Map<String, dynamic>))
      .toList(),
  bookmarked: json['bookmarked'] as bool?,
  postNumber: (json['post_number'] as num?)?.toInt(),
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
  'pinned': instance.pinned,
  'unpinned': instance.unpinned,
  'excerpt': instance.excerpt,
  'visible': instance.visible,
  'closed': instance.closed,
  'archived': instance.archived,
  'tags': instance.tags,
  'views': instance.views,
  'like_count': instance.likeCount,
  'has_summary': instance.hasSummary,
  'last_poster_username': instance.lastPosterUsername,
  'category_id': instance.categoryId,
  'pinned_globally': instance.pinnedGlobally,
  'featured_link': instance.featuredLink,
  'has_accepted_answer': instance.hasAcceptedAnswer,
  'posters': instance.posters,
  'bookmarked': instance.bookmarked,
  'post_number': instance.postNumber,
};

Poster _$PosterFromJson(Map<String, dynamic> json) => Poster(
  extras: json['extras'],
  description: json['description'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  primaryGroupId: (json['primary_group_id'] as num?)?.toInt(),
  flairGroupId: (json['flair_group_id'] as num?)?.toInt(),
  avatarTemplate: json['avatar_template'] as String?,
);

Map<String, dynamic> _$PosterToJson(Poster instance) => <String, dynamic>{
  'extras': instance.extras,
  'description': instance.description,
  'user_id': instance.userId,
  'primary_group_id': instance.primaryGroupId,
  'flair_group_id': instance.flairGroupId,
  'avatar_template': instance.avatarTemplate,
};
