import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'badge_detail.g.dart';

@JsonSerializable()
class BadgeDetailResponse {
  @JsonKey(name: 'badge_types', defaultValue: [])
  final List<BadgeType>? badgeTypes;
  @JsonKey(name: 'badge_groupings', defaultValue: [])
  final List<BadgeGrouping>? badgeGroupings;
  @JsonKey(defaultValue: [])
  final List<BadgeDetail>? badges;

  BadgeDetailResponse({
    required this.badgeTypes,
    required this.badgeGroupings,
    required this.badges,
  });

  factory BadgeDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$BadgeDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeDetailResponseToJson(this);
}

@JsonSerializable()
class BadgeType {
  final int id;
  final String name;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  BadgeType({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory BadgeType.fromJson(Map<String, dynamic> json) =>
      _$BadgeTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeTypeToJson(this);
}

@JsonSerializable()
class BadgeGrouping {
  final int id;
  final String name;
  final String? description;
  final int position;
  final bool system;

  BadgeGrouping({
    required this.id,
    required this.name,
    this.description,
    required this.position,
    required this.system,
  });

  String getDisplayName() {
    switch (name) {
      case 'Getting Started':
        return '入门';
      case 'Community':
        return '社区';
      case 'Posting':
        return '发帖';
      case 'Trust Level':
        return '信任等级';
      default:
        return name;
    }
  }

  factory BadgeGrouping.fromJson(Map<String, dynamic> json) =>
      _$BadgeGroupingFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeGroupingToJson(this);
}

@JsonSerializable()
class BadgeDetail {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: 'grant_count')
  final int grantCount;
  @JsonKey(name: 'allow_title')
  final bool allowTitle;
  @JsonKey(name: 'multiple_grant')
  final bool multipleGrant;
  final String? icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final bool listable;
  final bool enabled;
  @JsonKey(name: 'badge_grouping_id')
  final int badgeGroupingId;
  final bool system;
  @JsonKey(name: 'long_description')
  final String? longDescription;
  final String slug;
  @JsonKey(name: 'has_badge', defaultValue: false)
  final bool hasBadge;
  @JsonKey(name: 'manually_grantable', defaultValue: false)
  final bool manuallyGrantable;
  @JsonKey(name: 'show_in_post_header', defaultValue: false)
  final bool showInPostHeader;
  @JsonKey(name: 'badge_type_id')
  final int badgeTypeId;

  BadgeDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.grantCount,
    required this.allowTitle,
    required this.multipleGrant,
    this.icon,
    this.imageUrl,
    required this.listable,
    required this.enabled,
    required this.badgeGroupingId,
    required this.system,
    this.longDescription,
    required this.slug,
    required this.hasBadge,
    required this.manuallyGrantable,
    required this.showInPostHeader,
    required this.badgeTypeId,
  });

  String getImageUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return '';
    }
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl!;
    }
    return '${HttpConfig.baseUrl}${imageUrl!.replaceAll('{size}', '80')}';
  }

  // 添加一些随机的颜色字符串
  final List<String> randomColors = [
    '#FF0000',
    '#00FF00',
    '#0000FF',
    '#FFFF00',
    '#FF00FF',
    '#00FFFF',
    '#FFFFFF',
    '#000000'
  ];

  factory BadgeDetail.fromJson(Map<String, dynamic> json) =>
      _$BadgeDetailFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeDetailToJson(this);
}
