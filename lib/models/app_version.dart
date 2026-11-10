import 'package:json_annotation/json_annotation.dart';

part 'app_version.g.dart';

@JsonSerializable()
class AppVersion {
  @JsonKey(name: 'has_update')
  final bool? hasUpdate;
  @JsonKey(name: 'latest_version')
  final String? latestVersion;
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @JsonKey(name: 'release_notes')
  final String? releaseNotes;
  @JsonKey(name: 'is_force_update')
  final bool? isForceUpdate;
  @JsonKey(name: 'min_required_version')
  final String? minRequiredVersion;

  AppVersion({
    this.hasUpdate,
    this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
    this.isForceUpdate,
    this.minRequiredVersion,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) =>
      _$AppVersionFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionToJson(this);
}
