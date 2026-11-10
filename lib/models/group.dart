import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class GroupResponse {
  final List<Group> groups;
  final GroupExtras extras;
  @JsonKey(name: 'total_rows_groups')
  final int totalRowsGroups;
  @JsonKey(name: 'load_more_groups')
  final String? loadMoreGroups;

  GroupResponse({
    required this.groups,
    required this.extras,
    required this.totalRowsGroups,
    this.loadMoreGroups,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupResponseToJson(this);
}

@JsonSerializable()
class Group {
  final int id;
  final bool? automatic;
  final String name;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'user_count')
  final int userCount;
  @JsonKey(name: 'mentionable_level')
  final int mentionableLevel;
  @JsonKey(name: 'messageable_level')
  final int messageableLevel;
  @JsonKey(name: 'visibility_level')
  final int visibilityLevel;
  @JsonKey(name: 'primary_group')
  final bool? primaryGroup;
  final String? title;
  @JsonKey(name: 'grant_trust_level')
  final int? grantTrustLevel;
  @JsonKey(name: 'has_messages')
  final bool? hasMessages;
  @JsonKey(name: 'flair_url')
  final String? flairUrl;
  @JsonKey(name: 'flair_bg_color')
  final String flairBgColor;
  @JsonKey(name: 'flair_color')
  final String flairColor;
  @JsonKey(name: 'bio_cooked')
  final String bioCooked;
  @JsonKey(name: 'bio_excerpt')
  final String bioExcerpt;
  @JsonKey(name: 'public_admission')
  final bool? publicAdmission;
  @JsonKey(name: 'public_exit')
  final bool? publicExit;
  @JsonKey(name: 'allow_membership_requests')
  final bool? allowMembershipRequests;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'default_notification_level')
  final int defaultNotificationLevel;
  @JsonKey(name: 'membership_request_template')
  final String? membershipRequestTemplate;
  @JsonKey(name: 'is_group_user')
  final bool? isGroupUser;
  @JsonKey(name: 'members_visibility_level')
  final int membersVisibilityLevel;
  @JsonKey(name: 'can_see_members')
  final bool? canSeeMembers;
  @JsonKey(name: 'publish_read_state')
  final bool? publishReadState;

  Group({
    required this.id,
    this.automatic,
    required this.name,
    this.displayName,
    required this.userCount,
    required this.mentionableLevel,
    required this.messageableLevel,
    required this.visibilityLevel,
    this.primaryGroup,
    this.title,
    this.grantTrustLevel,
    this.hasMessages,
    this.flairUrl,
    required this.flairBgColor,
    required this.flairColor,
    required this.bioCooked,
    required this.bioExcerpt,
    required this.publicAdmission,
    required this.publicExit,
    required this.allowMembershipRequests,
    this.fullName,
    required this.defaultNotificationLevel,
    this.membershipRequestTemplate,
    this.isGroupUser,
    required this.membersVisibilityLevel,
    this.canSeeMembers,
    this.publishReadState,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class GroupExtras {
  @JsonKey(name: 'type_filters')
  final List<String> typeFilters;

  GroupExtras({required this.typeFilters});

  factory GroupExtras.fromJson(Map<String, dynamic> json) =>
      _$GroupExtrasFromJson(json);
  Map<String, dynamic> toJson() => _$GroupExtrasToJson(this);
}
