// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String?,
  textColor: json['text_color'] as String?,
  description: json['description'] as String?,
  topicCount: (json['topic_count'] as num?)?.toInt(),
  postCount: (json['post_count'] as num?)?.toInt(),
  position: (json['position'] as num?)?.toInt(),
  parentCategoryId: (json['parent_category_id'] as num?)?.toInt(),
  logo: json['uploaded_logo'] == null
      ? null
      : CategoryLogo.fromJson(json['uploaded_logo'] as Map<String, dynamic>),
  logoDark: json['uploaded_logo_dark'] == null
      ? null
      : CategoryLogoDark.fromJson(
          json['uploaded_logo_dark'] as Map<String, dynamic>,
        ),
  englishName: json['english_name'] as String?,
  slug: json['slug'] as String?,
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
  'parent_category_id': instance.parentCategoryId,
  'uploaded_logo': instance.logo,
  'uploaded_logo_dark': instance.logoDark,
  'english_name': instance.englishName,
  'slug': instance.slug,
};

CategoryLogo _$CategoryLogoFromJson(Map<String, dynamic> json) => CategoryLogo(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
);

Map<String, dynamic> _$CategoryLogoToJson(CategoryLogo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

CategoryLogoDark _$CategoryLogoDarkFromJson(Map<String, dynamic> json) =>
    CategoryLogoDark(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryLogoDarkToJson(CategoryLogoDark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };
