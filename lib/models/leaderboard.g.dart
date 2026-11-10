// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) =>
    LeaderboardResponse(
      personal: PersonalRank.fromJson(json['personal'] as Map<String, dynamic>),
      leaderboard: LeaderboardInfo.fromJson(
        json['leaderboard'] as Map<String, dynamic>,
      ),
      users: (json['users'] as List<dynamic>)
          .map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeaderboardResponseToJson(
  LeaderboardResponse instance,
) => <String, dynamic>{
  'personal': instance.personal,
  'leaderboard': instance.leaderboard,
  'users': instance.users,
};

PersonalRank _$PersonalRankFromJson(Map<String, dynamic> json) => PersonalRank(
  user: LeaderboardUser.fromJson(json['user'] as Map<String, dynamic>),
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$PersonalRankToJson(PersonalRank instance) =>
    <String, dynamic>{'user': instance.user, 'position': instance.position};

LeaderboardInfo _$LeaderboardInfoFromJson(Map<String, dynamic> json) =>
    LeaderboardInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      createdById: (json['created_by_id'] as num).toInt(),
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      visibleToGroupsIds: (json['visible_to_groups_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      includedGroupsIds: (json['included_groups_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      excludedGroupsIds: (json['excluded_groups_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      defaultPeriod: (json['default_period'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
      periodFilterDisabled: json['period_filter_disabled'] as bool,
    );

Map<String, dynamic> _$LeaderboardInfoToJson(LeaderboardInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_by_id': instance.createdById,
      'from_date': instance.fromDate,
      'to_date': instance.toDate,
      'visible_to_groups_ids': instance.visibleToGroupsIds,
      'included_groups_ids': instance.includedGroupsIds,
      'excluded_groups_ids': instance.excludedGroupsIds,
      'default_period': instance.defaultPeriod,
      'updated_at': instance.updatedAt,
      'period_filter_disabled': instance.periodFilterDisabled,
    };

LeaderboardUser _$LeaderboardUserFromJson(Map<String, dynamic> json) =>
    LeaderboardUser(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      avatarTemplate: json['avatar_template'] as String,
      totalScore: (json['total_score'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      animatedAvatar: json['animated_avatar'] as String?,
    );

Map<String, dynamic> _$LeaderboardUserToJson(LeaderboardUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar_template': instance.avatarTemplate,
      'total_score': instance.totalScore,
      'position': instance.position,
      'animated_avatar': instance.animatedAvatar,
    };
