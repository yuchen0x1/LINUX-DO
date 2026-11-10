import 'package:json_annotation/json_annotation.dart';
part 'user_status.g.dart';

@JsonSerializable()
class UserStatus {
  final String? description;
  final String? emoji;
  @JsonKey(name: 'ends_at')
  final String? endsAt;
  @JsonKey(name: 'message_bus_last_id')
  final int? messageBusLastId;

  UserStatus({
    required this.description,
    required this.emoji,
    required this.endsAt,
    required this.messageBusLastId,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}
