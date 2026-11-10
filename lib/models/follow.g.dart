// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Follow _$FollowFromJson(Map<String, dynamic> json) => Follow(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$FollowToJson(Follow instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'animated_avatar': instance.animatedAvatar,
};
