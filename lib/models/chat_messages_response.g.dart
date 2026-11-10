// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_messages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessagesResponse _$ChatMessagesResponseFromJson(
  Map<String, dynamic> json,
) => ChatMessagesResponse(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => ChatDetailMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  tracking: json['tracking'] as Map<String, dynamic>,
  meta: ChatMessageMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessagesResponseToJson(
  ChatMessagesResponse instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'tracking': instance.tracking,
  'meta': instance.meta,
};

ChatMessageMeta _$ChatMessageMetaFromJson(Map<String, dynamic> json) =>
    ChatMessageMeta(
      targetMessageId: (json['target_message_id'] as num?)?.toInt(),
      canLoadMoreFuture: json['can_load_more_future'] as bool? ?? false,
      canLoadMorePast: json['can_load_more_past'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatMessageMetaToJson(ChatMessageMeta instance) =>
    <String, dynamic>{
      'target_message_id': instance.targetMessageId,
      'can_load_more_future': instance.canLoadMoreFuture,
      'can_load_more_past': instance.canLoadMorePast,
    };
