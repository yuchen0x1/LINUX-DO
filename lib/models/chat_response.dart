import 'package:json_annotation/json_annotation.dart';
import 'chat_message.dart';

part 'chat_response.g.dart';

@JsonSerializable()
class ChatResponse {
  @JsonKey(name: 'public_channels')
  final List<ChatMessage>? publicChannels;

  @JsonKey(name: 'direct_message_channels')
  final List<ChatMessage>? directMessageChannels;

  ChatResponse({this.publicChannels, this.directMessageChannels});

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}
