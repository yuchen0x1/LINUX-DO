// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersion _$AppVersionFromJson(Map<String, dynamic> json) => AppVersion(
  hasUpdate: json['has_update'] as bool?,
  latestVersion: json['latest_version'] as String?,
  downloadUrl: json['download_url'] as String?,
  releaseNotes: json['release_notes'] as String?,
  isForceUpdate: json['is_force_update'] as bool?,
  minRequiredVersion: json['min_required_version'] as String?,
);

Map<String, dynamic> _$AppVersionToJson(AppVersion instance) =>
    <String, dynamic>{
      'has_update': instance.hasUpdate,
      'latest_version': instance.latestVersion,
      'download_url': instance.downloadUrl,
      'release_notes': instance.releaseNotes,
      'is_force_update': instance.isForceUpdate,
      'min_required_version': instance.minRequiredVersion,
    };
