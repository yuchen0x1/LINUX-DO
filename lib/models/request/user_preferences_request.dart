import 'package:json_annotation/json_annotation.dart';

part 'user_preferences_request.g.dart';

@JsonSerializable()
class UserPreferencesRequest {
  @JsonKey(name: 'bio_raw')
  final String? bioRaw;
  final String? website;
  final String? location;
  @JsonKey(name: 'custom_fields')
  final CustomFields? customFields;
  @JsonKey(name: 'card_background_upload_url')
  final String? cardBackgroundUploadUrl;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'hide_profile')
  final bool? hideProfile;
  final String? timezone;
  @JsonKey(name: 'default_calendar')
  final String? defaultCalendar;

  UserPreferencesRequest({
    this.bioRaw,
    this.website,
    this.location,
    this.customFields,
    this.cardBackgroundUploadUrl,
    this.dateOfBirth,
    this.hideProfile,
    this.timezone,
    this.defaultCalendar,
  });

  factory UserPreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesRequestToJson(this);
}

@JsonSerializable()
class CustomFields {
  @JsonKey(name: 'last_chat_channel_id')
  final int lastChatChannelId;
  @JsonKey(name: 'holidays-region')
  final String holidaysRegion;
  @JsonKey(name: 'telegram_chat_id')
  final String telegramChatId;
  @JsonKey(name: 'signature_url')
  final String signatureUrl;
  @JsonKey(name: 'see_signatures')
  final bool seeSignatures;

  CustomFields({
    required this.lastChatChannelId,
    required this.holidaysRegion,
    required this.telegramChatId,
    required this.signatureUrl,
    required this.seeSignatures,
  });

  factory CustomFields.fromJson(Map<String, dynamic> json) =>
      _$CustomFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$CustomFieldsToJson(this);
}
