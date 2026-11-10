// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BirthdayResponse _$BirthdayResponseFromJson(Map<String, dynamic> json) =>
    BirthdayResponse(
      birthdays: (json['birthdays'] as List<dynamic>)
          .map((e) => Birthday.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRowsBirthdays: (json['total_rows_birthdays'] as num).toInt(),
      loadMoreBirthdays: json['load_more_birthdays'] as String?,
    );

Map<String, dynamic> _$BirthdayResponseToJson(BirthdayResponse instance) =>
    <String, dynamic>{
      'birthdays': instance.birthdays,
      'total_rows_birthdays': instance.totalRowsBirthdays,
      'load_more_birthdays': instance.loadMoreBirthdays,
    };

Birthday _$BirthdayFromJson(Map<String, dynamic> json) => Birthday(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String,
  avatarTemplate: json['avatar_template'] as String,
  animatedAvatar: json['animated_avatar'] as String?,
  title: json['title'] as String?,
  cakedate: json['cakedate'] as String,
);

Map<String, dynamic> _$BirthdayToJson(Birthday instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'animated_avatar': instance.animatedAvatar,
  'title': instance.title,
  'cakedate': instance.cakedate,
};
