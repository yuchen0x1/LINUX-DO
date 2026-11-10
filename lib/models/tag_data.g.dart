// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagResponse _$TagResponseFromJson(Map<String, dynamic> json) => TagResponse(
  results: (json['results'] as List<dynamic>)
      .map((e) => TagItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  requiredTagGroup: json['required_tag_group'] == null
      ? null
      : RequiredTagGroup.fromJson(
          json['required_tag_group'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$TagResponseToJson(TagResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
      'required_tag_group': instance.requiredTagGroup,
    };

TagItem _$TagItemFromJson(Map<String, dynamic> json) => TagItem(
  id: json['id'] as String,
  text: json['text'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  count: (json['count'] as num).toInt(),
  pmOnly: json['pm_only'] as bool,
  targetTag: json['target_tag'] as String?,
);

Map<String, dynamic> _$TagItemToJson(TagItem instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'name': instance.name,
  'description': instance.description,
  'count': instance.count,
  'pm_only': instance.pmOnly,
  'target_tag': instance.targetTag,
};

RequiredTagGroup _$RequiredTagGroupFromJson(Map<String, dynamic> json) =>
    RequiredTagGroup(
      name: json['name'] as String,
      minCount: (json['min_count'] as num).toInt(),
    );

Map<String, dynamic> _$RequiredTagGroupToJson(RequiredTagGroup instance) =>
    <String, dynamic>{'name': instance.name, 'min_count': instance.minCount};
