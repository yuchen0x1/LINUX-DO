import 'package:json_annotation/json_annotation.dart';

import 'topic_model.dart';
part 'docs.g.dart';

@JsonSerializable()
class Docs {
  @JsonKey(name: 'topic_count')
  int? topicCount;

  @JsonKey(name: 'topics')
  TopicListResponse? topics;

  @JsonKey(name: 'tags')
  List<DocTag>? tags;

  Docs({this.topicCount, this.topics, this.tags});

  factory Docs.fromJson(Map<String, dynamic> json) => _$DocsFromJson(json);
  Map<String, dynamic> toJson() => _$DocsToJson(this);
}

@JsonSerializable()
class DocTag {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'active')
  bool? active;

  @JsonKey(name: 'count')
  int? count;

  DocTag({this.id, this.active, this.count});

  factory DocTag.fromJson(Map<String, dynamic> json) => _$DocTagFromJson(json);
  Map<String, dynamic> toJson() => _$DocTagToJson(this);
}
