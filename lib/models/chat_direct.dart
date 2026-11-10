import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/models/chat_message.dart';

part 'chat_direct.g.dart';

@JsonSerializable()
class ChatDirect {
  final ChatMessage? channel;

  ChatDirect({this.channel});

  factory ChatDirect.fromJson(Map<String, dynamic> json) =>
      _$ChatDirectFromJson(json);
  Map<String, dynamic> toJson() => _$ChatDirectToJson(this);
}
