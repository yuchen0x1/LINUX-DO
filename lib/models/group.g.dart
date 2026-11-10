// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupResponse _$GroupResponseFromJson(Map<String, dynamic> json) =>
    GroupResponse(
      groups: (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      extras: GroupExtras.fromJson(json['extras'] as Map<String, dynamic>),
      totalRowsGroups: (json['total_rows_groups'] as num).toInt(),
      loadMoreGroups: json['load_more_groups'] as String?,
    );

Map<String, dynamic> _$GroupResponseToJson(GroupResponse instance) =>
    <String, dynamic>{
      'groups': instance.groups,
      'extras': instance.extras,
      'total_rows_groups': instance.totalRowsGroups,
      'load_more_groups': instance.loadMoreGroups,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  id: (json['id'] as num).toInt(),
  automatic: json['automatic'] as bool?,
  name: json['name'] as String,
  displayName: json['display_name'] as String?,
  userCount: (json['user_count'] as num).toInt(),
  mentionableLevel: (json['mentionable_level'] as num).toInt(),
  messageableLevel: (json['messageable_level'] as num).toInt(),
  visibilityLevel: (json['visibility_level'] as num).toInt(),
  primaryGroup: json['primary_group'] as bool?,
  title: json['title'] as String?,
  grantTrustLevel: (json['grant_trust_level'] as num?)?.toInt(),
  hasMessages: json['has_messages'] as bool?,
  flairUrl: json['flair_url'] as String?,
  flairBgColor: json['flair_bg_color'] as String,
  flairColor: json['flair_color'] as String,
  bioCooked: json['bio_cooked'] as String,
  bioExcerpt: json['bio_excerpt'] as String,
  publicAdmission: json['public_admission'] as bool?,
  publicExit: json['public_exit'] as bool?,
  allowMembershipRequests: json['allow_membership_requests'] as bool?,
  fullName: json['full_name'] as String?,
  defaultNotificationLevel: (json['default_notification_level'] as num).toInt(),
  membershipRequestTemplate: json['membership_request_template'] as String?,
  isGroupUser: json['is_group_user'] as bool?,
  membersVisibilityLevel: (json['members_visibility_level'] as num).toInt(),
  canSeeMembers: json['can_see_members'] as bool?,
  publishReadState: json['publish_read_state'] as bool?,
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'automatic': instance.automatic,
  'name': instance.name,
  'display_name': instance.displayName,
  'user_count': instance.userCount,
  'mentionable_level': instance.mentionableLevel,
  'messageable_level': instance.messageableLevel,
  'visibility_level': instance.visibilityLevel,
  'primary_group': instance.primaryGroup,
  'title': instance.title,
  'grant_trust_level': instance.grantTrustLevel,
  'has_messages': instance.hasMessages,
  'flair_url': instance.flairUrl,
  'flair_bg_color': instance.flairBgColor,
  'flair_color': instance.flairColor,
  'bio_cooked': instance.bioCooked,
  'bio_excerpt': instance.bioExcerpt,
  'public_admission': instance.publicAdmission,
  'public_exit': instance.publicExit,
  'allow_membership_requests': instance.allowMembershipRequests,
  'full_name': instance.fullName,
  'default_notification_level': instance.defaultNotificationLevel,
  'membership_request_template': instance.membershipRequestTemplate,
  'is_group_user': instance.isGroupUser,
  'members_visibility_level': instance.membersVisibilityLevel,
  'can_see_members': instance.canSeeMembers,
  'publish_read_state': instance.publishReadState,
};

GroupExtras _$GroupExtrasFromJson(Map<String, dynamic> json) => GroupExtras(
  typeFilters: (json['type_filters'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GroupExtrasToJson(GroupExtras instance) =>
    <String, dynamic>{'type_filters': instance.typeFilters};
