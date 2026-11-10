// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) => UserRequest(
  name: json['name'] as String,
  title: json['title'] as String,
  primaryGroupId: (json['primary_group_id'] as num).toInt(),
  flairGroupId: (json['flair_group_id'] as num).toInt(),
  status: UserStatus.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'primary_group_id': instance.primaryGroupId,
      'flair_group_id': instance.flairGroupId,
      'status': instance.status,
    };

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) => UserStatus(
  description: json['description'] as String,
  emoji: json['emoji'] as String,
  endsAt: json['ends_at'] as String?,
  messageBusLastId: (json['message_bus_last_id'] as num).toInt(),
);

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{
      'description': instance.description,
      'emoji': instance.emoji,
      'ends_at': instance.endsAt,
      'message_bus_last_id': instance.messageBusLastId,
    };
