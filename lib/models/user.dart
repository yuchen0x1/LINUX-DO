import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/models/user_action.dart';
import 'package:linux_do/models/user_auth_token.dart';
import 'package:linux_do/models/user_status.dart';
import 'package:linux_do/net/http_config.dart';

import 'badge_detail.dart';
part 'user.g.dart';

@JsonSerializable()
class UserResponse {
  @JsonKey(name: 'user_badges')
  final List<UserBadge>? userBadges;
  @JsonKey(name: 'badges')
  final List<BadgeDetail>? badges;
  @JsonKey(name: 'badge_types')
  final List<BadgeType>? badgeTypes;
  @JsonKey(name: 'users')
  final List<UserInfo>? users;
  @JsonKey(name: 'user')
  final CurrentUser? user;

  UserResponse({
    this.userBadges,
    this.badges,
    this.badgeTypes,
    this.users,
    this.user,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  String toString() {
    return 'UserResponse(user: $user)';
  }
}

@JsonSerializable()
class UserBadge {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'granted_at')
  final String grantedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'badge_id')
  final int badgeId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'granted_by_id')
  final int grantedById;

  UserBadge({
    required this.id,
    required this.grantedAt,
    required this.createdAt,
    required this.count,
    required this.badgeId,
    required this.userId,
    required this.grantedById,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}

@JsonSerializable()
class Badge {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'grant_count')
  final int grantCount;
  @JsonKey(name: 'allow_title')
  final bool allowTitle;
  @JsonKey(name: 'multiple_grant')
  final bool multipleGrant;
  @JsonKey(name: 'icon')
  final String? icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'listable')
  final bool listable;
  @JsonKey(name: 'enabled')
  final bool enabled;
  @JsonKey(name: 'badge_grouping_id')
  final int badgeGroupingId;
  @JsonKey(name: 'system')
  final bool system;
  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(name: 'manually_grantable')
  final bool manuallyGrantable;
  @JsonKey(name: 'show_in_post_header')
  final bool showInPostHeader;
  @JsonKey(name: 'badge_type_id')
  final int badgeTypeId;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.grantCount,
    required this.allowTitle,
    required this.multipleGrant,
    this.icon,
    this.imageUrl,
    required this.listable,
    required this.enabled,
    required this.badgeGroupingId,
    required this.system,
    required this.slug,
    required this.manuallyGrantable,
    required this.showInPostHeader,
    required this.badgeTypeId,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}

@JsonSerializable()
class BadgeType {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  BadgeType({required this.id, required this.name, required this.sortOrder});

  factory BadgeType.fromJson(Map<String, dynamic> json) =>
      _$BadgeTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeTypeToJson(this);
}

