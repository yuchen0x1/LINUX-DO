// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
  posts:
      (json['posts'] as List<dynamic>?)
          ?.map((e) => SearchPost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  users: json['users'] as List<dynamic>? ?? [],
  categories: json['categories'] as List<dynamic>? ?? [],
  tags: json['tags'] as List<dynamic>? ?? [],
  groups: json['groups'] as List<dynamic>? ?? [],
  groupedSearchResult: GroupedSearchResult.fromJson(
    json['grouped_search_result'] as Map<String, dynamic>,
  ),
  userIds:
      (json['user_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  categoryIds:
      (json['category_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  tagIds:
      (json['tag_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  groupIds:
      (json['group_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'topics': instance.topics,
      'users': instance.users,
      'categories': instance.categories,
      'tags': instance.tags,
      'groups': instance.groups,
      'grouped_search_result': instance.groupedSearchResult,
      'user_ids': instance.userIds,
      'category_ids': instance.categoryIds,
      'tag_ids': instance.tagIds,
      'group_ids': instance.groupIds,
    };

SearchPost _$SearchPostFromJson(Map<String, dynamic> json) => SearchPost(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  username: json['username'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  createdAt: json['created_at'] as String?,
  likeCount: (json['like_count'] as num).toInt(),
  blurb: json['blurb'] as String?,
  postNumber: (json['post_number'] as num).toInt(),
  topicId: (json['topic_id'] as num).toInt(),
);

Map<String, dynamic> _$SearchPostToJson(SearchPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'avatar_template': instance.avatarTemplate,
      'created_at': instance.createdAt,
      'like_count': instance.likeCount,
      'blurb': instance.blurb,
      'post_number': instance.postNumber,
      'topic_id': instance.topicId,
    };

GroupedSearchResult _$GroupedSearchResultFromJson(Map<String, dynamic> json) =>
    GroupedSearchResult(
      morePosts: json['more_posts'],
      moreUsers: json['more_users'],
      moreCategories: json['more_categories'],
      term: json['term'] as String,
      searchLogId: (json['search_log_id'] as num).toInt(),
      moreFullPageResults: json['more_full_page_results'] as bool?,
      canCreateTopic: json['can_create_topic'] as bool,
      error: json['error'],
      extra: json['extra'] as Map<String, dynamic>,
      postIds: (json['post_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$GroupedSearchResultToJson(
  GroupedSearchResult instance,
) => <String, dynamic>{
  'more_posts': instance.morePosts,
  'more_users': instance.moreUsers,
  'more_categories': instance.moreCategories,
  'term': instance.term,
  'search_log_id': instance.searchLogId,
  'more_full_page_results': instance.moreFullPageResults,
  'can_create_topic': instance.canCreateTopic,
  'error': instance.error,
  'extra': instance.extra,
  'post_ids': instance.postIds,
};
