import 'package:json_annotation/json_annotation.dart';
import 'chat_detail_message.dart';

part 'chat_messages_response.g.dart';

@JsonSerializable()
class ChatMessagesResponse {
  final List<ChatDetailMessage> messages;
  final Map<String, dynamic> tracking;
  final ChatMessageMeta meta;

  ChatMessagesResponse({
    required this.messages,
    required this.tracking,
    required this.meta,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessagesResponseToJson(this);
}

@JsonSerializable()
class ChatMessageMeta {
  @JsonKey(name: 'target_message_id')
  final int? targetMessageId;

  @JsonKey(name: 'can_load_more_future', defaultValue: false)
  final bool canLoadMoreFuture;

  @JsonKey(name: 'can_load_more_past', defaultValue: false)
  final bool canLoadMorePast;

  ChatMessageMeta({
    this.targetMessageId,
    this.canLoadMoreFuture = false,
    this.canLoadMorePast = false,
  });

  factory ChatMessageMeta.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageMetaToJson(this);
}
