import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable()
class Badge {
  final String title;
  final String subtitle;
  final int progress;
  final int total;
  final String icon;

  Badge({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.total,
    required this.icon,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}
