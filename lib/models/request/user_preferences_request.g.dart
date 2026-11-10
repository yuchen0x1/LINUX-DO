// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesRequest _$UserPreferencesRequestFromJson(
  Map<String, dynamic> json,
) => UserPreferencesRequest(
  bioRaw: json['bio_raw'] as String?,
  website: json['website'] as String?,
  location: json['location'] as String?,
  customFields: json['custom_fields'] == null
      ? null
      : CustomFields.fromJson(json['custom_fields'] as Map<String, dynamic>),
  cardBackgroundUploadUrl: json['card_background_upload_url'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  hideProfile: json['hide_profile'] as bool?,
  timezone: json['timezone'] as String?,
  defaultCalendar: json['default_calendar'] as String?,
);

Map<String, dynamic> _$UserPreferencesRequestToJson(
  UserPreferencesRequest instance,
) => <String, dynamic>{
  'bio_raw': instance.bioRaw,
  'website': instance.website,
  'location': instance.location,
  'custom_fields': instance.customFields,
  'card_background_upload_url': instance.cardBackgroundUploadUrl,
  'date_of_birth': instance.dateOfBirth,
  'hide_profile': instance.hideProfile,
  'timezone': instance.timezone,
  'default_calendar': instance.defaultCalendar,
};

CustomFields _$CustomFieldsFromJson(Map<String, dynamic> json) => CustomFields(
  lastChatChannelId: (json['last_chat_channel_id'] as num).toInt(),
  holidaysRegion: json['holidays-region'] as String,
  telegramChatId: json['telegram_chat_id'] as String,
  signatureUrl: json['signature_url'] as String,
  seeSignatures: json['see_signatures'] as bool,
);

Map<String, dynamic> _$CustomFieldsToJson(CustomFields instance) =>
    <String, dynamic>{
      'last_chat_channel_id': instance.lastChatChannelId,
      'holidays-region': instance.holidaysRegion,
      'telegram_chat_id': instance.telegramChatId,
      'signature_url': instance.signatureUrl,
      'see_signatures': instance.seeSignatures,
    };
