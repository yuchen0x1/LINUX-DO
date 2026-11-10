// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatDirect _$ChatDirectFromJson(Map<String, dynamic> json) => ChatDirect(
  channel: json['channel'] == null
      ? null
      : ChatMessage.fromJson(json['channel'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatDirectToJson(ChatDirect instance) =>
    <String, dynamic>{'channel': instance.channel};
