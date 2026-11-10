import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
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
  @JsonKey(name: 'parent_category_id')
  final int? parentCategoryId;
  @JsonKey(name: 'uploaded_logo')
  final CategoryLogo? logo;
  @JsonKey(name: 'uploaded_logo_dark')
  final CategoryLogoDark? logoDark;
  @JsonKey(name: 'english_name')
  final String? englishName;
  final String? slug;

  Category({
    required this.id,
    required this.name,
    this.color,
    this.textColor,
    this.description,
    this.topicCount,
    this.postCount,
    this.position,
    this.parentCategoryId,
    this.logo,
    this.logoDark,
    this.englishName,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}

@JsonSerializable()
class CategoryLogo {
  final int id;
  final String url;
  final int width;
  final int height;

  CategoryLogo({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  String get imageUrl {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '${HttpConfig.baseUrl}$url';
  }

  factory CategoryLogo.fromJson(Map<String, dynamic> json) =>
      _$CategoryLogoFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryLogoToJson(this);
}

@JsonSerializable()
class CategoryLogoDark {
  final int id;
  final String url;
  final int width;
  final int height;

  CategoryLogoDark({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  String get imageUrl =>
      url.startsWith('http') ? url : '${HttpConfig.baseUrl}$url';

  factory CategoryLogoDark.fromJson(Map<String, dynamic> json) =>
      _$CategoryLogoDarkFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryLogoDarkToJson(this);
}
