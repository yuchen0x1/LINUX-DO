import 'package:json_annotation/json_annotation.dart';

import '../utils/expand/datetime_expand.dart';

part 'chat_detail_message.g.dart';

@JsonSerializable()
class ChatDetailMessage {
  final int? id;
  final String? message;
  final String? cooked;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? excerpt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'deleted_by_id')
  final int? deletedById;
  @JsonKey(name: 'thread_id')
  final int? threadId;
  @JsonKey(name: 'chat_channel_id')
  final int? channelId;
  final bool streaming;
  final ChatMessageUser? user;
  @JsonKey(name: 'mentioned_users')
  final List<ChatMessageUser>? mentionedUsers;
  @JsonKey(name: 'available_flags')
  final List<String?>? availableFlags;
  final List<dynamic>? blocks;
  @JsonKey(name: 'chat_webhook_event')
  final dynamic chatWebhookEvent;
  final List<dynamic>? uploads;

  String get friendlyTime {
    if (createdAt == null) return '';
    return DateTime.parse(createdAt!).friendlyDateTime2;
  }

  ChatDetailMessage({
    this.id,
    this.message,
    this.cooked,
    this.createdAt,
    this.excerpt,
    this.deletedAt,
    this.deletedById,
    this.threadId,
    this.channelId,
    required this.streaming,
    this.user,
    this.mentionedUsers,
    this.availableFlags,
    this.blocks,
    this.chatWebhookEvent,
    this.uploads,
  });

  factory ChatDetailMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatDetailMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatDetailMessageToJson(this);
}

@JsonSerializable()
class ChatMessageUser {
  final int id;
  final String username;
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'can_chat')
  final bool? canChat;
  @JsonKey(name: 'has_chat_enabled')
  final bool? hasChatEnabled;
  final bool? moderator;
  final bool? admin;
  final bool? staff;
  @JsonKey(name: 'new_user')
  final bool? newUser;
  @JsonKey(name: 'primary_group_name')
  final String? primaryGroupName;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  ChatMessageUser({
    required this.id,
    required this.username,
    this.name,
    this.avatarTemplate,
    this.canChat,
    this.hasChatEnabled,
    this.moderator,
    this.admin,
    this.staff,
    this.newUser,
    this.primaryGroupName,
    this.animatedAvatar,
  });

  factory ChatMessageUser.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageUserToJson(this);
}
