import 'package:json_annotation/json_annotation.dart';
import 'topic_model.dart';

part 'search_result.g.dart';

@JsonSerializable()
class SearchResult {
  @JsonKey(defaultValue: [])
  final List<SearchPost> posts;
  @JsonKey(defaultValue: [])
  final List<Topic> topics;
  @JsonKey(defaultValue: [])
  final List<dynamic> users;
  @JsonKey(defaultValue: [])
  final List<dynamic> categories;
  @JsonKey(defaultValue: [])
  final List<dynamic> tags;
  @JsonKey(defaultValue: [])
  final List<dynamic> groups;
  @JsonKey(name: 'grouped_search_result')
  final GroupedSearchResult groupedSearchResult;
  @JsonKey(name: 'user_ids', defaultValue: [])
  final List<int> userIds;
  @JsonKey(name: 'category_ids', defaultValue: [])
  final List<int> categoryIds;
  @JsonKey(name: 'tag_ids', defaultValue: [])
  final List<int> tagIds;
  @JsonKey(name: 'group_ids', defaultValue: [])
  final List<int> groupIds;

  SearchResult({
    required this.posts,
    required this.topics,
    required this.users,
    required this.categories,
    required this.tags,
    required this.groups,
    required this.groupedSearchResult,
    required this.userIds,
    required this.categoryIds,
    required this.tagIds,
    required this.groupIds,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

@JsonSerializable()
class SearchPost {
  final int id;
  final String? name;
  final String? username;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'like_count')
  final int likeCount;
  final String? blurb;
  @JsonKey(name: 'post_number')
  final int postNumber;
  @JsonKey(name: 'topic_id')
  final int topicId;

  SearchPost({
    required this.id,
    this.name,
    this.username,
    this.avatarTemplate,
    this.createdAt,
    required this.likeCount,
    this.blurb,
    required this.postNumber,
    required this.topicId,
  });

  factory SearchPost.fromJson(Map<String, dynamic> json) =>
      _$SearchPostFromJson(json);
  Map<String, dynamic> toJson() => _$SearchPostToJson(this);
}

@JsonSerializable()
class GroupedSearchResult {
  @JsonKey(name: 'more_posts')
  final dynamic morePosts;
  @JsonKey(name: 'more_users')
  final dynamic moreUsers;
  @JsonKey(name: 'more_categories')
  final dynamic moreCategories;
  final String term;
  @JsonKey(name: 'search_log_id')
  final int searchLogId;
  @JsonKey(name: 'more_full_page_results')
  final bool? moreFullPageResults;
  @JsonKey(name: 'can_create_topic')
  final bool canCreateTopic;
  final dynamic error;
  final Map<String, dynamic> extra;
  @JsonKey(name: 'post_ids')
  final List<int> postIds;

  GroupedSearchResult({
    this.morePosts,
    this.moreUsers,
    this.moreCategories,
    required this.term,
    required this.searchLogId,
    this.moreFullPageResults,
    required this.canCreateTopic,
    this.error,
    required this.extra,
    required this.postIds,
  });

  factory GroupedSearchResult.fromJson(Map<String, dynamic> json) =>
      _$GroupedSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$GroupedSearchResultToJson(this);
}
