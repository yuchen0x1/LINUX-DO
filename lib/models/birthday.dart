import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

part 'birthday.g.dart';

@JsonSerializable()
class BirthdayResponse {
  final List<Birthday> birthdays;
  @JsonKey(name: 'total_rows_birthdays')
  final int totalRowsBirthdays;
  @JsonKey(name: 'load_more_birthdays')
  final String? loadMoreBirthdays;

  BirthdayResponse({
    required this.birthdays,
    required this.totalRowsBirthdays,
    this.loadMoreBirthdays,
  });

  factory BirthdayResponse.fromJson(Map<String, dynamic> json) =>
      _$BirthdayResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayResponseToJson(this);
}

@JsonSerializable()
class Birthday {
  final int id;
  final String username;
  final String name;
  @JsonKey(name: 'avatar_template')
  final String avatarTemplate;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;
  final String? title;
  final String cakedate;

  Birthday({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarTemplate,
    this.animatedAvatar,
    this.title,
    required this.cakedate,
  });

  factory Birthday.fromJson(Map<String, dynamic> json) =>
      _$BirthdayFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayToJson(this);

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
}
