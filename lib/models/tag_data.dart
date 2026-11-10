import 'package:json_annotation/json_annotation.dart';

part 'tag_data.g.dart';

@JsonSerializable()
class TagResponse {
  final List<TagItem> results;
  @JsonKey(name: 'required_tag_group')
  final RequiredTagGroup? requiredTagGroup;

  TagResponse({
    required this.results,
    this.requiredTagGroup,
  });

  factory TagResponse.fromJson(Map<String, dynamic> json) =>
      _$TagResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TagResponseToJson(this);
}

@JsonSerializable()
class TagItem {
  final String id;
  final String text;
  final String name;
  final String? description;
  final int count;
  @JsonKey(name: 'pm_only')
  final bool pmOnly;
  @JsonKey(name: 'target_tag')
  final String? targetTag;

  TagItem({
    required this.id,
    required this.text,
    required this.name,
    this.description,
    required this.count,
    required this.pmOnly,
    this.targetTag,
  });

  factory TagItem.fromJson(Map<String, dynamic> json) =>
      _$TagItemFromJson(json);
  Map<String, dynamic> toJson() => _$TagItemToJson(this);
}

@JsonSerializable()
class RequiredTagGroup {
  final String name;
  @JsonKey(name: 'min_count')
  final int minCount;

  RequiredTagGroup({
    required this.name,
    required this.minCount,
  });

  factory RequiredTagGroup.fromJson(Map<String, dynamic> json) =>
      _$RequiredTagGroupFromJson(json);
  Map<String, dynamic> toJson() => _$RequiredTagGroupToJson(this);
}
