// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) => UserStatus(
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
  endsAt: json['ends_at'] as String?,
  messageBusLastId: (json['message_bus_last_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{
      'description': instance.description,
      'emoji': instance.emoji,
      'ends_at': instance.endsAt,
      'message_bus_last_id': instance.messageBusLastId,
    };
