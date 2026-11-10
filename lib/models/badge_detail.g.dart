// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeDetailResponse _$BadgeDetailResponseFromJson(Map<String, dynamic> json) =>
    BadgeDetailResponse(
      badgeTypes:
          (json['badge_types'] as List<dynamic>?)
              ?.map((e) => BadgeType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      badgeGroupings:
          (json['badge_groupings'] as List<dynamic>?)
              ?.map((e) => BadgeGrouping.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$BadgeDetailResponseToJson(
  BadgeDetailResponse instance,
) => <String, dynamic>{
  'badge_types': instance.badgeTypes,
  'badge_groupings': instance.badgeGroupings,
  'badges': instance.badges,
};

BadgeType _$BadgeTypeFromJson(Map<String, dynamic> json) => BadgeType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
);

Map<String, dynamic> _$BadgeTypeToJson(BadgeType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_order': instance.sortOrder,
};

BadgeGrouping _$BadgeGroupingFromJson(Map<String, dynamic> json) =>
    BadgeGrouping(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num).toInt(),
      system: json['system'] as bool,
    );

Map<String, dynamic> _$BadgeGroupingToJson(BadgeGrouping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'position': instance.position,
      'system': instance.system,
    };

BadgeDetail _$BadgeDetailFromJson(Map<String, dynamic> json) => BadgeDetail(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  grantCount: (json['grant_count'] as num).toInt(),
  allowTitle: json['allow_title'] as bool,
  multipleGrant: json['multiple_grant'] as bool,
  icon: json['icon'] as String?,
  imageUrl: json['image_url'] as String?,
  listable: json['listable'] as bool,
  enabled: json['enabled'] as bool,
  badgeGroupingId: (json['badge_grouping_id'] as num).toInt(),
  system: json['system'] as bool,
  longDescription: json['long_description'] as String?,
  slug: json['slug'] as String,
  hasBadge: json['has_badge'] as bool? ?? false,
  manuallyGrantable: json['manually_grantable'] as bool? ?? false,
  showInPostHeader: json['show_in_post_header'] as bool? ?? false,
  badgeTypeId: (json['badge_type_id'] as num).toInt(),
);

Map<String, dynamic> _$BadgeDetailToJson(BadgeDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'grant_count': instance.grantCount,
      'allow_title': instance.allowTitle,
      'multiple_grant': instance.multipleGrant,
      'icon': instance.icon,
      'image_url': instance.imageUrl,
      'listable': instance.listable,
      'enabled': instance.enabled,
      'badge_grouping_id': instance.badgeGroupingId,
      'system': instance.system,
      'long_description': instance.longDescription,
      'slug': instance.slug,
      'has_badge': instance.hasBadge,
      'manually_grantable': instance.manuallyGrantable,
      'show_in_post_header': instance.showInPostHeader,
      'badge_type_id': instance.badgeTypeId,
    };
