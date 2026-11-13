import 'package:json_annotation/json_annotation.dart';

part 'user_request.g.dart';

@JsonSerializable()
class UserRequest {
  final String name;
  final String title;
  @JsonKey(name: 'primary_group_id')
  final int primaryGroupId;
  @JsonKey(name: 'flair_group_id')
  final int flairGroupId;
  final UserStatus status;

  UserRequest({
    required this.name,
    required this.title,
    required this.primaryGroupId,
    required this.flairGroupId,
    required this.status,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
}

@JsonSerializable()
class UserStatus {
  final String description;
  final String emoji;
  @JsonKey(name: 'ends_at')
  final String? endsAt;
  @JsonKey(name: 'message_bus_last_id')
  final int messageBusLastId;

  UserStatus({
    required this.description,
    required this.emoji,
    this.endsAt,
    required this.messageBusLastId,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}
