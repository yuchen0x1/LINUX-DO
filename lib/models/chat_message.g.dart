// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: (json['id'] as num).toInt(),
  allowChannelWideMentions: json['allow_channel_wide_mentions'] as bool,
  chatable: ChatableData.fromJson(json['chatable'] as Map<String, dynamic>),
  chatableId: (json['chatable_id'] as num).toInt(),
  chatableType: json['chatable_type'] as String?,
  chatableUrl: json['chatable_url'] as String?,
  description: json['description'] as String?,
  title: json['title'] as String?,
  unicodeTitle: json['unicode_title'] as String?,
  slug: json['slug'] as String?,
  status: json['status'] as String?,
  membershipsCount: (json['memberships_count'] as num?)?.toInt(),
  currentUserMembership: json['current_user_membership'] == null
      ? null
      : Membership.fromJson(
          json['current_user_membership'] as Map<String, dynamic>,
        ),
  threadingEnabled: json['threading_enabled'] as bool?,
  iconUploadUrl: json['icon_upload_url'] as String?,
  lastMessage: json['last_message'] == null
      ? null
      : ChatDetailMessage.fromJson(
          json['last_message'] as Map<String, dynamic>,
        ),
  meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'allow_channel_wide_mentions': instance.allowChannelWideMentions,
      'chatable': instance.chatable,
      'chatable_id': instance.chatableId,
      'chatable_type': instance.chatableType,
      'chatable_url': instance.chatableUrl,
      'description': instance.description,
      'title': instance.title,
      'unicode_title': instance.unicodeTitle,
      'slug': instance.slug,
      'status': instance.status,
      'memberships_count': instance.membershipsCount,
      'current_user_membership': instance.currentUserMembership,
      'threading_enabled': instance.threadingEnabled,
      'icon_upload_url': instance.iconUploadUrl,
      'last_message': instance.lastMessage,
      'meta': instance.meta,
    };

ChatableData _$ChatableDataFromJson(Map<String, dynamic> json) => ChatableData(
  group: json['group'] as bool?,
  users: (json['users'] as List<dynamic>?)
      ?.map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
      .toList(),
  uploadedLogo: json['uploaded_logo'] == null
      ? null
      : UploadedLogo.fromJson(json['uploaded_logo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatableDataToJson(ChatableData instance) =>
    <String, dynamic>{
      'group': instance.group,
      'users': instance.users,
      'uploaded_logo': instance.uploadedLogo,
    };

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  status: json['status'] == null
      ? null
      : UserStatus.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'status': instance.status,
};

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) => UserStatus(
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
  endsAt: json['ends_at'] as String?,
);

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{
      'description': instance.description,
      'emoji': instance.emoji,
      'ends_at': instance.endsAt,
    };

Membership _$MembershipFromJson(Map<String, dynamic> json) => Membership(
  following: json['following'] as bool,
  muted: json['muted'] as bool,
  notificationLevel: json['notification_level'] as String,
  chatChannelId: (json['chat_channel_id'] as num).toInt(),
  lastReadMessageId: (json['last_read_message_id'] as num?)?.toInt(),
  lastViewedAt: json['last_viewed_at'] as String,
);

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'following': instance.following,
      'muted': instance.muted,
      'notification_level': instance.notificationLevel,
      'chat_channel_id': instance.chatChannelId,
      'last_read_message_id': instance.lastReadMessageId,
      'last_viewed_at': instance.lastViewedAt,
    };

UploadedLogo _$UploadedLogoFromJson(Map<String, dynamic> json) => UploadedLogo(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
);

Map<String, dynamic> _$UploadedLogoToJson(UploadedLogo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  messageBusLastIds: MessageBusLastIds.fromJson(
    json['message_bus_last_ids'] as Map<String, dynamic>,
  ),
  canJoinChatChannel: json['can_join_chat_channel'] as bool,
  canFlag: json['can_flag'] as bool,
  userSilenced: json['user_silenced'] as bool,
  canModerate: json['can_moderate'] as bool,
  canDeleteSelf: json['can_delete_self'] as bool,
  canDeleteOthers: json['can_delete_others'] as bool,
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'message_bus_last_ids': instance.messageBusLastIds,
  'can_join_chat_channel': instance.canJoinChatChannel,
  'can_flag': instance.canFlag,
  'user_silenced': instance.userSilenced,
  'can_moderate': instance.canModerate,
  'can_delete_self': instance.canDeleteSelf,
  'can_delete_others': instance.canDeleteOthers,
};

MessageBusLastIds _$MessageBusLastIdsFromJson(Map<String, dynamic> json) =>
    MessageBusLastIds(
      channelMessageBusLastId: (json['channel_message_bus_last_id'] as num)
          .toInt(),
      newMessages: (json['new_messages'] as num).toInt(),
      newMentions: (json['new_mentions'] as num).toInt(),
    );

Map<String, dynamic> _$MessageBusLastIdsToJson(MessageBusLastIds instance) =>
    <String, dynamic>{
      'channel_message_bus_last_id': instance.channelMessageBusLastId,
      'new_messages': instance.newMessages,
      'new_mentions': instance.newMentions,
    };
