// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  login: json['login'] as String,
  password: json['password'] as String,
  secondFactorMethod: (json['second_factor_method'] as num).toInt(),
  timezone: json['timezone'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
      'second_factor_method': instance.secondFactorMethod,
      'timezone': instance.timezone,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String?,
      user: json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'error': instance.error,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String?,
  avatarTemplate: json['avatar_template'] as String?,
  email: json['email'] as String?,
  trustLevel: (json['trust_level'] as num).toInt(),
  moderator: json['moderator'] as bool,
  admin: json['admin'] as bool,
  canCreateTopic: json['can_create_topic'] as bool,
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatar_template': instance.avatarTemplate,
  'email': instance.email,
  'trust_level': instance.trustLevel,
  'moderator': instance.moderator,
  'admin': instance.admin,
  'can_create_topic': instance.canCreateTopic,
};
