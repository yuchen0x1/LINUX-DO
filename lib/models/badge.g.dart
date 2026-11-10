// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  progress: (json['progress'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  icon: json['icon'] as String,
);

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
  'title': instance.title,
  'subtitle': instance.subtitle,
  'progress': instance.progress,
  'total': instance.total,
  'icon': instance.icon,
};