@JsonSerializable()
class UserInfo {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'username')
  final String? username;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'trust_level')
  final int? trustLevel;
  @JsonKey(name: 'admin')
  final bool? admin;
  @JsonKey(name: 'moderator')
  final bool? moderator;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  UserInfo({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarTemplate,
    this.trustLevel,
    this.admin,
    this.moderator,
    this.animatedAvatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable()
class CurrentUser {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'secondary_emails')
  final List<String>? secondaryEmails;
  @JsonKey(name: 'unconfirmed_emails')
  final List<String>? unconfirmedEmails;
  @JsonKey(name: 'last_posted_at')
  final String? lastPostedAt;
  @JsonKey(name: 'last_seen_at')
  final String? lastSeenAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'cakedate')
  final String? cakedate;
  @JsonKey(name: 'ignored')
  final bool ignored;
  @JsonKey(name: 'muted')
  final bool muted;
  @JsonKey(name: 'can_ignore_user')
  final bool canIgnoreUser;
  @JsonKey(name: 'can_mute_user')
  final bool canMuteUser;
  @JsonKey(name: 'can_send_private_messages')
  final bool canSendPrivateMessages;
  @JsonKey(name: 'can_send_private_message_to_user')
  final bool canSendPrivateMessageToUser;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'moderator')
  final bool moderator;
  @JsonKey(name: 'admin')
  final bool admin;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'badge_count')
  final int badgeCount;
  @JsonKey(name: 'custom_fields')
  final Map<String, dynamic>? customFields;
  @JsonKey(name: 'time_read')
  final int timeRead;
  @JsonKey(name: 'recent_time_read')
  final int recentTimeRead;
  @JsonKey(name: 'primary_group_id')
  final int? primaryGroupId;
  @JsonKey(name: 'primary_group_name')
  final String? primaryGroupName;
  @JsonKey(name: 'flair_group_id')
  final int? flairGroupId;
  @JsonKey(name: 'flair_name')
  final String? flairName;
  @JsonKey(name: 'flair_url')
  final String? flairUrl;
  @JsonKey(name: 'flair_bg_color')
  final String? flairBgColor;
  @JsonKey(name: 'flair_color')
  final String? flairColor;
  @JsonKey(name: 'timezone')
  final String? timezone;
  @JsonKey(name: 'can_edit')
  final bool canEdit;
  @JsonKey(name: 'can_edit_username')
  final bool canEditUsername;
  @JsonKey(name: 'can_edit_email')
  final bool canEditEmail;
  @JsonKey(name: 'can_edit_name')
  final bool canEditName;
  @JsonKey(name: 'uploaded_avatar_id')
  final int? uploadedAvatarId;
  @JsonKey(name: 'has_title_badges')
  final bool hasTitleBadges;
  @JsonKey(name: 'pending_count')
  final int pendingCount;
  @JsonKey(name: 'profile_view_count')
  final int profileViewCount;
  @JsonKey(name: 'second_factor_enabled')
  final bool secondFactorEnabled;
  @JsonKey(name: 'second_factor_backup_enabled')
  final bool secondFactorBackupEnabled;
  @JsonKey(name: 'associated_accounts')
  final List<Map<String, String>>? associatedAccounts;
  @JsonKey(name: 'invited_by')
  final UserInfo? invitedBy;
  @JsonKey(name: 'groups')
  final List<dynamic>? groups;
  @JsonKey(name: 'gamification_score')
  final int? gamificationScore;
  @JsonKey(name: 'user_option')
  final UserAction? userAction;
  @JsonKey(name: 'status')
  final UserStatus? status;
  @JsonKey(name: 'total_followers')
  final int? totalFollowers;
  @JsonKey(name: 'total_following')
  final int? totalFollowing;
  @JsonKey(name: 'accepted_answers')
  final int? acceptedAnswers;
  @JsonKey(name: 'card_background_upload_url')
  final String? cardBackgroundUploadUrl;
  @JsonKey(name: 'card_badge')
  final UserCardBadge? cardBadge;
  @JsonKey(name: 'bio_excerpt')
  final String? bioExcerpt;
  @JsonKey(name: 'category_expert_endorsements')
  final List<CategoryExpert>? endorseCategories;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'is_followed')
  final bool? isFollowed;
  @JsonKey(name: 'user_title')
  final String? userTitle;
  @JsonKey(name: 'user_auth_tokens')
  final List<UserAuthToken>? userAuthTokens;
  @JsonKey(name: 'sidebar_category_ids')
  final List<int>? sidebarCategoryIds;
  @JsonKey(name: 'sidebar_tags')
  final List<Tags>? sidebarTags;
  @JsonKey(name: 'birthdate')
  final String? birthdate;

  CurrentUser({
    required this.id,
    required this.username,
    this.name,
    required this.avatarTemplate,
    required this.email,
    this.secondaryEmails,
    this.unconfirmedEmails,
    this.lastPostedAt,
    this.lastSeenAt,
    this.createdAt,
    this.ignored = false,
    this.muted = false,
    this.canIgnoreUser = false,
    this.canMuteUser = false,
    this.canSendPrivateMessages = false,
    this.canSendPrivateMessageToUser = false,
    this.trustLevel = 0,
    this.moderator = false,
    this.admin = false,
    this.title,
    this.badgeCount = 0,
    this.customFields,
    this.timeRead = 0,
    this.recentTimeRead = 0,
    this.primaryGroupId,
    this.primaryGroupName,
    this.flairGroupId,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.timezone,
    this.canEdit = false,
    this.canEditUsername = false,
    this.canEditEmail = false,
    this.canEditName = false,
    this.uploadedAvatarId,
    this.hasTitleBadges = false,
    this.pendingCount = 0,
    this.profileViewCount = 0,
    this.secondFactorEnabled = false,
    this.secondFactorBackupEnabled = false,
    this.associatedAccounts,
    this.cardBadge,
    this.invitedBy,
    this.gamificationScore,
    this.groups,
    this.userAction,
    this.status,
    this.totalFollowers,
    this.totalFollowing,
    this.acceptedAnswers,
    this.cakedate,
    this.cardBackgroundUploadUrl,
    this.bioExcerpt,
    this.endorseCategories,
    this.voteCount,
    this.isFollowed,
    this.userTitle,
    this.userAuthTokens,
    this.sidebarCategoryIds,
    this.sidebarTags,
    this.birthdate,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentUserToJson(this);

  @override
  String toString() {
    return 'CurrentUser(id: $id, username: $username, customFields: $customFields)';
  }

  String get avatarUrl {
    if (avatarTemplate == null || avatarTemplate!.isEmpty) {
      return '';
    }
    if (avatarTemplate!.startsWith('http://') ||
        avatarTemplate!.startsWith('https://')) {
      return avatarTemplate!;
    }
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll('{size}', '100')}';
  }

  String? get backgroundUrl {
    // 如果不包含https:// 则添加
    if (cardBackgroundUploadUrl != null &&
        !cardBackgroundUploadUrl!.startsWith('https://')) {
      final tmpUrl = cardBackgroundUploadUrl!.replaceAll(RegExp(r'/+'), '/');
      return '${HttpConfig.baseUrl}$tmpUrl';
    }
    return cardBackgroundUploadUrl;
  }

  bool isWebMaster() {
    return id == 1;
  }
}

