// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  notifications:
      (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  totalRowsNotifications:
      (json['total_rows_notifications'] as num?)?.toInt() ?? 0,
  seenNotificationId: (json['seen_notification_id'] as num?)?.toInt() ?? 0,
  loadMoreNotifications: json['load_more_notifications'] as String? ?? '',
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'total_rows_notifications': instance.totalRowsNotifications,
  'seen_notification_id': instance.seenNotificationId,
  'load_more_notifications': instance.loadMoreNotifications,
};

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      notificationType: (json['notification_type'] as num?)?.toInt() ?? 0,
      read: json['read'] as bool? ?? false,
      highPriority: json['high_priority'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      postNumber: (json['post_number'] as num?)?.toInt(),
      topicId: (json['topic_id'] as num?)?.toInt(),
      fancyTitle: json['fancy_title'] as String?,
      slug: json['slug'] as String?,
      data: NotificationData.fromJson(json['data'] as Map<String, dynamic>),
      actingUserAvatarTemplate:
          json['acting_user_avatar_template'] as String? ?? '',
      actingUserName: json['acting_user_name'] as String? ?? '',
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'notification_type': instance.notificationType,
      'read': instance.read,
      'high_priority': instance.highPriority,
      'created_at': instance.createdAt,
      'post_number': instance.postNumber,
      'topic_id': instance.topicId,
      'fancy_title': instance.fancyTitle,
      'slug': instance.slug,
      'data': instance.data,
      'acting_user_avatar_template': instance.actingUserAvatarTemplate,
      'acting_user_name': instance.actingUserName,
    };

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      displayUsername: json['display_username'] as String? ?? '',
      avatarTemplate: json['avatar_template'] as String? ?? '',
      originalUsername: json['original_username'] as String? ?? '',
      originalAvatarTemplate: json['original_avatar_template'] as String? ?? '',
      message: json['message'] as String? ?? '',
      topicTitle: json['topic_title'] as String? ?? '',
      originalPostId: (json['original_post_id'] as num?)?.toInt() ?? 0,
      originalPostType: (json['original_post_type'] as num?)?.toInt() ?? 0,
      revisionNumber: (json['revision_number'] as num?)?.toInt(),
      reactionIcon: json['reaction_icon'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      badgeId: (json['badge_id'] as num?)?.toInt() ?? 0,
      badgeName: json['badge_name'] as String? ?? '',
      badgeSlug: json['badge_slug'] as String? ?? '',
      badgeTitle: json['badge_title'] as bool? ?? false,
      username: json['username'] as String? ?? '',
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'display_username': instance.displayUsername,
      'avatar_template': instance.avatarTemplate,
      'original_username': instance.originalUsername,
      'original_avatar_template': instance.originalAvatarTemplate,
      'message': instance.message,
      'topic_title': instance.topicTitle,
      'original_post_id': instance.originalPostId,
      'original_post_type': instance.originalPostType,
      'revision_number': instance.revisionNumber,
      'reaction_icon': instance.reactionIcon,
      'original_name': instance.originalName,
      'badge_id': instance.badgeId,
      'badge_name': instance.badgeName,
      'badge_slug': instance.badgeSlug,
      'badge_title': instance.badgeTitle,
      'username': instance.username,
    };
