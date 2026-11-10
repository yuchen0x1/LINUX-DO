import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'category_data.g.dart';

@JsonSerializable()
class CategoryListResponse {
  @JsonKey(name: 'category_list')
  final CategoryList categoryList;

  CategoryListResponse(this.categoryList);

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryListResponseToJson(this);
}

@JsonSerializable()
class CategoryList {
  @JsonKey(name: 'categories')
  final List<Category> categories;

  CategoryList(this.categories);

  factory CategoryList.fromJson(Map<String, dynamic> json) =>
      _$CategoryListFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryListToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String? name;
  @JsonKey(name: 'color')
  final String? color;
  @JsonKey(name: 'text_color')
  final String? textColor;
  final String? description;
  @JsonKey(name: 'topic_count')
  final int? topicCount;
  @JsonKey(name: 'post_count')
  final int? postCount;
  final int? position;
  @JsonKey(name: 'description_text')
  final String? descriptionText;
  @JsonKey(name: 'description_excerpt')
  final String? descriptionExcerpt;
  @JsonKey(name: 'topic_url')
  final String? topicUrl;
  @JsonKey(name: 'read_restricted')
  final bool? readRestricted;
  final int? permission;
  @JsonKey(name: 'notification_level')
  final int? notificationLevel;
  @JsonKey(name: 'can_edit')
  final bool? canEdit;
  @JsonKey(name: 'topic_template')
  final String? topicTemplate;
  @JsonKey(name: 'has_children')
  final bool? hasChildren;
  @JsonKey(name: 'sort_order')
  final String? sortOrder;
  @JsonKey(name: 'sort_ascending')
  final bool? sortAscending;
  @JsonKey(name: 'show_subcategory_list')
  final bool? showSubcategoryList;
  @JsonKey(name: 'num_featured_topics')
  final int? numFeaturedTopics;
  @JsonKey(name: 'default_view')
  final String? defaultView;
  @JsonKey(name: 'subcategory_list_style')
  final String? subcategoryListStyle;
  @JsonKey(name: 'default_top_period')
  final String? defaultTopPeriod;
  @JsonKey(name: 'default_list_filter')
  final String? defaultListFilter;
  @JsonKey(name: 'minimum_required_tags')
  final int? minimumRequiredTags;
  @JsonKey(name: 'navigate_to_first_post_after_read')
  final bool? navigateToFirstPostAfterRead;
  @JsonKey(name: 'uploaded_logo')
  final UploadedImage? uploadedLogo;
  @JsonKey(name: 'uploaded_background')
  final UploadedImage? uploadedBackground;

  Category({
    required this.id,
    this.name,
    this.color,
    this.textColor,
    this.description,
    this.topicCount,
    this.postCount,
    this.position,
    this.descriptionText,
    this.descriptionExcerpt,
    this.topicUrl,
    this.readRestricted,
    this.permission,
    this.notificationLevel,
    this.canEdit,
    this.topicTemplate,
    this.hasChildren,
    this.sortOrder,
    this.sortAscending,
    this.showSubcategoryList,
    this.numFeaturedTopics,
    this.defaultView,
    this.subcategoryListStyle,
    this.defaultTopPeriod,
    this.defaultListFilter,
    this.minimumRequiredTags,
    this.navigateToFirstPostAfterRead,
    this.uploadedLogo,
    this.uploadedBackground,
  });

  String getLogoUrl() {
    if (uploadedLogo == null) return '';
    if (uploadedLogo!.url!.startsWith('http://') ||
        uploadedLogo!.url!.startsWith('https://')) {
      return uploadedLogo!.url!;
    }
    return '${HttpConfig.baseUrl}${uploadedLogo!.url!}';
  }

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class UploadedImage {
  final String? url;
  final int? width;
  final int? height;

  UploadedImage({this.url, this.width, this.height});

  factory UploadedImage.fromJson(Map<String, dynamic> json) =>
      _$UploadedImageFromJson(json);
  Map<String, dynamic> toJson() => _$UploadedImageToJson(this);
}

@JsonSerializable()
class CategoryTopic {
  final int id;
  final String title;
  @JsonKey(name: 'fancy_title')
  final String fancyTitle;
  final String slug;
  @JsonKey(name: 'posts_count')
  final int postsCount;
  @JsonKey(name: 'reply_count')
  final int replyCount;
  @JsonKey(name: 'highest_post_number')
  final int highestPostNumber;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'last_posted_at')
  final String lastPostedAt;
  final bool bumped;
  @JsonKey(name: 'bumped_at')
  final String bumpedAt;
  final String archetype;
  final bool unseen;
  final bool pinned;
  final bool? unpinned;
  final bool visible;
  final bool closed;
  final bool archived;
  final bool? bookmarked;
  final bool? liked;
  @JsonKey(name: 'has_accepted_answer')
  final bool hasAcceptedAnswer;
  @JsonKey(name: 'can_have_answer')
  final bool canHaveAnswer;
  @JsonKey(name: 'last_poster')
  final LastPoster lastPoster;

  CategoryTopic({
    required this.id,
    required this.title,
    required this.fancyTitle,
    required this.slug,
    required this.postsCount,
    required this.replyCount,
    required this.highestPostNumber,
    this.imageUrl,
    required this.createdAt,
    required this.lastPostedAt,
    required this.bumped,
    required this.bumpedAt,
    required this.archetype,
    required this.unseen,
    required this.pinned,
    this.unpinned,
    required this.visible,
    required this.closed,
    required this.archived,
    this.bookmarked,
    this.liked,
    required this.hasAcceptedAnswer,
    required this.canHaveAnswer,
    required this.lastPoster,
  });

  factory CategoryTopic.fromJson(Map<String, dynamic> json) =>
      _$CategoryTopicFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryTopicToJson(this);
}

@JsonSerializable()
class LastPoster {
  final int id;
  final String username;
  final String name;
  @JsonKey(name: 'avatar_template')
  final String avatarTemplate;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  LastPoster({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarTemplate,
    this.animatedAvatar,
  });

  factory LastPoster.fromJson(Map<String, dynamic> json) =>
      _$LastPosterFromJson(json);
  Map<String, dynamic> toJson() => _$LastPosterToJson(this);
}
