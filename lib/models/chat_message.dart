import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

import 'chat_detail_message.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final int id;
  @JsonKey(name: 'allow_channel_wide_mentions')
  final bool allowChannelWideMentions;
  final ChatableData chatable;
  @JsonKey(name: 'chatable_id')
  final int chatableId;
  @JsonKey(name: 'chatable_type')
  final String? chatableType;
  @JsonKey(name: 'chatable_url')
  final String? chatableUrl;
  final String? description;
  final String? title;
  @JsonKey(name: 'unicode_title')
  final String? unicodeTitle;
  final String? slug;
  final String? status;
  @JsonKey(name: 'memberships_count')
  final int? membershipsCount;
  @JsonKey(name: 'current_user_membership')
  final Membership? currentUserMembership;
  @JsonKey(name: 'threading_enabled')
  final bool? threadingEnabled;
  @JsonKey(name: 'icon_upload_url')
  final String? iconUploadUrl;
  @JsonKey(name: 'last_message')
  final ChatDetailMessage? lastMessage;
  final Meta meta;

  ChatMessage({
    required this.id,
    required this.allowChannelWideMentions,
    required this.chatable,
    required this.chatableId,
    this.chatableType,
    this.chatableUrl,
    this.description,
    this.title,
    this.unicodeTitle,
    this.slug,
    this.status,
    this.membershipsCount,
    this.currentUserMembership,
    this.threadingEnabled,
    this.iconUploadUrl,
    this.lastMessage,
    required this.meta,
  });

  String getAvatarUrl() {
    if (chatable.users?.isNotEmpty == true) {
      final user = chatable.users!.first;
      final avatarTemplate = user.avatarTemplate;
      if (avatarTemplate != null) {
        if (avatarTemplate.startsWith('http://') ||
            avatarTemplate.startsWith('https://')) {
          return avatarTemplate;
        }
        return '${HttpConfig.baseUrl}${avatarTemplate.replaceAll('{size}', '100')}';
      }
    }
    final logo = chatable.uploadedLogo;
    if (logo?.url != null) {
      final url = logo!.url;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      return '${HttpConfig.baseUrl}$url';
    }
    return '';
  }

  bool isWebMaster() {
    return chatable.users?.first.id == 1;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class ChatableData {
  final bool? group;
  final List<ChatUser>? users;
  @JsonKey(name: 'uploaded_logo')
  final UploadedLogo? uploadedLogo;

  ChatableData({this.group, this.users, this.uploadedLogo});

  factory ChatableData.fromJson(Map<String, dynamic> json) =>
      _$ChatableDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatableDataToJson(this);
}

@JsonSerializable()
class ChatUser {
  final int id;
  final String username;
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  final UserStatus? status;

  ChatUser({
    required this.id,
    required this.username,
    this.name,
    this.avatarTemplate,
    this.status,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}

@JsonSerializable()
class UserStatus {
  final String? description;
  final String? emoji;
  @JsonKey(name: 'ends_at')
  final String? endsAt;

  UserStatus({this.description, this.emoji, this.endsAt});

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}

@JsonSerializable()
class Membership {
  final bool following;
  final bool muted;
  @JsonKey(name: 'notification_level')
  final String notificationLevel;
  @JsonKey(name: 'chat_channel_id')
  final int chatChannelId;
  @JsonKey(name: 'last_read_message_id')
  final int? lastReadMessageId;
  @JsonKey(name: 'last_viewed_at')
  final String lastViewedAt;

  Membership({
    required this.following,
    required this.muted,
    required this.notificationLevel,
    required this.chatChannelId,
    this.lastReadMessageId,
    required this.lastViewedAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
  Map<String, dynamic> toJson() => _$MembershipToJson(this);
}

@JsonSerializable()
class UploadedLogo {
  final int id;
  final String url;
  final int width;
  final int height;

  UploadedLogo({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  factory UploadedLogo.fromJson(Map<String, dynamic> json) =>
      _$UploadedLogoFromJson(json);
  Map<String, dynamic> toJson() => _$UploadedLogoToJson(this);
}

@JsonSerializable()
class Meta {
  @JsonKey(name: 'message_bus_last_ids')
  final MessageBusLastIds messageBusLastIds;
  @JsonKey(name: 'can_join_chat_channel')
  final bool canJoinChatChannel;
  @JsonKey(name: 'can_flag')
  final bool canFlag;
  @JsonKey(name: 'user_silenced')
  final bool userSilenced;
  @JsonKey(name: 'can_moderate')
  final bool canModerate;
  @JsonKey(name: 'can_delete_self')
  final bool canDeleteSelf;
  @JsonKey(name: 'can_delete_others')
  final bool canDeleteOthers;

  Meta({
    required this.messageBusLastIds,
    required this.canJoinChatChannel,
    required this.canFlag,
    required this.userSilenced,
    required this.canModerate,
    required this.canDeleteSelf,
    required this.canDeleteOthers,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable()
class MessageBusLastIds {
  @JsonKey(name: 'channel_message_bus_last_id')
  final int channelMessageBusLastId;
  @JsonKey(name: 'new_messages')
  final int newMessages;
  @JsonKey(name: 'new_mentions')
  final int newMentions;

  MessageBusLastIds({
    required this.channelMessageBusLastId,
    required this.newMessages,
    required this.newMentions,
  });

  factory MessageBusLastIds.fromJson(Map<String, dynamic> json) =>
      _$MessageBusLastIdsFromJson(json);
  Map<String, dynamic> toJson() => _$MessageBusLastIdsToJson(this);
}
