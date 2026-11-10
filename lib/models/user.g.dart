// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  userBadges: (json['user_badges'] as List<dynamic>?)
      ?.map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
      .toList(),
  badges: (json['badges'] as List<dynamic>?)
      ?.map((e) => BadgeDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  badgeTypes: (json['badge_types'] as List<dynamic>?)
      ?.map((e) => BadgeType.fromJson(e as Map<String, dynamic>))
      .toList(),
  users: (json['users'] as List<dynamic>?)
      ?.map((e) => UserInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  user: json['user'] == null
      ? null
      : CurrentUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'user_badges': instance.userBadges,
      'badges': instance.badges,
      'badge_types': instance.badgeTypes,
      'users': instance.users,
      'user': instance.user,
    };

UserBadge _$UserBadgeFromJson(Map<String, dynamic> json) => UserBadge(
  id: (json['id'] as num).toInt(),
  grantedAt: json['granted_at'] as String,
  createdAt: json['created_at'] as String,
  count: (json['count'] as num).toInt(),
  badgeId: (json['badge_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  grantedById: (json['granted_by_id'] as num).toInt(),
);

Map<String, dynamic> _$UserBadgeToJson(UserBadge instance) => <String, dynamic>{
  'id': instance.id,
  'granted_at': instance.grantedAt,
  'created_at': instance.createdAt,
  'count': instance.count,
  'badge_id': instance.badgeId,
  'user_id': instance.userId,
  'granted_by_id': instance.grantedById,
};

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  grantCount: (json['grant_count'] as num).toInt(),
  allowTitle: json['allow_title'] as bool,
  multipleGrant: json['multiple_grant'] as bool,
  icon: json['icon'] as String?,
  imageUrl: json['image_url'] as String?,
  listable: json['listable'] as bool,
  enabled: json['enabled'] as bool,
  badgeGroupingId: (json['badge_grouping_id'] as num).toInt(),
  system: json['system'] as bool,
  slug: json['slug'] as String,
  manuallyGrantable: json['manually_grantable'] as bool,
  showInPostHeader: json['show_in_post_header'] as bool,
  badgeTypeId: (json['badge_type_id'] as num).toInt(),
);

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'grant_count': instance.grantCount,
  'allow_title': instance.allowTitle,
  'multiple_grant': instance.multipleGrant,
  'icon': instance.icon,
  'image_url': instance.imageUrl,
  'listable': instance.listable,
  'enabled': instance.enabled,
  'badge_grouping_id': instance.badgeGroupingId,
  'system': instance.system,
  'slug': instance.slug,
  'manually_grantable': instance.manuallyGrantable,
  'show_in_post_header': instance.showInPostHeader,
  'badge_type_id': instance.badgeTypeId,
};

BadgeType _$BadgeTypeFromJson(Map<String, dynamic> json) => BadgeType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
);

Map<String, dynamic> _$BadgeTypeToJson(BadgeType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_order': instance.sortOrder,
};

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  trustLevel: (json['trust_level'] as num?)?.toInt(),
  admin: json['admin'] as bool?,
  moderator: json['moderator'] as bool?,
  animatedAvatar: json['animated_avatar'] as String?,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'trust_level': instance.trustLevel,
  'admin': instance.admin,
  'moderator': instance.moderator,
  'animated_avatar': instance.animatedAvatar,
};

CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) => CurrentUser(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  email: json['email'] as String?,
  secondaryEmails: (json['secondary_emails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  unconfirmedEmails: (json['unconfirmed_emails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  lastPostedAt: json['last_posted_at'] as String?,
  lastSeenAt: json['last_seen_at'] as String?,
  createdAt: json['created_at'] as String?,
  ignored: json['ignored'] as bool? ?? false,
  muted: json['muted'] as bool? ?? false,
  canIgnoreUser: json['can_ignore_user'] as bool? ?? false,
  canMuteUser: json['can_mute_user'] as bool? ?? false,
  canSendPrivateMessages: json['can_send_private_messages'] as bool? ?? false,
  canSendPrivateMessageToUser:
      json['can_send_private_message_to_user'] as bool? ?? false,
  trustLevel: (json['trust_level'] as num?)?.toInt() ?? 0,
  moderator: json['moderator'] as bool? ?? false,
  admin: json['admin'] as bool? ?? false,
  title: json['title'] as String?,
  badgeCount: (json['badge_count'] as num?)?.toInt() ?? 0,
  customFields: json['custom_fields'] as Map<String, dynamic>?,
  timeRead: (json['time_read'] as num?)?.toInt() ?? 0,
  recentTimeRead: (json['recent_time_read'] as num?)?.toInt() ?? 0,
  primaryGroupId: (json['primary_group_id'] as num?)?.toInt(),
  primaryGroupName: json['primary_group_name'] as String?,
  flairGroupId: (json['flair_group_id'] as num?)?.toInt(),
  flairName: json['flair_name'] as String?,
  flairUrl: json['flair_url'] as String?,
  flairBgColor: json['flair_bg_color'] as String?,
  flairColor: json['flair_color'] as String?,
  timezone: json['timezone'] as String?,
  canEdit: json['can_edit'] as bool? ?? false,
  canEditUsername: json['can_edit_username'] as bool? ?? false,
  canEditEmail: json['can_edit_email'] as bool? ?? false,
  canEditName: json['can_edit_name'] as bool? ?? false,
  uploadedAvatarId: (json['uploaded_avatar_id'] as num?)?.toInt(),
  hasTitleBadges: json['has_title_badges'] as bool? ?? false,
  pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
  profileViewCount: (json['profile_view_count'] as num?)?.toInt() ?? 0,
  secondFactorEnabled: json['second_factor_enabled'] as bool? ?? false,
  secondFactorBackupEnabled:
      json['second_factor_backup_enabled'] as bool? ?? false,
  associatedAccounts: (json['associated_accounts'] as List<dynamic>?)
      ?.map((e) => Map<String, String>.from(e as Map))
      .toList(),
  cardBadge: json['card_badge'] == null
      ? null
      : UserCardBadge.fromJson(json['card_badge'] as Map<String, dynamic>),
  invitedBy: json['invited_by'] == null
      ? null
      : UserInfo.fromJson(json['invited_by'] as Map<String, dynamic>),
  gamificationScore: (json['gamification_score'] as num?)?.toInt(),
  groups: json['groups'] as List<dynamic>?,
  userAction: json['user_option'] == null
      ? null
      : UserAction.fromJson(json['user_option'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : UserStatus.fromJson(json['status'] as Map<String, dynamic>),
  totalFollowers: (json['total_followers'] as num?)?.toInt(),
  totalFollowing: (json['total_following'] as num?)?.toInt(),
  acceptedAnswers: (json['accepted_answers'] as num?)?.toInt(),
  cakedate: json['cakedate'] as String?,
  cardBackgroundUploadUrl: json['card_background_upload_url'] as String?,
  bioExcerpt: json['bio_excerpt'] as String?,
  endorseCategories: (json['category_expert_endorsements'] as List<dynamic>?)
      ?.map((e) => CategoryExpert.fromJson(e as Map<String, dynamic>))
      .toList(),
  voteCount: (json['vote_count'] as num?)?.toInt(),
  isFollowed: json['is_followed'] as bool?,
  userTitle: json['user_title'] as String?,
  userAuthTokens: (json['user_auth_tokens'] as List<dynamic>?)
      ?.map((e) => UserAuthToken.fromJson(e as Map<String, dynamic>))
      .toList(),
  sidebarCategoryIds: (json['sidebar_category_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  sidebarTags: (json['sidebar_tags'] as List<dynamic>?)
      ?.map((e) => Tags.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CurrentUserToJson(CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar_template': instance.avatarTemplate,
      'email': instance.email,
      'secondary_emails': instance.secondaryEmails,
      'unconfirmed_emails': instance.unconfirmedEmails,
      'last_posted_at': instance.lastPostedAt,
      'last_seen_at': instance.lastSeenAt,
      'created_at': instance.createdAt,
      'cakedate': instance.cakedate,
      'ignored': instance.ignored,
      'muted': instance.muted,
      'can_ignore_user': instance.canIgnoreUser,
      'can_mute_user': instance.canMuteUser,
      'can_send_private_messages': instance.canSendPrivateMessages,
      'can_send_private_message_to_user': instance.canSendPrivateMessageToUser,
      'trust_level': instance.trustLevel,
      'moderator': instance.moderator,
      'admin': instance.admin,
      'title': instance.title,
      'badge_count': instance.badgeCount,
      'custom_fields': instance.customFields,
      'time_read': instance.timeRead,
      'recent_time_read': instance.recentTimeRead,
      'primary_group_id': instance.primaryGroupId,
      'primary_group_name': instance.primaryGroupName,
      'flair_group_id': instance.flairGroupId,
      'flair_name': instance.flairName,
      'flair_url': instance.flairUrl,
      'flair_bg_color': instance.flairBgColor,
      'flair_color': instance.flairColor,
      'timezone': instance.timezone,
      'can_edit': instance.canEdit,
      'can_edit_username': instance.canEditUsername,
      'can_edit_email': instance.canEditEmail,
      'can_edit_name': instance.canEditName,
      'uploaded_avatar_id': instance.uploadedAvatarId,
      'has_title_badges': instance.hasTitleBadges,
      'pending_count': instance.pendingCount,
      'profile_view_count': instance.profileViewCount,
      'second_factor_enabled': instance.secondFactorEnabled,
      'second_factor_backup_enabled': instance.secondFactorBackupEnabled,
      'associated_accounts': instance.associatedAccounts,
      'invited_by': instance.invitedBy,
      'groups': instance.groups,
      'gamification_score': instance.gamificationScore,
      'user_option': instance.userAction,
      'status': instance.status,
      'total_followers': instance.totalFollowers,
      'total_following': instance.totalFollowing,
      'accepted_answers': instance.acceptedAnswers,
      'card_background_upload_url': instance.cardBackgroundUploadUrl,
      'card_badge': instance.cardBadge,
      'bio_excerpt': instance.bioExcerpt,
      'category_expert_endorsements': instance.endorseCategories,
      'vote_count': instance.voteCount,
      'is_followed': instance.isFollowed,
      'user_title': instance.userTitle,
      'user_auth_tokens': instance.userAuthTokens,
      'sidebar_category_ids': instance.sidebarCategoryIds,
      'sidebar_tags': instance.sidebarTags,
    };

UserCardBadge _$UserCardBadgeFromJson(Map<String, dynamic> json) =>
    UserCardBadge(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String?,
      grantCount: (json['grant_count'] as num?)?.toInt(),
      allowTitle: json['allow_title'] as bool?,
      multipleGrant: json['multiple_grant'] as bool?,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      listable: json['listable'] as bool?,
      enabled: json['enabled'] as bool?,
      badgeGroupId: (json['badge_grouping_id'] as num?)?.toInt(),
      system: json['system'] as bool?,
      slug: json['slug'] as String?,
      manuallyGrantable: json['manually_grantable'] as bool?,
      showInPostHeader: json['show_in_post_header'] as bool?,
      badgeTypeId: (json['badge_type_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserCardBadgeToJson(UserCardBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'grant_count': instance.grantCount,
      'allow_title': instance.allowTitle,
      'multiple_grant': instance.multipleGrant,
      'icon': instance.icon,
      'image_url': instance.imageUrl,
      'listable': instance.listable,
      'enabled': instance.enabled,
      'badge_grouping_id': instance.badgeGroupId,
      'system': instance.system,
      'slug': instance.slug,
      'manually_grantable': instance.manuallyGrantable,
      'show_in_post_header': instance.showInPostHeader,
      'badge_type_id': instance.badgeTypeId,
    };

CategoryExpert _$CategoryExpertFromJson(Map<String, dynamic> json) =>
    CategoryExpert(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      endorsedUserId: (json['endorsed_user_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CategoryExpertToJson(CategoryExpert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'endorsed_user_id': instance.endorsedUserId,
      'category_id': instance.categoryId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

Tags _$TagsFromJson(Map<String, dynamic> json) => Tags(
  name: json['name'] as String?,
  description: json['description'] as String?,
  pmOnly: json['pm_only'] as bool?,
);

Map<String, dynamic> _$TagsToJson(Tags instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'pm_only': instance.pmOnly,
};
