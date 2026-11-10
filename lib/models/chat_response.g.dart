// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
  publicChannels: (json['public_channels'] as List<dynamic>?)
      ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  directMessageChannels: (json['direct_message_channels'] as List<dynamic>?)
      ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'public_channels': instance.publicChannels,
      'direct_message_channels': instance.directMessageChannels,
    };