@JsonSerializable()
class UserCardBadge {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'grant_count')
  final int? grantCount;
  @JsonKey(name: 'allow_title')
  final bool? allowTitle;
  @JsonKey(name: 'multiple_grant')
  final bool? multipleGrant;
  @JsonKey(name: 'icon')
  final String? icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'listable')
  final bool? listable;
  @JsonKey(name: 'enabled')
  final bool? enabled;
  @JsonKey(name: 'badge_grouping_id')
  final int? badgeGroupId;
  @JsonKey(name: 'system')
  final bool? system;
  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'manually_grantable')
  final bool? manuallyGrantable;
  @JsonKey(name: 'show_in_post_header')
  final bool? showInPostHeader;
  @JsonKey(name: 'badge_type_id')
  final int? badgeTypeId;

  UserCardBadge({
    required this.id,
    this.description,
    this.grantCount,
    this.allowTitle,
    this.multipleGrant,
    this.icon,
    this.imageUrl,
    this.listable,
    this.enabled,
    this.badgeGroupId,
    this.system,
    this.slug,
    this.manuallyGrantable,
    this.showInPostHeader,
    this.badgeTypeId,
  });

  factory UserCardBadge.fromJson(Map<String, dynamic> json) =>
      _$UserCardBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserCardBadgeToJson(this);
}

@JsonSerializable()
class CategoryExpert {
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'endorsed_user_id')
  final int? endorsedUserId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CategoryExpert({
    this.id,
    this.userId,
    this.endorsedUserId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryExpert.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpertFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryExpertToJson(this);
}

@JsonSerializable()
class Tags {
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'pm_only')
  final bool? pmOnly;

  Tags({this.name, this.description, this.pmOnly});

  factory Tags.fromJson(Map<String, dynamic> json) => _$TagsFromJson(json);
  Map<String, dynamic> toJson() => _$TagsToJson(this);
}
