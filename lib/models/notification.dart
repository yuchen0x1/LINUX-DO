import 'package:json_annotation/json_annotation.dart';
import '../net/http_config.dart';
import '../utils/expand/datetime_expand.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationResponse {
  @JsonKey(name: 'notifications', defaultValue: [])
  final List<NotificationItem> notifications;
  @JsonKey(name: 'total_rows_notifications', defaultValue: 0)
  final int totalRowsNotifications;
  @JsonKey(name: 'seen_notification_id', defaultValue: 0)
  final int seenNotificationId;
  @JsonKey(name: 'load_more_notifications', defaultValue: '')
  final String loadMoreNotifications;

  NotificationResponse({
    required this.notifications,
    required this.totalRowsNotifications,
    required this.seenNotificationId,
    required this.loadMoreNotifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class NotificationItem {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(name: 'user_id', defaultValue: 0)
  final int userId;
  @JsonKey(name: 'notification_type', defaultValue: 0)
  final int notificationType;
  @JsonKey(defaultValue: false)
  final bool read;
  @JsonKey(name: 'high_priority', defaultValue: false)
  final bool highPriority;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;
  @JsonKey(name: 'post_number')
  final int? postNumber;
  @JsonKey(name: 'topic_id')
  final int? topicId;
  @JsonKey(name: 'fancy_title')
  final String? fancyTitle;
  @JsonKey(name: 'slug')
  final String? slug;
  final NotificationData data;
  @JsonKey(name: 'acting_user_avatar_template', defaultValue: '')
  final String actingUserAvatarTemplate;
  @JsonKey(name: 'acting_user_name', defaultValue: '')
  final String actingUserName;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.read,
    required this.highPriority,
    required this.createdAt,
    this.postNumber,
    this.topicId,
    this.fancyTitle,
    this.slug,
    required this.data,
    required this.actingUserAvatarTemplate,
    required this.actingUserName,
  });

  String getUesrName() {
    if (data.originalUsername.isNotEmpty) {
      return data.originalUsername;
    }
    return actingUserName;
  }

  String getAvatarUrl() {
    if (actingUserAvatarTemplate.isEmpty) {
      return '';
    }
    if (actingUserAvatarTemplate.startsWith('http://') ||
        actingUserAvatarTemplate.startsWith('https://')) {
      return actingUserAvatarTemplate;
    }
    return '${HttpConfig.baseUrl}${actingUserAvatarTemplate.replaceAll('{size}', '80')}';
  }

  bool isWebMaster() {
    return userId == 1;
  }

  String get formattedDate {
    final date = DateTime.parse(createdAt);
    return date.friendlyDateTime;
  }

  String getTitle() {
    switch (notificationType) {
      case 12:
        return '你获得了 ${data.badgeName} 徽章';
      case 2:
        return '${data.displayUsername} 回复了你的帖子 ${data.topicTitle}';
      default:
        return fancyTitle ?? '';
    }
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class NotificationData {
  @JsonKey(name: 'display_username', defaultValue: '')
  final String displayUsername;
  @JsonKey(name: 'avatar_template', defaultValue: '')
  final String avatarTemplate;
  @JsonKey(name: 'original_username', defaultValue: '')
  final String originalUsername;
  @JsonKey(name: 'original_avatar_template', defaultValue: '')
  final String originalAvatarTemplate;
  @JsonKey(defaultValue: '')
  final String message;
  @JsonKey(name: 'topic_title', defaultValue: '')
  final String topicTitle;
  @JsonKey(name: 'original_post_id', defaultValue: 0)
  final int originalPostId;
  @JsonKey(name: 'original_post_type', defaultValue: 0)
  final int originalPostType;
  @JsonKey(name: 'revision_number')
  final int? revisionNumber;
  @JsonKey(name: 'reaction_icon', defaultValue: '')
  final String reactionIcon;
  @JsonKey(name: 'original_name', defaultValue: '')
  final String originalName;
  @JsonKey(name: 'badge_id', defaultValue: 0)
  final int badgeId;
  @JsonKey(name: 'badge_name', defaultValue: '')
  final String badgeName;
  @JsonKey(name: 'badge_slug', defaultValue: '')
  final String badgeSlug;
  @JsonKey(name: 'badge_title', defaultValue: false)
  final bool badgeTitle;
  @JsonKey(name: 'username', defaultValue: '')
  final String username;

  NotificationData({
    required this.displayUsername,
    required this.avatarTemplate,
    required this.originalUsername,
    required this.originalAvatarTemplate,
    required this.message,
    required this.topicTitle,
    required this.originalPostId,
    required this.originalPostType,
    this.revisionNumber,
    required this.reactionIcon,
    required this.originalName,
    required this.badgeId,
    required this.badgeName,
    required this.badgeSlug,
    required this.badgeTitle,
    required this.username,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}
