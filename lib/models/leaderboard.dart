import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

part 'leaderboard.g.dart';

@JsonSerializable()
class LeaderboardResponse {
  final PersonalRank personal;
  final LeaderboardInfo leaderboard;
  final List<LeaderboardUser> users;

  LeaderboardResponse({
    required this.personal,
    required this.leaderboard,
    required this.users,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardResponseToJson(this);
}

@JsonSerializable()
class PersonalRank {
  final LeaderboardUser user;
  final int position;

  PersonalRank({required this.user, required this.position});

  factory PersonalRank.fromJson(Map<String, dynamic> json) =>
      _$PersonalRankFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalRankToJson(this);
}

@JsonSerializable()
class LeaderboardInfo {
  final int id;
  final String name;
  @JsonKey(name: 'created_by_id')
  final int createdById;
  @JsonKey(name: 'from_date')
  final String? fromDate;
  @JsonKey(name: 'to_date')
  final String? toDate;
  @JsonKey(name: 'visible_to_groups_ids')
  final List<int> visibleToGroupsIds;
  @JsonKey(name: 'included_groups_ids')
  final List<int> includedGroupsIds;
  @JsonKey(name: 'excluded_groups_ids')
  final List<int> excludedGroupsIds;
  @JsonKey(name: 'default_period')
  final int defaultPeriod;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'period_filter_disabled')
  final bool periodFilterDisabled;

  LeaderboardInfo({
    required this.id,
    required this.name,
    required this.createdById,
    this.fromDate,
    this.toDate,
    required this.visibleToGroupsIds,
    required this.includedGroupsIds,
    required this.excludedGroupsIds,
    required this.defaultPeriod,
    required this.updatedAt,
    required this.periodFilterDisabled,
  });

  factory LeaderboardInfo.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardInfoToJson(this);
}

@JsonSerializable()
class LeaderboardUser {
  final int id;
  final String username;
  final String name;
  @JsonKey(name: 'avatar_template')
  final String avatarTemplate;
  @JsonKey(name: 'total_score')
  final int totalScore;
  final int position;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  LeaderboardUser({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarTemplate,
    required this.totalScore,
    required this.position,
    this.animatedAvatar,
  });

  // 获取格式化后的分数
  String get formattedScore {
    return totalScore.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 获取头像URL
  String get avatarUrl {
    if (animatedAvatar != null && animatedAvatar!.isNotEmpty) {
      if (animatedAvatar!.startsWith('http://') ||
          animatedAvatar!.startsWith('https://')) {
        return animatedAvatar!;
      }
      return '${HttpConfig.baseUrl}${animatedAvatar!.replaceAll('{size}', '80')}';
    }

    if (avatarTemplate.isEmpty) {
      return '';
    }
    if (avatarTemplate.startsWith('http://') ||
        avatarTemplate.startsWith('https://')) {
      return avatarTemplate;
    }
    return '${HttpConfig.baseUrl}${avatarTemplate.replaceAll('{size}', '80')}';
  }

  String get displayName {
    if (name.isEmpty || name.length > 12) {
      return username.replaceAll('\n', ' ');
    }
    return name.replaceAll('\n', ' ');
  }

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardUserFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardUserToJson(this);
}
