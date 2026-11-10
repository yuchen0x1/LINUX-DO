// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryListResponse _$CategoryListResponseFromJson(
  Map<String, dynamic> json,
) => CategoryListResponse(
  CategoryList.fromJson(json['category_list'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategoryListResponseToJson(
  CategoryListResponse instance,
) => <String, dynamic>{'category_list': instance.categoryList};

CategoryList _$CategoryListFromJson(Map<String, dynamic> json) => CategoryList(
  (json['categories'] as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryListToJson(CategoryList instance) =>
    <String, dynamic>{'categories': instance.categories};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  color: json['color'] as String?,
  textColor: json['text_color'] as String?,
  description: json['description'] as String?,
  topicCount: (json['topic_count'] as num?)?.toInt(),
  postCount: (json['post_count'] as num?)?.toInt(),
  position: (json['position'] as num?)?.toInt(),
  descriptionText: json['description_text'] as String?,
  descriptionExcerpt: json['description_excerpt'] as String?,
  topicUrl: json['topic_url'] as String?,
  readRestricted: json['read_restricted'] as bool?,
  permission: (json['permission'] as num?)?.toInt(),
  notificationLevel: (json['notification_level'] as num?)?.toInt(),
  canEdit: json['can_edit'] as bool?,
  topicTemplate: json['topic_template'] as String?,
  hasChildren: json['has_children'] as bool?,
  sortOrder: json['sort_order'] as String?,
  sortAscending: json['sort_ascending'] as bool?,
  showSubcategoryList: json['show_subcategory_list'] as bool?,
  numFeaturedTopics: (json['num_featured_topics'] as num?)?.toInt(),
  defaultView: json['default_view'] as String?,
  subcategoryListStyle: json['subcategory_list_style'] as String?,
  defaultTopPeriod: json['default_top_period'] as String?,
  defaultListFilter: json['default_list_filter'] as String?,
  minimumRequiredTags: (json['minimum_required_tags'] as num?)?.toInt(),
  navigateToFirstPostAfterRead:
      json['navigate_to_first_post_after_read'] as bool?,
  uploadedLogo: json['uploaded_logo'] == null
      ? null
      : UploadedImage.fromJson(json['uploaded_logo'] as Map<String, dynamic>),
  uploadedBackground: json['uploaded_background'] == null
      ? null
      : UploadedImage.fromJson(
          json['uploaded_background'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'text_color': instance.textColor,
  'description': instance.description,
  'topic_count': instance.topicCount,
  'post_count': instance.postCount,
  'position': instance.position,
  'description_text': instance.descriptionText,
  'description_excerpt': instance.descriptionExcerpt,
  'topic_url': instance.topicUrl,
  'read_restricted': instance.readRestricted,
  'permission': instance.permission,
  'notification_level': instance.notificationLevel,
  'can_edit': instance.canEdit,
  'topic_template': instance.topicTemplate,
  'has_children': instance.hasChildren,
  'sort_order': instance.sortOrder,
  'sort_ascending': instance.sortAscending,
  'show_subcategory_list': instance.showSubcategoryList,
  'num_featured_topics': instance.numFeaturedTopics,
  'default_view': instance.defaultView,
  'subcategory_list_style': instance.subcategoryListStyle,
  'default_top_period': instance.defaultTopPeriod,
  'default_list_filter': instance.defaultListFilter,
  'minimum_required_tags': instance.minimumRequiredTags,
  'navigate_to_first_post_after_read': instance.navigateToFirstPostAfterRead,
  'uploaded_logo': instance.uploadedLogo,
  'uploaded_background': instance.uploadedBackground,
};

UploadedImage _$UploadedImageFromJson(Map<String, dynamic> json) =>
    UploadedImage(
      url: json['url'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadedImageToJson(UploadedImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

CategoryTopic _$CategoryTopicFromJson(Map<String, dynamic> json) =>
    CategoryTopic(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      fancyTitle: json['fancy_title'] as String,
      slug: json['slug'] as String,
      postsCount: (json['posts_count'] as num).toInt(),
      replyCount: (json['reply_count'] as num).toInt(),
      highestPostNumber: (json['highest_post_number'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String,
      lastPostedAt: json['last_posted_at'] as String,
      bumped: json['bumped'] as bool,
      bumpedAt: json['bumped_at'] as String,
      archetype: json['archetype'] as String,
      unseen: json['unseen'] as bool,
      pinned: json['pinned'] as bool,
      unpinned: json['unpinned'] as bool?,
      visible: json['visible'] as bool,
      closed: json['closed'] as bool,
      archived: json['archived'] as bool,
      bookmarked: json['bookmarked'] as bool?,
      liked: json['liked'] as bool?,
      hasAcceptedAnswer: json['has_accepted_answer'] as bool,
      canHaveAnswer: json['can_have_answer'] as bool,
      lastPoster: LastPoster.fromJson(
        json['last_poster'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CategoryTopicToJson(CategoryTopic instance) =>
    <String, dynamic>{
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
      'visible': instance.visible,
      'closed': instance.closed,
      'archived': instance.archived,
      'bookmarked': instance.bookmarked,
      'liked': instance.liked,
      'has_accepted_answer': instance.hasAcceptedAnswer,
      'can_have_answer': instance.canHaveAnswer,
      'last_poster': instance.lastPoster,
    };

LastPoster _$LastPosterFromJson(Map<String, dynamic> json) => LastPoster(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String,
  avatarTemplate: json['avatar_template'] as String,
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$LastPosterToJson(LastPoster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar_template': instance.avatarTemplate,
      'animated_avatar': instance.animatedAvatar,
    };
